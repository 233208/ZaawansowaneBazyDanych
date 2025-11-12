-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

-- https://github.com/233208/ZaawansowaneBazyDanych

-- =============================================
-- Zadanie 2
-- =============================================

ALTER TABLE [233208].[Customer]
ADD
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
        CONSTRAINT DF_Customer_SysStartTime DEFAULT SYSUTCDATETIME(),
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
        CONSTRAINT DF_Customer_SysEndTime DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
GO

ALTER TABLE [233208].[Customer]
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [233208].[CustomerHistory]));
GO

-- =============================================
-- Zadanie 3
-- =============================================
UPDATE [233208].[Customer] SET Phone = '111-222-333' WHERE CustomerID = 1;
GO
UPDATE [233208].[Customer] SET EmailAddress = 'zadanie3@email.com' WHERE CustomerID = 1;
GO
UPDATE [233208].[Customer] SET CompanyName = 'Zadanie Inc.' WHERE CustomerID = 1;
GO
UPDATE [233208].[Customer] SET Phone = '999-888-777' WHERE CustomerID = 2;
UPDATE [233208].[Customer] SET Phone = '999-888-776' WHERE CustomerID = 3;
UPDATE [233208].[Customer] SET Phone = '999-888-775' WHERE CustomerID = 4;
UPDATE [233208].[Customer] SET EmailAddress = 'update5.email@example.com' WHERE CustomerID = 5;
UPDATE [233208].[Customer] SET EmailAddress = 'update6.email@example.com' WHERE CustomerID = 6;
UPDATE [233208].[Customer] SET LastName = 'Nowak' WHERE CustomerID = 7;
UPDATE [233208].[Customer] SET LastName = 'Kowal' WHERE CustomerID = 8;
UPDATE [233208].[Customer] SET CompanyName = 'Nowa Firma 9' WHERE CustomerID = 9;
UPDATE [233208].[Customer] SET CompanyName = 'Nowa Firma 10' WHERE CustomerID = 10;
GO

INSERT INTO [233208].[Customer] (FirstName, LastName, EmailAddress, PasswordHash, PasswordSalt)
VALUES
('Monika', 'Mazurek', 'monika.m@example.com', 'HASH123', 'SALT1'),
('Marek', 'Marucha', 'marek.m@example.com', 'HASH456', 'SALT2'),
('Maciej', 'Mickiewicz', 'maciej.m@example.com', 'HASH789', 'SALT3'),
('Magda', 'Malina', 'magda.m@example.com', 'HASH101', 'SALT4'),
('Mariusz', 'Mrowka', 'mariusz.m@example.com', 'HASH112', 'SALT5');
GO
-- =============================================
-- Zadanie 4
-- =============================================

SELECT CustomerID, FirstName, LastName, EmailAddress, Phone, CompanyName, SysStartTime, SysEndTime
FROM [233208].[Customer]
FOR SYSTEM_TIME ALL WHERE CustomerID = 1
ORDER BY SysEndTime DESC;
GO

-- =============================================
-- Zadanie 5
-- =============================================

DECLARE @MomentPoModyfikacjach DATETIME2; SELECT @MomentPoModyfikacjach = MAX(SysStartTime)
FROM [233208].[Customer]
WHERE CustomerID IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

SELECT CustomerID, FirstName, LastName, EmailAddress, Phone, CompanyName, SysStartTime, SysEndTime
FROM [233208].[Customer]
FOR SYSTEM_TIME AS OF @MomentPoModyfikacjach;
GO

-- =============================================
-- Zadanie 6
-- =============================================

CREATE XML SCHEMA COLLECTION ProductAttributeSchema AS N'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Attributes">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Weight" type="xs:decimal" minOccurs="0" />
        <xs:element name="Color" type="xs:string" minOccurs="0" />
        <xs:element name="Material" type="xs:string" minOccurs="0" />
        <xs:element name="WarrantyYears" type="xs:int" minOccurs="0" />
        <xs:element name="CountryOfOrigin" type="xs:string" minOccurs="0" />
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';
GO

CREATE TABLE [SalesLT].[ProductAttribute] (
ProductAttributeID INT IDENTITY(1,1) PRIMARY KEY,
ProductID INT NOT NULL,
    
Attributes XML(ProductAttributeSchema) NULL, 
CONSTRAINT FK_ProductAttribute_Product FOREIGN KEY (ProductID)
REFERENCES [SalesLT].[Product] (ProductID)
ON DELETE CASCADE 
);
GO

-- =============================================
-- Zadanie 7
-- =============================================

INSERT INTO [SalesLT].[ProductAttribute] (ProductID, Attributes)
VALUES
(
    707, 
    N'<Attributes>
        <Weight>2.5</Weight>
        <Color>Midnight Black</Color>
        <Material>High-Modulus Carbon</Material>
        <WarrantyYears>10</WarrantyYears>
        <CountryOfOrigin>Taiwan</CountryOfOrigin>
    </Attributes>'
),
(
    870, 
    N'<Attributes>
        <Weight>12.8</Weight>
        <Color>Matte Black</Color>
        <Material>6061 Aluminum</Material>
        <WarrantyYears>5</WarrantyYears>
        <CountryOfOrigin>USA</CountryOfOrigin>
    </Attributes>'
),
(
    994,
    N'<Attributes>
        <Weight>0.25</Weight>
        <Material>Chromoly Steel</Material>
        <WarrantyYears>2</WarrantyYears>
        <CountryOfOrigin>Germany</CountryOfOrigin>
    </Attributes>'
),
(
    995, 
    N'<Attributes>
        <Weight>0.22</Weight>
        <Material>Titanium Alloy</Material>
        <WarrantyYears>3</WarrantyYears>
        <CountryOfOrigin>Japan</CountryOfOrigin>
    </Attributes>'
),
(
    996, 
    N'<Attributes>
        <Weight>0.18</Weight>
        <Color>Gold Anodized</Color>
        <Material>Ceramic/Titanium</Material>
        <WarrantyYears>7</WarrantyYears>
        <CountryOfOrigin>Switzerland</CountryOfOrigin>
    </Attributes>'
);
GO

-- =============================================
-- Zadanie 8
-- =============================================

UPDATE [SalesLT].[ProductAttribute]
SET Attributes.modify
('
    replace value of (/Attributes/Material/text())[1]
    with "Materiał (zaczyna się na M)"
')
WHERE Attributes.exist('/Attributes/Material') = 1;
GO

UPDATE [SalesLT].[ProductAttribute]
SET Attributes.modify
('
    replace value of (/Attributes/CountryOfOrigin/text())[1]
    with "Malezja (Miejsce na M)"
')
WHERE Attributes.exist('/Attributes/CountryOfOrigin') = 1;
GO

UPDATE [SalesLT].[ProductAttribute]
SET Attributes.modify
('
    replace value of (/Attributes/Color/text())[1]
    with "Matowy (Kolor na M)"
')
WHERE Attributes.exist('/Attributes/Color') = 1;
GO

-- =============================================
-- Zadanie 9
-- =============================================

DECLARE @JsonData NVARCHAR(MAX) = N'{
    "info": {
        "autor": "Mateusz Wójcik",
        "indeks": 123456,
        "status": "Oczekujący"
    },
    "dataZadania": "2025-11-12"
}';

PRINT '--- JSON przed modyfikacją ---';
SELECT @JsonData AS JsonPrzed;

SET @JsonData = JSON_MODIFY(
    @JsonData,            
    '$.info.indeks',       
    233208                
);

PRINT '--- JSON po modyfikacji ---';
SELECT @JsonData AS ZmodyfikowanyJson;
GO