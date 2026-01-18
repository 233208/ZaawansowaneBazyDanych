-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

CREATE TABLE SalesLT.ProductPriceHistory (
    ID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    OldPrice DECIMAL(18,2),
    NewPrice DECIMAL(18,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

CREATE OR ALTER TRIGGER SalesLT.trg_PriceChange
ON SalesLT.Product
AFTER UPDATE 
AS
BEGIN
    INSERT INTO SalesLT.ProductPriceHistory (ProductID, OldPrice, NewPrice)
    SELECT i.ProductID, d.ListPrice, i.ListPrice
    FROM inserted i
    JOIN deleted d ON i.ProductID = d.ProductID
    WHERE i.ListPrice <> d.ListPrice;
END;
GO

-- =============================================
-- Zadanie 2
-- =============================================

ALTER TABLE [233208].Customer SET (SYSTEM_VERSIONING = OFF);
GO

IF OBJECT_ID('[233208].DeletedCustomersLog', 'U') IS NULL
BEGIN
    CREATE TABLE [233208].DeletedCustomersLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT,
        FirstName NVARCHAR(50),
        LastName NVARCHAR(50),
        LogDate DATETIME DEFAULT GETDATE(),
        Reason NVARCHAR(100)
    );
END
GO

CREATE OR ALTER TRIGGER [233208].trg_CustomerDeleteControl
ON [233208].Customer
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [233208].DeletedCustomersLog (CustomerID, FirstName, LastName, Reason)
    SELECT d.CustomerID, d.FirstName, d.LastName, 'Klient posiada zamówienia'
    FROM deleted d
    WHERE EXISTS (SELECT 1 FROM [233208].SalesOrderHeader h WHERE h.CustomerID = d.CustomerID);

    DELETE c
    FROM [233208].Customer c
    JOIN deleted d ON c.CustomerID = d.CustomerID
    WHERE NOT EXISTS (SELECT 1 FROM [233208].SalesOrderHeader h WHERE h.CustomerID = d.CustomerID);
END;
GO
         
-- =============================================
-- Zadanie 3
-- =============================================

WITH CategoryPath_CTE (ProductCategoryID, Name, fPath) AS
(
    SELECT ProductCategoryID, Name, CAST(Name AS NVARCHAR(MAX)) FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID IS NULL

    UNION ALL

    SELECT 
        c.ProductCategoryID, 
        c.Name, 
        CAST(p.fPath + ' -> ' + c.Name AS NVARCHAR(MAX))
    FROM SalesLT.ProductCategory c
    INNER JOIN CategoryPath_CTE p ON c.ParentProductCategoryID = p.ProductCategoryID
)
SELECT fPath
FROM CategoryPath_CTE
ORDER BY fPath;
GO

-- =============================================
-- Zadanie 4
-- =============================================

-- Trigger działa w tej samej transakcji.
-- Jeśli trigger zakończy się niepowodzeniem to cała operacja jest rollbackowana.
-- W transakcji Rollback wycofa również wpis do loga.

-- =============================================
-- Zadanie 5
-- =============================================

-- =============================================
-- Zadanie 6
-- =============================================

CREATE TABLE dbo.CompanyEmployees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    ManagerID INT NULL
);

INSERT INTO dbo.CompanyEmployees VALUES (1, 'CEO', NULL);
INSERT INTO dbo.CompanyEmployees VALUES (2, 'IT Director', 1);
INSERT INTO dbo.CompanyEmployees VALUES (3, 'Developer', 2);
WITH EmployeeHierarchy AS
(
    SELECT EmployeeID, FirstName, ManagerID, 1 AS Level
    FROM dbo.CompanyEmployees
    WHERE ManagerID IS NULL

    UNION ALL

    SELECT e.EmployeeID, e.FirstName, e.ManagerID, h.Level + 1
    FROM dbo.CompanyEmployees e
    JOIN EmployeeHierarchy h ON e.ManagerID = h.EmployeeID
)
SELECT * FROM EmployeeHierarchy;
GO  