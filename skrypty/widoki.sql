USE [u_karcinsk]
GO
/****** Object:  View [dbo].[CompanyEmployees]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CompanyEmployees] AS
SELECT * FROM IndividualClients
    WHERE CompanyID IS NOT NULL
    
GO
/****** Object:  View [dbo].[CurrentMonthIncome]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CurrentMonthIncome] AS
SELECT SUM(Quantity*UnitPrice) AS Income FROM OrderDetails
JOIN Orders O on O.OrderID = OrderDetails.OrderID
WHERE MONTH(OrderDate) = MONTH(GETDATE()) AND YEAR(OrderDate) = YEAR(GETDATE())
GO
/****** Object:  View [dbo].[CurrentMonthSales]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CurrentMonthSales] AS
SELECT O.OrderID, PositionID, Quantity, UnitPrice, OrderDate FROM OrderDetails
JOIN Orders O on O.OrderID = OrderDetails.OrderID
WHERE MONTH(OrderDate) = MONTH(GETDATE()) AND YEAR(OrderDate) = YEAR(GETDATE())
GO
/****** Object:  View [dbo].[CurrentSeaFood]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CurrentSeaFood] AS
    SELECT * FROM Menu WHERE Category = 'Owoce morza'
GO
/****** Object:  View [dbo].[MenuInfo]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MenuInfo] AS
    SELECT AP.PositionID, PositionName, UnitPrice, CategoryName FROM Menu
    JOIN AllPositions AP on AP.PositionID = Menu.PositionID
GO
/****** Object:  View [dbo].[MonthlyIncome]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonthlyIncome] AS
SELECT * FROM dbo.MonthlyIncomeAndAmount()
GO
/****** Object:  View [dbo].[MonthlyIncomeReportForEmployee]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonthlyIncomeReportForEmployee] AS
(SELECT * FROM dbo.MonthlyEmployeeOperate())
GO
/****** Object:  View [dbo].[MonthlyOperatedReportForEmployee]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MonthlyOperatedReportForEmployee] AS
(SELECT * FROM dbo.MonthlyEmployeeCTOperate())
GO
/****** Object:  View [dbo].[NotAccepted]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NotAccepted] AS
    SELECT * FROM Orders WHERE Accepted = 0
GO
/****** Object:  View [dbo].[OrdersByHour]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrdersByHour] AS
    SELECT DATEPART(hour, OrderDate) AS Hour, COUNT(OrderID) AS NumberOfOrders, ROUND(SUM(dbo.PriceOfOrder(OrderID)), 2) AS TotalCost
    FROM Orders
    GROUP BY DATEPART(hour, OrderDate)
GO
/****** Object:  View [dbo].[PreviousMonthIncome]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PreviousMonthIncome] AS
SELECT SUM(Quantity*UnitPrice) AS Income FROM OrderDetails
JOIN Orders O on O.OrderID = OrderDetails.OrderID
WHERE MONTH(DATEADD(month, 1, OrderDate)) = MONTH(GETDATE()) AND YEAR(DATEADD(month, 1, OrderDate)) = YEAR(GETDATE())
GO
/****** Object:  View [dbo].[PreviousMonthSales]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PreviousMonthSales] AS
    SELECT O.OrderID, PositionID, Quantity, UnitPrice, OrderDate FROM OrderDetails
    JOIN Orders O on O.OrderID = OrderDetails.OrderID
    WHERE MONTH(DATEADD(month, 1, OrderDate)) = MONTH(GETDATE()) AND YEAR(DATEADD(month, 1, OrderDate)) = YEAR(GETDATE())
GO
/****** Object:  View [dbo].[TotalReceipt]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TotalReceipt] AS
SELECT O.OrderID, 
	TMP.WithoutDiscount,
	ROUND(TMP.WithoutDiscount * (1-O.Discount), 2) as WithDiscount,
	O.Discount
	FROM Orders O
	JOIN
	(SELECT OrderID, 
		SUM(Quantity * UnitPrice) as WithoutDiscount
		FROM OrderDetails 
		GROUP BY OrderID) TMP ON O.OrderID = TMP.OrderID
GO
/****** Object:  View [dbo].[WeekDayLastMonth]    Script Date: 13.01.2023 15:33:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WeekDayLastMonth] AS
	(SELECT * FROM dbo.OrdersLastMonth())
GO
