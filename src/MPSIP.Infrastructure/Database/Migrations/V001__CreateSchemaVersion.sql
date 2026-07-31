IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NULL
CREATE TABLE dbo.SchemaVersion (
    Version     INT           NOT NULL PRIMARY KEY,
    Description NVARCHAR(200) NOT NULL,
    AppliedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);

