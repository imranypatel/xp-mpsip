IF OBJECT_ID('dbo.OpportunityKind', 'U') IS NULL
CREATE TABLE dbo.OpportunityKind (
    Id   INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50)  NOT NULL UNIQUE,
    Name NVARCHAR(100) NOT NULL
);

