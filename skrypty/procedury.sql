USE [u_karcinsk]
GO
/****** Object:  StoredProcedure [dbo].[AcceptOrder]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AcceptOrder]
    @OrderID int
AS
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
        RAISERROR(N'Nie ma takiego zamówienia', 16, 1)
    UPDATE Orders
    SET Accepted = 'true'
    WHERE OrderID = @OrderID
GO
/****** Object:  StoredProcedure [dbo].[AddCompanyClient]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddCompanyClient]
    @CompanyName varchar(255),
    @Address varchar(255),
    @Phone int,
    @NIP bigint
AS
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM CompanyClients WHERE NIP = @NIP)
        RAISERROR(N'Firma jest już w bazie', 16, 1)
    DECLARE @ClientID int
    SELECT @ClientID = MAX(ClientID) + 1 FROM Clients
    INSERT INTO CompanyClients(ClientID, CompanyName, Address, Phone, NIP)
    VALUES (@ClientID, @CompanyName, @Address, @Phone, @NIP)
GO
/****** Object:  StoredProcedure [dbo].[AddEmployee]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddEmployee]
    @FirstName varchar(255),
    @LastName varchar(255)
AS
    SET NOCOUNT ON
    DECLARE @EmployeeID int
    SELECT @EmployeeID = MAX(EmployeeID) + 1 FROM Employees
    INSERT INTO Employees(EmployeeID, FirstName, LastName)
    VALUES (@EmployeeID, @FirstName, @LastName)
GO
/****** Object:  StoredProcedure [dbo].[AddIndividualClient]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddIndividualClient]
    @FirstName varchar(255),
    @LastName varchar(255),
    @Phone int,
    @CompanyID int
AS
    SET NOCOUNT ON
    IF @CompanyID IS NOT NULL AND NOT EXISTS(SELECT * FROM CompanyClients WHERE ClientID = @CompanyID)
        RAISERROR('Nie ma takiej firmy w bazie', 16, 1)
    DECLARE @ClientID int
    SELECT @ClientID = MAX(ClientID) + 1 FROM Clients
    INSERT INTO IndividualClients(ClientID, FirstName, LastName, Phone, NumOrders, CompanyID)
    VALUES (@ClientID, @FirstName, @LastName, @Phone, 0, @CompanyID)
    INSERT INTO Discounts(ClientID, D1, D2Used, D2LatestDate)
    VALUES (@ClientID, 0, 0, null)
GO
/****** Object:  StoredProcedure [dbo].[AddOrder]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddOrder]
    @ClientID int,
    @Discount float,
    @RealisationDate datetime,
    @ToGo bit,
    @EmployeeID int
AS
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT * FROM Clients WHERE ClientID = @ClientID)
        RAISERROR('Nie ma takiego klienta w bazie', 16, 1)
    IF @EmployeeID IS NOT NULL AND NOT EXISTS(SELECT * FROM Employees WHERE EmployeeID = @EmployeeID)
        RAISERROR('Nie ma takiego pracownika w bazie', 16, 1)
    DECLARE @OrderID int
    SELECT @OrderID = ISNULL(MAX(OrderID), 0) + 1 FROM Orders
    IF @Discount IS NULL
    BEGIN
        DECLARE @R1 float
        IF (SELECT D1 FROM Discounts WHERE ClientID = @ClientID) = 1
            SELECT @R1 = R1 FROM Variables
        ELSE
            SELECT @R1 = 0
        DECLARE @R2 float
        IF dbo.CanUseOneTimeDiscount(@ClientID) = 1
            SELECT @R2 = R2 FROM Variables
        ELSE
            SELECT @R2 = 0
        IF @R2 > @R1
        BEGIN
            SET @Discount = @R2
            UPDATE Discounts
            SET D2Used = 1
            WHERE ClientID = @ClientID
        END
        ELSE
            SET @Discount = @R1
    END
    INSERT INTO Orders(OrderID, ClientID, Discount, OrderDate, RealisationDate, ToGo, Accepted, EmployeeID)
    VALUES (@OrderID, @ClientID, @Discount, GETDATE(), @RealisationDate, @ToGo, 'false', @EmployeeID)
GO
/****** Object:  StoredProcedure [dbo].[AddOrderDetail]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddOrderDetail]
    @OrderID int,
    @PositionID int,
    @Quantity int
AS
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
        RAISERROR(N'Nie ma takiego zamówienia w bazie', 16, 1)
    IF NOT EXISTS(SELECT * FROM Menu WHERE PositionID = @PositionID)
        RAISERROR('Nie ma takiej pozycji w menu', 16, 1)
    DECLARE @UnitPrice money
    SELECT @UnitPrice = UnitPrice FROM AllPositions WHERE PositionID = @PositionID
    INSERT INTO OrderDetails(OrderID, PositionID, Quantity, UnitPrice)
    VALUES (@OrderID, @PositionID, @Quantity, @UnitPrice)
    DECLARE @ClientID int
    SELECT @ClientID = ClientID FROM Orders WHERE OrderID = @OrderID
    IF (SELECT D1 FROM Discounts WHERE ClientID = @ClientID) = 0 AND dbo.IsEntitledToReusableDiscount(@ClientID) = 1
        UPDATE Discounts
        SET D1 = 1
        WHERE ClientID = @ClientID
    IF dbo.IsEntitledToOneTimeDiscount(@ClientID) = 1
        UPDATE Discounts
        SET D2Used = 0, D2LatestDate = GETDATE()
        WHERE ClientID = @ClientID
GO
/****** Object:  StoredProcedure [dbo].[AddPosition]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddPosition]
    @PositionName varchar(255),
    @CategoryName varchar(255),
    @UnitPrice money
AS
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM AllPositions WHERE PositionName = @PositionName)
        RAISERROR(N'Taka pozycja już istnieje', 16, 1)
    IF NOT EXISTS(SELECT * FROM AllPositions WHERE CategoryName = @CategoryName)
        RAISERROR('Taka kategoria nie istnieje', 16, 1)
    DECLARE @PositionID int
    SELECT @PositionID = MAX(PositionID) + 1 FROM AllPositions
    INSERT INTO AllPositions(PositionID, PositionName, UnitPrice, LastActive, CategoryName)
    VALUES (@PositionID, @PositionName, @UnitPrice, YEAR(1), @CategoryName)
    INSERT INTO PriceHistory(PositionID, UnitPrice, StartDate, EndDate)
    VALUES (@PositionID, @UnitPrice, GETDATE(), null)
GO
/****** Object:  StoredProcedure [dbo].[AddPositionToMenu]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddPositionToMenu]
    @PositionID int,
    @ForceAdd bit
AS
    IF @PositionID NOT IN (SELECT PositionID FROM AllPositions WHERE LastActive IS NOT NULL)
        RAISERROR(N'Pozycja nie istnieje lub jest już aktywna',16,1)

    IF @ForceAdd = 1 OR (DATEDIFF(DAY, (SELECT MIN(LastActive) FROM AllPositions WHERE PositionID = @PositionID), GETDATE()) < 14)
        RAISERROR(N'Pozycja powtórzy się, nie minęły jeszcze 2 tygodnie',16,1)

    UPDATE AllPositions SET LastActive = NULL WHERE PositionID = @PositionID
GO
/****** Object:  StoredProcedure [dbo].[ChangePrice]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ChangePrice]
    @PositionID int,
    @UnitPrice int
AS
    SET NOCOUNT ON
    IF NOT EXISTS(SELECT * FROM AllPositions WHERE PositionID = @PositionID)
        RAISERROR(N'Taka pozycja nie istnieje', 16, 1)
    UPDATE AllPositions
    SET UnitPrice = @UnitPrice
    WHERE PositionID = @PositionID
    UPDATE PriceHistory
    SET EndDate = GETDATE()
    WHERE PositionID = @PositionID AND EndDate IS NULL
    INSERT INTO PriceHistory(PositionID, UnitPrice, StartDate, EndDate)
    VALUES (@PositionID, @UnitPrice, DATEADD(day, 1, GETDATE()), null)
GO
/****** Object:  StoredProcedure [dbo].[ChangeVariables]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ChangeVariables]
    @Z1 int,
    @K1 int,
    @R1 float,
    @K2 int,
    @D1 int,
    @R2 float
AS
    SET NOCOUNT ON
    SELECT @Z1 = ISNULL(@Z1, Z1), @K1 = ISNULL(@K1, K1), @R1 = ISNULL(@R1, R1), @K2 = ISNULL(@K2, K2), @D1 = ISNULL(@D1, D1), @R2 = ISNULL(@R2, R2) FROM Variables
    UPDATE Variables
    SET Z1 = @Z1, K1 = @K1, R1 = @R1, K2 = @K2, D1 = @D1, R2 = @R2
    UPDATE VarHistory
    SET EndDate = GETDATE()
    WHERE EndDate IS NULL
    INSERT INTO VarHistory(StartDate, EndDate, Z1, K1, R1, K2, D1, R2)
    VALUES (DATEADD(day, 1, GETDATE()), null, @Z1, @K1, @R1, @K2, @D1, @R2)
GO
/****** Object:  StoredProcedure [dbo].[DeletePositionFromMenu]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePositionFromMenu]
    @PositionID int
AS
    IF @PositionID NOT IN (SELECT PositionID FROM AllPositions WHERE LastActive IS NULL)
        RAISERROR(N'Pozycja nie istnieje lub nie ma jej w menu',16,1)

    UPDATE AllPositions SET LastActive = GETDATE() WHERE PositionID = @PositionID
GO
/****** Object:  StoredProcedure [dbo].[SwapOldestPosition]    Script Date: 13.01.2023 15:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SwapOldestPosition]
    @Category_name varchar(255)
AS
    IF NOT (@Category_name = 'Danie glowne' or @Category_name = 'Owoce morza' or @Category_name = 'Deser' or @Category_name = 'Zupa')
        RAISERROR(N'Podana kategoria nie istnieje',16,1)

    IF (DATEDIFF(DAY,(SELECT MIN(LastActive) FROM AllPositions WHERE CategoryName = @Category_name),GETDATE()) < 14 OR DATEDIFF(DAY,(SELECT MIN(ActiveSince) FROM Menu WHERE Category = @Category_name),GETDATE()) < 14)
        RAISERROR(N'Pozycja powtórzy się, nie minęły jeszcze 2 tygodnie',16,1)

    UPDATE AllPositions SET LastActive = NULL WHERE AllPositions.PositionID IN (SELECT TOP 1 a.PositionID FROM AllPositions a WHERE a.CategoryName = @Category_name AND a.LastActive IS NOT NULL ORDER BY a.LastActive)

    UPDATE AllPositions SET LastActive = GETDATE() WHERE AllPositions.PositionID IN (SELECT TOP 1 PositionID FROM Menu WHERE CategoryName = @Category_name ORDER BY ActiveSince)
GO
