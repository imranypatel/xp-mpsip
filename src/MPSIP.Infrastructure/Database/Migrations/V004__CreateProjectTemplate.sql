IF OBJECT_ID('dbo.ProjectTemplate', 'U') IS NULL
CREATE TABLE dbo.ProjectTemplate (
    Id                INT IDENTITY(1,1) PRIMARY KEY,
    OpportunityKindId INT           NOT NULL REFERENCES dbo.OpportunityKind(Id),
    Name              NVARCHAR(100) NOT NULL,
    Description       NVARCHAR(500) NULL,
    IsBuiltIn         BIT           NOT NULL DEFAULT 1
);

IF OBJECT_ID('dbo.TemplatePhase', 'U') IS NULL
CREATE TABLE dbo.TemplatePhase (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    TemplateId   INT           NOT NULL REFERENCES dbo.ProjectTemplate(Id),
    SortOrder    INT           NOT NULL,
    Name         NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(500) NULL
);

IF OBJECT_ID('dbo.TemplateTask', 'U') IS NULL
CREATE TABLE dbo.TemplateTask (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    TemplatePhaseId INT           NOT NULL REFERENCES dbo.TemplatePhase(Id),
    SortOrder       INT           NOT NULL,
    Name            NVARCHAR(200) NOT NULL,
    Description     NVARCHAR(500) NULL,
    ResourceType    NVARCHAR(20)  NOT NULL CHECK (ResourceType IN ('Man','Material','Money'))
);

