-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

DECLARE @ProductInfo NVARCHAR(MAX) = N'[
    {"ProductID": 680, "NewPrice": 6700.42},
    {"ProductID": 706, "NewPrice": 4200.97},
    {"ProductID": 707, "NewPrice": 15.99},
    {"ProductID": 850, "NewPrice": 42.99},
    {"ProductID": 999, "NewPrice": 12.75}
]';

-- Utworzenie widoku, który odwołuje się do zmiennej lokalnej jest niemożliwe.
-- Widok jest trwałym obiektem bazy danych, więc nie może opierać się na zmiennej lokalnej, która znika natychmiast po wykonaniu skryptu.
-- Zmienne lokalne istnieją tylko w ramach sesji.

-- =============================================
-- Zadanie 2
-- =============================================

CREATE VIEW Student_8.TheBestCustomers AS
SELECT TOP 10
    c.CustomerID,
    c.CompanyName,
    c.FirstName,
    c.LastName,
    SUM(soh.TotalDue) AS TotalSpent
FROM [233208].Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.CompanyName, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;
GO

SELECT * FROM Student_8.TheBestCustomers;
GO

-- Najelpszy klient jest wybierany na podstawie sumy należności za zamówienia

-- =============================================
-- Zadanie 3
-- =============================================

CREATE FUNCTION Student_8.ufn_ProductsJsonByCategory 
(
    @CategoryName NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT p.ProductID, p.Name, p.ListPrice, p.Color, p.Size FROM SalesLT.Product AS p
        JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
        WHERE pc.Name = @CategoryName
        FOR JSON AUTO
    );
END;
GO

SELECT Student_8.ufn_ProductsJsonByCategory('Bikes');
GO

-- =============================================
-- Zadanie 4
-- =============================================

CREATE FUNCTION Student_8.ufn_IsPriceHigherThanCurrent
(
    @ProductData NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    DECLARE @CurrentPrice DECIMAL(10,2);
    
    SELECT @CurrentPrice = ListPrice FROM SalesLT.Product 
    WHERE ProductID = CAST(JSON_VALUE(@ProductData, '$.ProductID') AS INT);
    
    IF CAST(JSON_VALUE(@ProductData, '$.NewPrice') AS DECIMAL(10,2)) > @CurrentPrice
        RETURN 1;
        
    RETURN 0;
END;
GO

SELECT 
    Student_8.ufn_IsPriceHigherThanCurrent('{"ProductID": 680, "NewPrice": 99999.00}') AS [Return_True],
    Student_8.ufn_IsPriceHigherThanCurrent('{"ProductID": 680, "NewPrice": 0.00}') AS [Return_False];
GO

-- Jak zachowa się system gdy cena będzie równa?
-- Funkcja zwróci 0, ponieważ warunek w instrukcji IF (@JsonPrice > @CurrentPrice) nie zostanie spełniony.

-- =============================================
-- Zadanie 5
-- =============================================

CREATE FUNCTION Student_8.ufn_GetCheaperProducts
(
    @CheckPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ProductID, Name, ListPrice FROM SalesLT.Product
    WHERE Student_8.ufn_IsPriceHigherThanCurrent(
        (
            SELECT ProductID, @CheckPrice AS NewPrice FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    ) = 1
);
GO

SELECT * FROM Student_8.ufn_GetCheaperProducts(1000.00);
GO

-- ==========================================
-- Zadanie 6
-- ==========================================

-- Zadanie jest niemożliwe do wykonania ponieważ:
-- 1. Funkcja tabelaryczna nie ma dostępu do tabeli tymczasowej #TopProducts utworzonej w sesji zewnętrznej (ograniczony zakres widoczności).
-- 2. Zmienne są widoczne tylko w obrębie batcha, w którym zostały zadeklarowane. 
-- 3. Funkcja jest osobnym obiektem, więc nie widzi zewnętrznej zmiennej @Summary i nie może do niej wstawić wyników.