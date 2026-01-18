-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================
-- Dostarczony skrypt ProductBOM.sql tworzy tabele powiązane relacjami, ale nie definiuje dla nich indeksów.
-- Brak indeksów na kolumnach używanych w złączeniach (JOIN) zmusi serwer do pełnego skanowania tabel (Table Scan).
-- Tworzę indeksy nieklastrowe na kolumnach relacyjnych we wszystkich nowo utworzonych tabelach.

CREATE NONCLUSTERED INDEX IX_ProductBOM_ParentProductID
ON SalesLT.ProductBOM (ParentProductID);
GO

CREATE NONCLUSTERED INDEX IX_ProductBOM_ComponentProductID
ON SalesLT.ProductBOM (ComponentProductID);
GO

CREATE NONCLUSTERED INDEX IX_ProductVendor_VendorID
ON SalesLT.ProductVendor (VendorID);
GO

CREATE NONCLUSTERED INDEX IX_VendorPriceHistory_VendorID
ON SalesLT.VendorPriceHistory (VendorID);
GO

CREATE NONCLUSTERED INDEX IX_VendorPriceHistory_ProductID
ON SalesLT.VendorPriceHistory (ProductID);
GO

CREATE NONCLUSTERED INDEX IX_ShipmentTrackingEvents_SalesOrderID
ON SalesLT.ShipmentTrackingEvents (SalesOrderID);
GO

-- =============================================
-- Zadanie 2
-- =============================================
-- Aby przyspieszyć pobieranie kolumn [Name], [AccountNumber] dla aktywnych dostawców,
-- stosuję indeks nieklastrowy z klauzulą INCLUDE.

CREATE NONCLUSTERED INDEX IX_Vendor_Active_Includes
ON SalesLT.Vendor (ActiveFlag)
INCLUDE (Name, AccountNumber)
WHERE ActiveFlag = 1;
GO

-- =============================================
-- Zadanie 3
-- =============================================
-- Tabele ProductVendor, VendorPriceHistory oraz ShipmentTrackingEvents
-- nie posiadają klucza głownego, więc są stertami.
-- Tworzę indeksy klastrowe, które fizycznie uporządkują dane.
-- UWAGA: Kolumny 'ID' w tych tabelach (np. QuoteID) są puste (NULL), dlatego tworze indeksy na kolumnach logicznych, które zawierają dane.


CREATE CLUSTERED INDEX CIX_ProductVendor_ProductID_VendorID
ON SalesLT.ProductVendor (ProductID, VendorID);
GO

CREATE CLUSTERED INDEX CIX_VendorPriceHistory_VendorID_QuoteDate
ON SalesLT.VendorPriceHistory (VendorID, QuoteDate);
GO

CREATE CLUSTERED INDEX CIX_ShipmentTrackingEvents_SalesOrderID_EventDate
ON SalesLT.ShipmentTrackingEvents (SalesOrderID, EventDate);
GO

SELECT TOP 10 * FROM SalesLT.VendorPriceHistory
ORDER BY VendorID, QuoteDate DESC;
GO

-- =============================================
-- Zadanie 4
-- =============================================
-- Parametr FILLFACTOR określa procent zapełnienia strony danymi.
-- Zadanie wymaga określenia wolnego miejsca, 
-- wiec ustawiam FILLFACTOR = 25.


ALTER INDEX CIX_VendorPriceHistory_VendorID_QuoteDate
ON SalesLT.VendorPriceHistory
REBUILD WITH (FILLFACTOR = 25);
GO 

-- =============================================
-- Zadanie 5
-- =============================================
-- Tworzę tabelę 'VendorReviews', powiązaną z tabelami Vendor i Product.
-- Tabela zawiera:
-- 1. Klucz główny (automatycznie tworzy indeks klastrowy).
-- 2. Indeks filtrowany (tylko zatwierdzone opinie).
-- 3. Indeks pokrywający (dla raportowania ocen produktów).


IF OBJECT_ID('[233208].VendorReviews', 'U') IS NOT NULL
    DROP TABLE [233208].VendorReviews;
GO

CREATE TABLE [233208].VendorReviews (
    ReviewID INT IDENTITY(1,1) NOT NULL,
    VendorID INT NOT NULL,
    ProductID INT NOT NULL,
    Rating TINYINT CHECK (Rating BETWEEN 1 AND 5),
    ReviewText NVARCHAR(500),
    ReviewDate DATETIME DEFAULT GETDATE(),
    IsApproved BIT DEFAULT 0,

    CONSTRAINT PK_VendorReviews PRIMARY KEY CLUSTERED (ReviewID),

    CONSTRAINT FK_VendorReviews_Vendor FOREIGN KEY (VendorID) REFERENCES SalesLT.Vendor(VendorID),
    CONSTRAINT FK_VendorReviews_Product FOREIGN KEY (ProductID) REFERENCES SalesLT.Product(ProductID)
);
GO

CREATE NONCLUSTERED INDEX IX_VendorReviews_Approved
ON [233208].VendorReviews (VendorID)
WHERE IsApproved = 1;
GO

CREATE NONCLUSTERED INDEX IX_VendorReviews_ProductRating
ON [233208].VendorReviews (ProductID)
INCLUDE (Rating, ReviewDate);
GO

SELECT name, type_desc, has_filter FROM sys.indexes WHERE object_id = OBJECT_ID('[233208].VendorReviews');
GO