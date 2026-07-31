IF OBJECT_ID('dbo.Project', 'U') IS NULL
CREATE TABLE dbo.Project (
    Id                INT IDENTITY(1,1) PRIMARY KEY,
    OwnerId           INT            NOT NULL REFERENCES dbo.AppUser(Id),
    OpportunityKindId INT            NOT NULL REFERENCES dbo.OpportunityKind(Id),
    TemplateId        INT            NULL     REFERENCES dbo.ProjectTemplate(Id),
    Name              NVARCHAR(200)  NOT NULL,
    Description       NVARCHAR(2000) NULL,
    StartDate         DATE           NOT NULL,
    ExpectedEndDate   DATE           NOT NULL,
    ActualEndDate     DATE           NULL,
    RiskDeclaration   NVARCHAR(2000) NULL,
    Contingency       NVARCHAR(2000) NULL,
    StatusCode        NVARCHAR(30)   NOT NULL DEFAULT 'Active'
        CHECK (StatusCode IN ('Draft','Active','OnHold','Closing','Closed','Archived')),
    IsDeleted         BIT            NOT NULL DEFAULT 0,
    CreatedAt         DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy         INT            NOT NULL,
    ModifiedAt        DATETIME2      NULL,
    ModifiedBy        INT            NULL
);

IF OBJECT_ID('dbo.ProjectPhase', 'U') IS NULL
CREATE TABLE dbo.ProjectPhase (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId       INT           NOT NULL REFERENCES dbo.Project(Id),
    TemplatePhaseId INT           NULL     REFERENCES dbo.TemplatePhase(Id),
    SortOrder       INT           NOT NULL,
    Name            NVARCHAR(100) NOT NULL,
    StatusCode      NVARCHAR(30)  NOT NULL DEFAULT 'NotStarted'
        CHECK (StatusCode IN ('NotStarted','InProgress','Completed')),
    StartedAt       DATETIME2     NULL,
    CompletedAt     DATETIME2     NULL
);

IF OBJECT_ID('dbo.ProjectTask', 'U') IS NULL
CREATE TABLE dbo.ProjectTask (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    ProjectPhaseId   INT            NOT NULL REFERENCES dbo.ProjectPhase(Id),
    TemplateTaskId   INT            NULL     REFERENCES dbo.TemplateTask(Id),
    SortOrder        INT            NOT NULL,
    Name             NVARCHAR(200)  NOT NULL,
    Description      NVARCHAR(1000) NULL,
    ResourceType     NVARCHAR(20)   NOT NULL CHECK (ResourceType IN ('Man','Material','Money')),
    AssignedToUserId INT            NULL     REFERENCES dbo.AppUser(Id),
    StatusCode       NVARCHAR(30)   NOT NULL DEFAULT 'NotStarted'
        CHECK (StatusCode IN ('NotStarted','InProgress','Blocked','Completed')),
    DueDate          DATE           NULL,
    CompletedAt      DATETIME2      NULL,
    IsDeleted        BIT            NOT NULL DEFAULT 0,
    CreatedAt        DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy        INT            NOT NULL
);

