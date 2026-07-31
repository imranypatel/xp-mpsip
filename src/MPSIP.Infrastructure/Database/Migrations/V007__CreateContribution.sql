IF OBJECT_ID('dbo.Contribution', 'U') IS NULL
CREATE TABLE dbo.Contribution (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId        INT            NOT NULL REFERENCES dbo.Project(Id),
    ProjectTaskId    INT            NULL     REFERENCES dbo.ProjectTask(Id),
    ContributorId    INT            NOT NULL REFERENCES dbo.AppUser(Id),
    ResourceType     NVARCHAR(20)   NOT NULL CHECK (ResourceType IN ('Man','Material','Money')),
    Description      NVARCHAR(500)  NOT NULL,
    Quantity         DECIMAL(18,4)  NOT NULL,
    Unit             NVARCHAR(50)   NULL,
    MonetaryValue    DECIMAL(18,2)  NULL,
    ContributionDate DATE           NOT NULL,
    IsDeleted        BIT            NOT NULL DEFAULT 0,
    CreatedAt        DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy        INT            NOT NULL
);

