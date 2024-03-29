USE [u_karcinsk]
GO
/****** Object:  UserDefinedFunction [dbo].[CanUseOneTimeDiscount]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CanUseOneTimeDiscount] (@ClientID int)
RETURNS bit
AS
BEGIN
    DECLARE @D2LatestDate date
    SELECT @D2LatestDate = D2LatestDate FROM Discounts WHERE ClientID = @ClientID
    DECLARE @D2Used bit
    SELECT @D2Used = D2Used FROM Discounts WHERE ClientID = @ClientID
    DECLARE @D1 int
    SELECT @D1 = D1 FROM Variables
    IF @D2LatestDate IS NOT NULL AND @D2Used = 0 AND GETDATE() <= DATEADD(day, @D1, @D2LatestDate)
        RETURN 1
    RETURN 0
END
GO
/****** Object:  UserDefinedFunction [dbo].[ClientDiscounts]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ClientDiscounts](@ClientID int)
RETURNS @Discounts TABLE (
    D1 bit,
    R1 float,
    OrdersLeft int,
    D2 bit,
    R2 float,
    ExpireDate date,
    AmountToGetNext money
)
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM IndividualClients WHERE ClientID = @ClientID)
        RETURN
    DECLARE @D1 bit
    SELECT @D1 = D1 FROM Discounts WHERE ClientID = @ClientID
    DECLARE @R1 float
    SELECT @R1 = R1 FROM Variables
    DECLARE @D2 bit
    IF dbo.CanUseOneTimeDiscount(@ClientID) = 1
        SET @D2 = 1
    ELSE
        SET @D2 = 0
    DECLARE @R2 float
    SELECT @R2 = R2 FROM Variables
    DECLARE @OrdersLeft int
    IF @D1 = 1
        SET @OrdersLeft = 0
    ELSE
    BEGIN
        DECLARE @K1 money
        SELECT @K1 = K1 FROM Variables
        DECLARE @Z1 int
        SELECT @Z1 = Z1 FROM Variables
        SELECT @OrdersLeft = COUNT(OrderID)
        FROM Orders
        WHERE ClientID = @ClientID AND Accepted = 1 AND dbo.PriceOfOrder(OrderID) >= @K1
        SET @OrdersLeft = @Z1 - @OrdersLeft
    END
    DECLARE @Date date
    SELECT @Date = D2LatestDate FROM Discounts WHERE ClientID = @ClientID
    DECLARE @Days int
    SELECT @Days = D1 FROM Variables
    DECLARE @ExpireDate date
    SET @ExpireDate = DATEADD(day, @Days, @Date)
    DECLARE @K2 money
    SELECT @K2 = K2 FROM Variables
    DECLARE @Amount money
    SELECT @Amount = ISNULL(SUM(dbo.PriceOfOrder(OrderID)), 0)
    FROM Orders
    WHERE ClientID = @ClientID AND Accepted = 1 AND OrderDate > @Date
    SET @Amount = @K2 - @Amount
    INSERT INTO @Discounts (D1, R1, OrdersLeft, D2, R2, ExpireDate, AmountToGetNext)
    VALUES (@D1, @R1, @OrdersLeft, @D2, @R2, @ExpireDate, @Amount)
    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsEntitledToOneTimeDiscount]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsEntitledToOneTimeDiscount] (@ClientID INT)
RETURNS bit
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM IndividualClients WHERE ClientID = @ClientID)
        RETURN 0
	DECLARE @K2 money
	SELECT @K2 = K2 FROM Variables
	DECLARE @Date date
	SELECT @Date = D2LatestDate FROM Discounts WHERE ClientID = @ClientID
    DECLARE @TotalCost int
    SELECT @TotalCost = SUM(dbo.PriceOfOrder(OrderID))
    FROM Orders
    WHERE ClientID = @ClientID AND Accepted = 1 AND OrderDate > @Date
    IF (@TotalCost >= @K2)
        RETURN 1
    RETURN 0
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsEntitledToReusableDiscount]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsEntitledToReusableDiscount] (@ClientID INT)
RETURNS bit
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM IndividualClients WHERE ClientID = @ClientID)
        RETURN 0
	DECLARE @K1 money
	SELECT @K1 = K1 FROM Variables
	DECLARE @Z1 int
	SELECT @Z1 = Z1 FROM Variables
    DECLARE @NumberOfOrders int
    SELECT @NumberOfOrders = COUNT(OrderID)
    FROM Orders
    WHERE ClientID = @ClientID AND Accepted = 1 AND dbo.PriceOfOrder(OrderID) >= @K1
    IF (@NumberOfOrders >= @Z1)
        RETURN 1
    RETURN 0
END
GO
/****** Object:  UserDefinedFunction [dbo].[MonthlyEmployeeCTOperate]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthlyEmployeeCTOperate] ()
RETURNS @myTable TABLE 
		([id] float,
		 [Jan] float,
		 [Feb] float,
		 [Mar] float,
		 [Apr] float,
		 [May] float,
		 [Jun] float,
		 [Jul] float,
		 [Aug] float,
		 [Sep] float,
		 [Oct] float,
		 [Nov] float,
		 [Dec] float)
AS BEGIN
	DECLARE 
		@idEmployee int = 1,
		@maxEmployee int = (SELECT COUNT(*) FROM Employees),
		@jan float = 0,
		@feb float = 0,
		@mar float = 0,
		@apr float = 0,
		@may float = 0,
		@jun float = 0,
		@jul float = 0,
		@aug float = 0,
		@sep float = 0,
		@oct float = 0,
		@nov float = 0,
		@dec float = 0
	WHILE @idEmployee <= @maxEmployee
	BEGIN
		SET @jan = (SELECT * FROM dbo.EmployeeCTOperateMonth(1,@idEmployee))
		SET @feb = (SELECT * FROM dbo.EmployeeCTOperateMonth(2,@idEmployee))
		SET @mar = (SELECT * FROM dbo.EmployeeCTOperateMonth(3,@idEmployee))
		SET @apr = (SELECT * FROM dbo.EmployeeCTOperateMonth(4,@idEmployee))
		SET @may = (SELECT * FROM dbo.EmployeeCTOperateMonth(5,@idEmployee))
		SET @jun = (SELECT * FROM dbo.EmployeeCTOperateMonth(6,@idEmployee))
		SET @jul = (SELECT * FROM dbo.EmployeeCTOperateMonth(7,@idEmployee))
		SET @aug = (SELECT * FROM dbo.EmployeeCTOperateMonth(8,@idEmployee))
		SET @sep = (SELECT * FROM dbo.EmployeeCTOperateMonth(9,@idEmployee))
		SET @oct = (SELECT * FROM dbo.EmployeeCTOperateMonth(10,@idEmployee))
		SET @nov = (SELECT * FROM dbo.EmployeeCTOperateMonth(11,@idEmployee))
		SET @dec = (SELECT * FROM dbo.EmployeeCTOperateMonth(12,@idEmployee))

		INSERT INTO @myTable ([id],[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec])
		VALUES (@idEmployee,@jan,@feb,@mar,@apr,@may,@jun,@jul,@aug,@sep,@oct,@nov,@dec)
		SET @idEmployee = @idEmployee + 1
	END

	UPDATE @myTable SET Jan=0.0 WHERE Jan is NULL
	UPDATE @myTable SET Feb=0.0 WHERE Feb is NULL
	UPDATE @myTable SET Mar=0.0 WHERE Mar is NULL
	UPDATE @myTable SET Apr=0.0 WHERE Apr is NULL
	UPDATE @myTable SET May=0.0 WHERE May is NULL
	UPDATE @myTable SET Jun=0.0 WHERE Jun is NULL
	UPDATE @myTable SET Jul=0.0 WHERE Jul is NULL
	UPDATE @myTable SET Aug=0.0 WHERE Aug is NULL
	UPDATE @myTable SET Sep=0.0 WHERE Sep is NULL
	UPDATE @myTable SET Oct=0.0 WHERE Oct is NULL
	UPDATE @myTable SET Nov=0.0 WHERE Nov is NULL
	UPDATE @myTable SET Dec=0.0 WHERE Dec is NULL

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[MonthlyEmployeeOperate]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthlyEmployeeOperate] ()
RETURNS @myTable TABLE 
		([id] float,
		 [Jan] float,
		 [Feb] float,
		 [Mar] float,
		 [Apr] float,
		 [May] float,
		 [Jun] float,
		 [Jul] float,
		 [Aug] float,
		 [Sep] float,
		 [Oct] float,
		 [Nov] float,
		 [Dec] float)
AS BEGIN
	DECLARE 
		@idEmployee int = 1,
		@maxEmployee int = (SELECT COUNT(*) FROM Employees),
		@jan float = 0,
		@feb float = 0,
		@mar float = 0,
		@apr float = 0,
		@may float = 0,
		@jun float = 0,
		@jul float = 0,
		@aug float = 0,
		@sep float = 0,
		@oct float = 0,
		@nov float = 0,
		@dec float = 0
	WHILE @idEmployee <= @maxEmployee
	BEGIN
		SET @jan = (SELECT * FROM dbo.EmployeeOperateMonth(1,@idEmployee))
		SET @feb = (SELECT * FROM dbo.EmployeeOperateMonth(2,@idEmployee))
		SET @mar = (SELECT * FROM dbo.EmployeeOperateMonth(3,@idEmployee))
		SET @apr = (SELECT * FROM dbo.EmployeeOperateMonth(4,@idEmployee))
		SET @may = (SELECT * FROM dbo.EmployeeOperateMonth(5,@idEmployee))
		SET @jun = (SELECT * FROM dbo.EmployeeOperateMonth(6,@idEmployee))
		SET @jul = (SELECT * FROM dbo.EmployeeOperateMonth(7,@idEmployee))
		SET @aug = (SELECT * FROM dbo.EmployeeOperateMonth(8,@idEmployee))
		SET @sep = (SELECT * FROM dbo.EmployeeOperateMonth(9,@idEmployee))
		SET @oct = (SELECT * FROM dbo.EmployeeOperateMonth(10,@idEmployee))
		SET @nov = (SELECT * FROM dbo.EmployeeOperateMonth(11,@idEmployee))
		SET @dec = (SELECT * FROM dbo.EmployeeOperateMonth(12,@idEmployee))

		INSERT INTO @myTable ([id],[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec])
		VALUES (@idEmployee,@jan,@feb,@mar,@apr,@may,@jun,@jul,@aug,@sep,@oct,@nov,@dec)
		SET @idEmployee = @idEmployee + 1
	END

	UPDATE @myTable SET Jan=0.0 WHERE Jan is NULL
	UPDATE @myTable SET Feb=0.0 WHERE Feb is NULL
	UPDATE @myTable SET Mar=0.0 WHERE Mar is NULL
	UPDATE @myTable SET Apr=0.0 WHERE Apr is NULL
	UPDATE @myTable SET May=0.0 WHERE May is NULL
	UPDATE @myTable SET Jun=0.0 WHERE Jun is NULL
	UPDATE @myTable SET Jul=0.0 WHERE Jul is NULL
	UPDATE @myTable SET Aug=0.0 WHERE Aug is NULL
	UPDATE @myTable SET Sep=0.0 WHERE Sep is NULL
	UPDATE @myTable SET Oct=0.0 WHERE Oct is NULL
	UPDATE @myTable SET Nov=0.0 WHERE Nov is NULL
	UPDATE @myTable SET Dec=0.0 WHERE Dec is NULL

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[MonthlyIncomeAndAmount]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthlyIncomeAndAmount] ()
RETURNS @myTable TABLE 
		([Month] int,
		 [Total] float,
		 [Amount] int)
AS
BEGIN
	INSERT INTO @myTable ([Month], [Total], [Amount])
	SELECT tmp.mont, tmp.total, tmp.amount
	FROM
	(SELECT MONTH(O.OrderDate) mont,
		SUM(TR.WithDiscount) total,
		COUNT(TR.WithDiscount) amount
	FROM TotalReceipt TR JOIN Orders O 
	ON O.OrderID = TR.OrderID
	WHERE YEAR(GETDATE()) <= YEAR(O.OrderDate) OR ( YEAR(GETDATE()) - 1 = YEAR(O.OrderDate) AND MONTH(GETDATE()) <= MONTH(O.OrderDate) )
	GROUP BY MONTH(O.OrderDate)) tmp
	
	DECLARE @idColumn int = 1
	WHILE @idColumn <= 12
	BEGIN
		IF @idColumn NOT IN (SELECT [Month] FROM @myTable)
		BEGIN
			INSERT INTO @myTable ([Month], [Total], [Amount]) VALUES (@idColumn, 0.0, 0)
		END
		SET @idColumn = @idColumn + 1
	END

	RETURN

END
GO
/****** Object:  UserDefinedFunction [dbo].[OrdersInDayLastMonth]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[OrdersInDayLastMonth] (@day INT)
RETURNS INT AS
BEGIN
	RETURN (SELECT COUNT(*) FROM (
	SELECT DATEPART(WEEKDAY, RealisationDate) dt FROM Orders WHERE 
	(MONTH(RealisationDate) + 1 = MONTH(GETDATE()) AND YEAR(RealisationDate) = YEAR(GETDATE()))
	OR (MONTH(RealisationDate) = 12 AND MONTH(GETDATE()) = 1 AND YEAR(RealisationDate) + 1 = YEAR(GETDATE()))
	) TMP WHERE TMP.dt = @day)
END

GO
/****** Object:  UserDefinedFunction [dbo].[OrdersLastMonth]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[OrdersLastMonth] ()
RETURNS @myTable TABLE
	([mon] int,
	 [tue] int,
	 [wed] int,
	 [thu] int,
	 [fri] int,
	 [sat] int,
	 [sun] int)
AS BEGIN
	DECLARE
	@MO int = (SELECT * FROM dbo.OrdersInDayLastMonth(1)),
	@TU int = (SELECT * FROM dbo.OrdersInDayLastMonth(2)),
	@WE int = (SELECT * FROM dbo.OrdersInDayLastMonth(3)),
	@TH int = (SELECT * FROM dbo.OrdersInDayLastMonth(4)),
	@FR int = (SELECT * FROM dbo.OrdersInDayLastMonth(5)),
	@SA int = (SELECT * FROM dbo.OrdersInDayLastMonth(6)),
	@SU int = (SELECT * FROM dbo.OrdersInDayLastMonth(7))

	INSERT INTO @myTable ([mon], [tue], [wed],
	 [thu], [fri], [sat], [sun])
	 VALUES (@MO, @TU, @WE, @TH, @FR, @SA, @SU)
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[PriceOfOrder]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PriceOfOrder] (@OrderID INT)
RETURNS FLOAT AS
BEGIN
	RETURN (SELECT WithDiscount FROM TotalReceipt WHERE OrderID = @OrderID)
END

GO
/****** Object:  UserDefinedFunction [dbo].[SumClientReceipt]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SumClientReceipt] (@clientID INT)
RETURNS FLOAT AS
BEGIN
	RETURN (SELECT ROUND(SUM(Quantity* UnitPrice*(1-Discount)),2) AS A
		FROM Orders O JOIN OrderDetails OD ON O.OrderID = OD.OrderID
		WHERE Accepted = 1
		GROUP BY ClientID
		HAVING ClientID = @clientID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[ClientOrdersHistory]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ClientOrdersHistory] (@ClientID int)
RETURNS TABLE
AS
	RETURN (SELECT OrderDate, RealisationDate, ToGo, Discount, dbo.PriceOfOrder(OrderID) AS Cost
            FROM Orders
            WHERE ClientID = @ClientID AND Accepted = 1)
GO
/****** Object:  UserDefinedFunction [dbo].[ClientsFromCompany]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ClientsFromCompany] (@companyID INT)
RETURNS TABLE AS
RETURN (SELECT * FROM IndividualClients WHERE CompanyID = @companyID)

GO
/****** Object:  UserDefinedFunction [dbo].[EmployeeCTOperateMonth]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[EmployeeCTOperateMonth] (@idMonth int, @idEmployee int)
RETURNS TABLE AS
RETURN((SELECT 
		COUNT(TR.WithDiscount) total
	FROM TotalReceipt TR JOIN Orders O 
	ON O.OrderID = TR.OrderID
	WHERE (YEAR(GETDATE()) <= YEAR(O.OrderDate) OR ( YEAR(GETDATE()) - 1 = YEAR(O.OrderDate) AND MONTH(GETDATE()) <= MONTH(O.OrderDate) ))
	AND (O.EmployeeID =@idEmployee) AND MONTH(O.OrderDate) = @idMonth))
GO
/****** Object:  UserDefinedFunction [dbo].[EmployeeOperateMonth]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[EmployeeOperateMonth] (@idMonth int, @idEmployee int)
RETURNS TABLE AS
RETURN((SELECT 
		SUM(TR.WithDiscount) total
	FROM TotalReceipt TR JOIN Orders O 
	ON O.OrderID = TR.OrderID
	WHERE (YEAR(GETDATE()) <= YEAR(O.OrderDate) OR ( YEAR(GETDATE()) - 1 = YEAR(O.OrderDate) AND MONTH(GETDATE()) <= MONTH(O.OrderDate) ))
	AND (O.EmployeeID =@idEmployee) AND MONTH(O.OrderDate) = @idMonth))
GO
/****** Object:  UserDefinedFunction [dbo].[OrdersOperatedByEmployee]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[OrdersOperatedByEmployee] (@employeeID INT)
RETURNS TABLE AS
RETURN (SELECT OrderID FROM ORDERS WHERE EmployeeID = @employeeID)
GO
/****** Object:  UserDefinedFunction [dbo].[OrdersOrderedBetween]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[OrdersOrderedBetween] (@start DATETIME = '2000-01-01 23:59:59.000', @end DATETIME = '3000-01-01 23:59:59.000')
RETURNS TABLE AS
RETURN (SELECT * FROM Orders 
		WHERE OrderDate >= @start AND OrderDate <= @end)
GO
/****** Object:  UserDefinedFunction [dbo].[OrdersRealisedBetween]    Script Date: 13.01.2023 15:34:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[OrdersRealisedBetween] (@start DATETIME = '2000-01-01 23:59:59.000', @end DATETIME = '2025-01-01 23:59:59.000')
RETURNS TABLE AS
RETURN (SELECT * FROM Orders 
		WHERE RealisationDate >= @start AND RealisationDate <= @end)
GO
