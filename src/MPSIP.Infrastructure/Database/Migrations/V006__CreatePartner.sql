IF OBJECT_ID('dbo.Partner', 'U') IS NULL
CREATE TABLE dbo.Partner (
    Id         INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId  INT           NOT NULL REFERENCES dbo.Project(Id),
    UserId     INT           NOT NULL REFERENCES dbo.AppUser(Id),
    StakePct   DECIMAL(5,2)  NOT NULL DEFAULT 0,
    JoinedAt   DATETIME2     NULL,
    StatusCode NVARCHAR(30)  NOT NULL DEFAULT 'Invited'
        CHECK (StatusCode IN ('Invited','Active','Withdrawn')),
    IsDeleted  BIT           NOT NULL DEFAULT 0,
    CreatedAt  DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy  INT           NOT NULL
);

IF OBJECT_ID('dbo.PartnerRole', 'U') IS NULL
CREATE TABLE dbo.PartnerRole (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    PartnerId INT           NOT NULL REFERENCES dbo.Partner(Id),
    RoleCode  NVARCHAR(50)  NOT NULL
        CHECK (RoleCode IN ('Owner','Investor','DomainExpert','Consultant',
                            'Contractor','Builder','Developer','Labour'))
);

IF OBJECT_ID('dbo.PartnerAgreement', 'U') IS NULL
CREATE TABLE dbo.PartnerAgreement (
    Id                   INT IDENTITY(1,1) PRIMARY KEY,
    PartnerId            INT            NOT NULL REFERENCES dbo.Partner(Id),
    ContributionTerms    NVARCHAR(2000) NULL,
    IncentiveTerms       NVARCHAR(2000) NULL,
    RiskAcceptance       NVARCHAR(2000) NULL,
    AcknowledgedAt       DATETIME2      NULL,
    AcknowledgedByUserId INT            NULL REFERENCES dbo.AppUser(Id),
    SignatureText        NVARCHAR(200)  NULL,
    CreatedAt            DATETIME2      NOT NULL DEFAULT GETUTCDATE()
);

