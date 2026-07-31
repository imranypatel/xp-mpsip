IF OBJECT_ID('dbo.ProjectClosure', 'U') IS NULL
CREATE TABLE dbo.ProjectClosure (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId        INT            NOT NULL REFERENCES dbo.Project(Id) UNIQUE,
    ClosureNotes     NVARCHAR(2000) NULL,
    FinalDistEventId INT            NULL REFERENCES dbo.DistributionEvent(Id),
    InitiatedAt      DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    InitiatedBy      INT            NOT NULL REFERENCES dbo.AppUser(Id),
    CompletedAt      DATETIME2      NULL
);

IF OBJECT_ID('dbo.PartnerFeedback', 'U') IS NULL
CREATE TABLE dbo.PartnerFeedback (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    ClosureId   INT            NOT NULL REFERENCES dbo.ProjectClosure(Id),
    PartnerId   INT            NOT NULL REFERENCES dbo.Partner(Id),
    Rating      TINYINT        NULL CHECK (Rating BETWEEN 1 AND 5),
    Comments    NVARCHAR(2000) NULL,
    SubmittedAt DATETIME2      NULL
);

