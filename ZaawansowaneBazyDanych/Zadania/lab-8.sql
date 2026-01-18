-- =============================================
-- Mateusz
-- Wójcik
-- 233208
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

SELECT DISTINCT
    pc.Name AS CategoryName,
    MIN(p.ListPrice) OVER (PARTITION BY pc.ProductCategoryID) AS MinPrice,
    MAX(p.ListPrice) OVER (PARTITION BY pc.ProductCategoryID) AS MaxPrice,
    COUNT(p.ProductID) OVER (PARTITION BY pc.ProductCategoryID) AS ProductCount
FROM SalesLT.Product p
JOIN SalesLT.ProductCategory pc 
    ON p.ProductCategoryID = pc.ProductCategoryID;
GO

-- =============================================
-- Tabela do zadań 2, 3, 4
-- =============================================

IF OBJECT_ID('[233208].Games', 'U') IS NOT NULL DROP TABLE [233208].Games;

CREATE TABLE [233208].Games (
    GameID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100),
    Genre NVARCHAR(50),      
    Status NVARCHAR(20),     
    PlayTimeHours INT,       
    Rating INT               
);

INSERT INTO [233208].Games (Title, Genre, Status, PlayTimeHours, Rating) VALUES
-- RPG
('The Witcher 3', 'RPG', 'Completed', 120, 10),
('Cyberpunk 2077', 'RPG', 'Completed', 75, 9),
('Baldurs Gate 3', 'RPG', 'Playing', 45, NULL),
('Skyrim', 'RPG', 'Completed', 200, 8),
('Mass Effect LE', 'RPG', 'Backlog', 0, NULL),
('Fallout: New Vegas', 'RPG', 'Completed', 85, 9),
('Disco Elysium', 'RPG', 'Backlog', 0, NULL),
('Dark Souls 3', 'RPG', 'Completed', 60, 9),
('Elden Ring', 'RPG', 'Playing', 110, NULL),
('Diablo IV', 'RPG', 'Abandoned', 40, NULL),

-- Strat
('Civilization VI', 'Strategy', 'Playing', 350, NULL),
('StarCraft II', 'Strategy', 'Completed', 60, 9),
('Total War: Warhammer III', 'Strategy', 'Backlog', 0, NULL),
('Factorio', 'Strategy', 'Playing', 500, NULL),
('Age of Empires II: DE', 'Strategy', 'Playing', 420, NULL),
('XCOM 2', 'Strategy', 'Abandoned', 15, NULL), 
('Stellaris', 'Strategy', 'Playing', 150, NULL),
('Heroes III', 'Strategy', 'Completed', 999, 10),

-- FPS
('Doom Eternal', 'FPS', 'Completed', 15, 9),
('Call of Duty: MW2', 'FPS', 'Abandoned', 5, NULL),
('Half-Life 2', 'FPS', 'Completed', 12, 10),
('Counter-Strike 2', 'FPS', 'Playing', 1986, NULL),
('BioShock', 'FPS', 'Completed', 12, 10),
('Valorant', 'FPS', 'Playing', 600, NULL),
('Apex Legends', 'FPS', 'Abandoned', 200, NULL),
('Overwatch 2', 'FPS', 'Playing', 50, NULL),
('Portal 2', 'FPS', 'Completed', 8, 10),

-- Indie
('Hades', 'Indie', 'Completed', 40, 9),
('Hollow Knight', 'Indie', 'Abandoned', 10, NULL),
('Stardew Valley', 'Indie', 'Playing', 80, NULL),
('Terraria', 'Indie', 'Backlog', 0, NULL),
('Celeste', 'Indie', 'Completed', 12, 9),
('Vampire Survivors', 'Indie', 'Completed', 30, 8),
('Slay the Spire', 'Indie', 'Playing', 250, NULL),
('Cuphead', 'Indie', 'Abandoned', 4, NULL),
('Among Us', 'Indie', 'Abandoned', 25, NULL),

-- Sim
('SimCity 4', 'Sim', 'Completed', 50, 8),
('Cities: Skylines', 'Sim', 'Backlog', 0, NULL),
('Microsoft Flight Simulator', 'Sim', 'Backlog', 0, NULL),
('Forza Horizon 5', 'Sim', 'Completed', 60, 9),
('Euro Truck Simulator 2', 'Sim', 'Playing', 200, NULL);
GO

-- =============================================
-- Zadanie 2
-- =============================================
-- Tworzę ranking gier, wg czasu gry (PlayTimeHours) w danym gatunku 
-- oraz obliczam udział procentowy czasu poświęconego na grę w jej gatunku. 

SELECT 
    Title,
    Genre,
    PlayTimeHours,
    ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY PlayTimeHours DESC) AS RankInGenre,
    SUM(PlayTimeHours) OVER (PARTITION BY Genre) AS TotalGenreTime,
    CAST(1.0 * PlayTimeHours / SUM(PlayTimeHours) OVER (PARTITION BY Genre) * 100 AS DECIMAL(5,2)) AS PercentShare
FROM [233208].Games
WHERE PlayTimeHours > 0
ORDER BY Genre, PlayTimeHours DESC;
GO

-- =============================================
-- Zadanie 3
-- =============================================
-- Sprawdzam wszystkie stany gier i ile gier jest w jakim stanie (Status) 
-- w poszczególnej kategorii.

IF OBJECT_ID('tempdb..#pivotGames') IS NOT NULL DROP TABLE #pivotGames;

-- PIVOT

SELECT Genre, [Backlog], [Playing], [Completed], [Abandoned]
INTO #pivotGames 
FROM (
    SELECT Genre, Status, GameID
    FROM [233208].Games
) AS Source
PIVOT (
    COUNT(GameID)
    FOR Status IN ([Backlog], [Playing], [Completed], [Abandoned])
) AS pvt;

SELECT * FROM #pivotGames ;

-- UNPIVOT

SELECT Genre, Status, GameCount
FROM #pivotGames 
UNPIVOT (
    GameCount
    FOR Status IN ([Backlog], [Playing], [Completed], [Abandoned])
) AS unpvt
WHERE GameCount > 0; 
GO

-- =============================================
-- Zadanie 4
-- =============================================
-- Liczę sumę godzin i gier dla par Genre-Statu.

SELECT 
    ISNULL(Genre, '--- ALL GENRES ---') AS Genre,
    ISNULL(Status, '--- TOTAL ---') AS Status,
    SUM(PlayTimeHours) AS TotalHours,
    COUNT(GameID) AS GamesCount
FROM [233208].Games
GROUP BY ROLLUP (Genre, Status);
GO

