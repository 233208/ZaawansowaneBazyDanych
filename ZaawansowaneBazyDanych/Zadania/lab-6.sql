-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

CREATE OR ALTER PROCEDURE [233208].usp_InsertCustomer
    @FirstName dbo.Name,               
    @LastName M8_surname.Surname,     
    @EmailAddress NVARCHAR(50),
    @Phone dbo.Phone,             
    @CompanyName NVARCHAR(128),
    @PasswordHash VARCHAR(128),
    @PasswordSalt VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [233208].Customer (FirstName, LastName, EmailAddress, Phone, CompanyName, PasswordHash, PasswordSalt, rowguid, ModifiedDate)
    VALUES (@FirstName, @LastName, @EmailAddress, @Phone, @CompanyName, @PasswordHash, @PasswordSalt, NEWID(), GETDATE());
END;
GO

-- =============================================
-- Zadanie 2
-- =============================================

CREATE OR ALTER PROCEDURE [233208].usp_GetCustomers
    @FirstName dbo.Name = NULL,
    @LastName M8_surname.Surname = NULL,
    @CustomerID INT = NULL,
    @EmailAddress NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CustomerID, FirstName, LastName, EmailAddress, CompanyName FROM [233208].Customer
    WHERE 
        (@CustomerID IS NULL OR CustomerID = @CustomerID)
        AND (@FirstName IS NULL OR FirstName = @FirstName)
        AND (@LastName IS NULL OR LastName = @LastName)
        AND (@EmailAddress IS NULL OR EmailAddress = @EmailAddress);
END;
GO

-- =============================================
-- Zadanie 3
-- =============================================

-- Zadanie jest niemożliwe do wykonania ponieważ:
-- 1. Zgodnie z dokumentacją T-SQL parametry typu tabelarycznego muszą być oznaczone jako READONLY.
-- 2. Nie można przekazać zmiennej tabelarycznej jako parametru OUTPUT (do zapisu).
-- 3. Procedura nie może modyfikować danych w tabeli wejściowej - wyniki tabelaryczne zwraca się poprzez SELECT.

-- =============================================
-- Zadanie 4
-- =============================================

CREATE OR ALTER FUNCTION dbo.ufn_CustomerExists
(
    @EmailAddress NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    IF EXISTS (SELECT 1 FROM [233208].Customer WHERE EmailAddress = @EmailAddress)
    BEGIN
        SET @Exists = 1;
    END
    RETURN @Exists;
END;
GO

CREATE OR ALTER PROCEDURE [233208].usp_InsertCustomer
    @FirstName dbo.Name,
    @LastName M8_surname.Surname,
    @EmailAddress NVARCHAR(50),
    @Phone dbo.Phone,
    @CompanyName NVARCHAR(128),
    @PasswordHash VARCHAR(128),
    @PasswordSalt VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF dbo.ufn_CustomerExists(@EmailAddress) = 1
    BEGIN
        THROW 50001, 'Użytkownik o podanym adresie Email już istnieje.', 1;
    END

    INSERT INTO [233208].Customer (FirstName, LastName, EmailAddress, Phone, CompanyName, PasswordHash, PasswordSalt, rowguid, ModifiedDate)
    VALUES (@FirstName, @LastName, @EmailAddress, @Phone, @CompanyName, @PasswordHash, @PasswordSalt, NEWID(), GETDATE());
END;
GO

-- =============================================
-- Zadanie 5
-- =============================================

CREATE OR ALTER PROCEDURE [233208].usp_UpdateCustomer
    @CustomerID INT,
    @FirstName dbo.Name,
    @LastName M8_surname.Surname
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [233208].Customer WHERE CustomerID = @CustomerID)
    BEGIN
        THROW 50002, 'Błąd: Rekord o podanym ID nie istnieje.', 1;
    END

    UPDATE [233208].Customer
    SET 
        FirstName = @FirstName,
        LastName = @LastName,
        ModifiedDate = GETDATE()
    WHERE CustomerID = @CustomerID;
END;
GO

-- =============================================
-- Zadanie 6
-- =============================================

-- WYJAŚNIENIE:
-- Nie zrobiłem części z ProductInventory, poniważ w bazie nie ma takiej tabeli.
-- Sprawdziłem też tabelę Product i tam nie ma kolumny na ilość, więc nie ma gdzie zapisać tej informacji.
-- Wykonuję zadanie w zakresie tabeli `SalesLT.Product` i transakcji. 
-- Część dotycząca `ProductInventory`jest niemożliwa do napisania bez "wymyślania" struktury tabeli.

CREATE OR ALTER PROCEDURE SalesLT.AddNewProduct
    @Name nvarchar(50),
    @Category int,
    @Price money,
    @Number nvarchar(25), 
    @Cost money 
AS
BEGIN
    IF @Price <= 0
    BEGIN
        PRINT 'Cena musi być większa niż 0'
        RETURN 
    END

    BEGIN TRAN

    BEGIN TRY
        INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
        VALUES (@Name, @Number, @Cost, @Price, @Category, GETDATE())

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN
        PRINT 'Błąd: Coś poszło nie tak'
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- Zadanie 7
-- =============================================

-- WYJAŚNIENIE:
-- Nie używam zmiennej @Summary, ponieważ zmienne są widoczne tylko w batchu, w którym powstały.
-- Procedura ich nie widzi, więc nie da się do nich nic wpisać.
-- Zamiast tego po prostu wyświetlam wynik obliczeń.

IF OBJECT_ID('tempdb..#TopProducts') IS NOT NULL DROP TABLE #TopProducts;

CREATE TABLE #TopProducts (
    ProductID int,
    Name nvarchar(50),
    ListPrice money
);

INSERT INTO #TopProducts (ProductID, Name, ListPrice)
SELECT TOP 25 
    p.ProductID,
    p.Name,
    p.ListPrice
FROM SalesLT.SalesOrderDetail sod
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name, p.ListPrice
ORDER BY COUNT(*) DESC;
GO

CREATE OR ALTER PROCEDURE Student_8.usp_ProcessTopProducts
AS
BEGIN
    SELECT ProductID,Name,ListPrice,ListPrice - (ListPrice * 0.08) AS ModifiedPrice
    FROM #TopProducts
END
GO

EXEC Student_8.usp_ProcessTopProducts;
GO