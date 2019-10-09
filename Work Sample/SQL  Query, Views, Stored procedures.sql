/*--------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
		SQL query statement
----------------------------------------------------------------*/


USE testdb
GO

select * from Trans_Incr_2







/*--------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
		Creating views tables
----------------------------------------------------------------*/

CREATE VIEW [Above Average Price] AS
SELECT  top 1000 TRANSACTION_TYPE, PRINCIPLE_AMOUNT
FROM Trans_Incr_2
WHERE PRINCIPLE_AMOUNT > (SELECT AVG(PRINCIPLE_AMOUNT) FROM Trans_Incr_2);


SELECT * FROM [Above Average Price];








/*--------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
		Stored procedure 
----------------------------------------------------------------*/
USE [testdb]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_AllPOC_VCASH]
AS

  
/*----------------------------------------------------------------------------------------
       month to month Comparisons           
----------------------------------------------------------------------------------------*/
-- create month_to_month database if it does not exists
IF NOT EXISTS (select * from sysobjects where name='mowiz_month_to_month' and xtype='U')
CREATE TABLE [dbo].[mowiz_month_to_month](
	[ITYPE] [varchar](150) NULL,
	[PREV_REV] [float] NULL,
	[CURR_REV] [float] NULL,
	[REVENUE_DIFF] [float] NULL
);

IF EXISTS (select * from sysobjects where name='mowiz_month_to_month' and xtype='U')
TRUNCATE TABLE mowiz_month_to_month;
-- Insert into month_to_month data table
INSERT INTO mowiz_month_to_month
	select curr_month.ITYPE,SUM(prev_month.AMOUNTVALUE) PREV_REV,SUM(curr_month.AMOUNTVALUE) CURR_REV,SUM((curr_month.AMOUNTVALUE - prev_month.AMOUNTVALUE)) REVENUE_DIFF from
		(select TRANSACTION_TYPE ITYPE,DATE,SUM(CHARGE_AOPFX_USD) AMOUNTVALUE FROM Trans_Incr_2 WHERE DATE>=dateadd(MONTH, datediff(MONTH,0, getdate()), 0) AND DATE < getdate()   group by DATE,TRANSACTION_TYPE ) curr_month
				left join
		(select TRANSACTION_TYPE ITYPE,DATE, SUM(CHARGE_AOPFX_USD) AMOUNTVALUE FROM Trans_Incr_2 WHERE DATE>=DATEADD(MONTH,-1,dateadd(MONTH, datediff(MONTH,0, getdate()), 0)) AND DATE < EOMONTH(DATEADD(MONTH,-1, getdate())) group by DATE,TRANSACTION_TYPE) prev_month
		on prev_month.ITYPE = curr_month.ITYPE
	WHERE (curr_month.AMOUNTVALUE - prev_month.AMOUNTVALUE) < 0 
	GROUP BY curr_month.ITYPE








