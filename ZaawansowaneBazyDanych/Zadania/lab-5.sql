-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

CREATE SCHEMA M8_surname AUTHORIZATION dbo;
GO
 
CREATE TYPE M8_surname.Surname FROM NVARCHAR(50) NOT NULL;
GO
 
ALTER TABLE [233208].Customer ALTER COLUMN LastName M8_surname.Surname;
GO

-- =============================================
-- Zadanie 2
-- =============================================

BEGIN TRAN;
    UPDATE SalesLT.Product
    SET ListPrice = ListPrice + 1 WHERE ProductID = 707; 

-- ODPOWIEDŹ:
-- Otwarta transakcja bez commit'a/rollback'a blokuje zasoby.
-- Inne operacje na tym wierszu/tabeli będą czekać w nieskończoność, co może prowadzić do deadlocków.

-- =============================================
-- Zadanie 3
-- =============================================

-- Tabla do testów
IF OBJECT_ID('SalesLT.TestTable', 'U') IS NOT NULL DROP TABLE SalesLT.TestTable;
CREATE TABLE SalesLT.TestTable (ID int identity, Name varchar(50));
INSERT INTO SalesLT.TestTable VALUES ('Test1'), ('Test2');

BEGIN TRAN;
    UPDATE TOP (10) SalesLT.Product
    SET ListPrice = ListPrice * 1.08; 

    INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name, rowguid, ModifiedDate)
    SELECT TOP 10 ParentProductCategoryID, Name + '_M8', NEWID(), GETDATE() FROM SalesLT.ProductCategory;

    UPDATE TOP (10) SalesLT.Customer
    SET CompanyName = CompanyName + '_M8';

    TRUNCATE TABLE SalesLT.TestTable;

    SELECT COUNT(*) as LiczbaWTestTable_Wewnatrz FROM SalesLT.TestTable;
    SELECT TOP 5 ListPrice as Cena_Wewnatrz FROM SalesLT.Product;

ROLLBACK;

SELECT COUNT(*) as LiczbaWTestTable_PoRollback FROM SalesLT.TestTable;
SELECT TOP 5 ListPrice as Cena_PoRollback FROM SalesLT.Product;

-- ODPOWIEDŹ:
-- Po rollback'u wszystkie zmiany zostały cofnięte. Tabela TestTable znowu zawiera dane, mimo użycia TRUNCATE.
-- TRUNCATE w SQL Server jest operacją transakcyjną i może zostać wycofany.

-- =============================================
-- Zadanie 4
-- =============================================

IF OBJECT_ID('SalesLT.TestTable', 'U') IS NOT NULL DROP TABLE SalesLT.TestTable;
CREATE TABLE SalesLT.TestTable (ID int identity, Name varchar(50));
INSERT INTO SalesLT.TestTable VALUES ('Test1'), ('Test2');

BEGIN TRAN;
    UPDATE TOP (10) SalesLT.Product
    SET ListPrice = ListPrice * 1.08; 

    INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name, rowguid, ModifiedDate)
    SELECT TOP 10 ParentProductCategoryID, Name + '_M8', NEWID(), GETDATE() FROM SalesLT.ProductCategory;

    UPDATE TOP (10) SalesLT.Customer
    SET CompanyName = CompanyName + '_M8';

    TRUNCATE TABLE SalesLT.TestTable;

    SELECT COUNT(*) as LiczbaWTestTable_Wewnatrz FROM SalesLT.TestTable;
    SELECT TOP 5 ListPrice as Cena_Wewnatrz FROM SalesLT.Product;

    WAITFOR DELAY '00:05:00'; 

ROLLBACK;

SELECT COUNT(*) as LiczbaWTestTable_PoRollback FROM SalesLT.TestTable;
SELECT TOP 5 ListPrice as Cena_PoRollback FROM SalesLT.Product;

-- Aby odczytać dane w innej sesji mimo trwającej tranzakcji, trzeba wpisać:

SELECT * FROM SalesLT.Product WITH (NOLOCK);

-- =============================================
-- Zadanie 5
-- =============================================

BEGIN TRY
    SELECT ProductID, ListPrice / 0 FROM SalesLT.Product WHERE ProductID = 707;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS NumerBledu,
        ERROR_MESSAGE() AS TrescBledu;
END CATCH;
GO

-- =============================================
-- Zadanie 6
-- =============================================
-- OPIS ZAŁOŻEŃ:
-- Użytkownik dodaje nową grę do swojej listy "do ogrania" (Backlog).
-- Operacje: 
--   1. Wstawienie nowego rekordu do tabeli Backlog.
-- Możliwe błędy:
--   1. Tytuł gry nie może być pusty.
--   2. Szacowany czas gry nie może być ujemny.
--   3. Status gry musi być jednym z predefiniowanych.

IF OBJECT_ID('dbo.Backlog', 'U') IS NULL
CREATE TABLE dbo.Backlog (
    GameID int IDENTITY(1,1) PRIMARY KEY,
    Title nvarchar(100) NOT NULL,
    TimeToBeat int DEFAULT 0,
    Status nvarchar(20) DEFAULT 'Planowana',
    DateAdded datetime DEFAULT GETDATE()
);
GO

DECLARE @GameTitle nvarchar(100) = 'Wiedźmin 3';
DECLARE @EstimatedHours int = 100; 
DECLARE @GameStatus nvarchar(20) = 'W trakcie';

BEGIN TRY
    IF @GameTitle IS NULL OR LEN(@GameTitle) = 0
    BEGIN
        THROW 50008, 'Błąd: Tytuł gry jest wymagany!', 1;
    END

    IF @EstimatedHours < 0
    BEGIN
        THROW 50008, 'Błąd: Czas gry (Time to Beat) nie może być ujemny!', 1;
    END

    IF @GameStatus NOT IN ('Planowana', 'W trakcie', 'Ukończona')
    BEGIN
        THROW 50008, 'Błąd: Niepoprawny status gry (dozwolone: Planowana, W trakcie, Ukończona)', 1;
    END

    INSERT INTO dbo.Backlog (Title, TimeToBeat, Status)
    VALUES (@GameTitle, @EstimatedHours, @GameStatus);

    PRINT 'Sukces: Gra została dodana do backlogu.';
END TRY
BEGIN CATCH
    PRINT 'Nie udało się dodać gry.';
    PRINT 'Szczegóły: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =============================================
-- Zadanie 7
-- =============================================
-- Dodanie transakcyjności: 
-- Dodajemy grę i aktualizujemy "Dziennik Aktywności" (symulowany tabelą TestTable).

IF OBJECT_ID('SalesLT.TestTable', 'U') IS NULL
CREATE TABLE SalesLT.TestTable (ID int identity, Name varchar(50));

-- Zmienne wejściowe
DECLARE @NewGameTitle nvarchar(100) = 'Cyberpunk 2077';
DECLARE @NewHours int = 60;
DECLARE @NewStatus nvarchar(20) = 'Planowana';

BEGIN TRY
    BEGIN TRAN; 
    IF @NewGameTitle IS NULL OR LEN(@NewGameTitle) = 0
    BEGIN
        THROW 50008, 'Błąd: Tytuł gry jest wymagany!', 1;
    END

    IF @NewHours < 0  
    BEGIN
        THROW 50008, 'Błąd: Szacowany czas gry nie może być ujemny!', 1;
    END

    IF @NewStatus NOT IN ('Planowana', 'W trakcie', 'Ukończona') 
    BEGIN
        THROW 50008, 'Błąd: Niepoprawny status gry (dozwolone: Planowana, W trakcie, Ukończona)', 1;
    END

    INSERT INTO dbo.Backlog (Title, TimeToBeat, Status)
    VALUES (@NewGameTitle, @NewHours, @NewStatus);

    INSERT INTO SalesLT.TestTable (Name)
    VALUES ('Dodano grę: ' + @NewGameTitle);

    COMMIT TRAN;
    PRINT 'Transakcja zakończona pomyślnie: Gra dodana i zdarzenie zalogowane.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRAN;
        PRINT 'Transakcja wycofana (ROLLBACK).';
    END
    PRINT 'Błąd krytyczny: ' + ERROR_MESSAGE();
END CATCH;
GO