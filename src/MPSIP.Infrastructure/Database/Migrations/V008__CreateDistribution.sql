IF OBJECT_ID('dbo.DistributionEvent', 'U') IS NULL
CREATE TABLE dbo.DistributionEvent (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId   INT            NOT NULL REFERENCES dbo.Project(Id),
    Name        NVARCHAR(200)  NOT NULL,
    TotalAmount DECIMAL(18,2)  NOT NULL,
    EventDate   DATE           NOT NULL,
    Notes       NVARCHAR(1000) NULL,
    StatusCode  NVARCHAR(30)   NOT NULL DEFAULT 'Pending'
        CHECK (StatusCode IN ('Pending','Distributed','Cancelled')),
    CreatedAt   DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy   INT            NOT NULL
);

IF OBJECT_ID('dbo.DistributionShare', 'U') IS NULL
CREATE TABLE dbo.DistributionShare (
    Id                   INT IDENTITY(1,1) PRIMARY KEY,
    DistributionEventId  INT           NOT NULL REFERENCES dbo.DistributionEvent(Id),
    PartnerId            INT           NOT NULL REFERENCES dbo.Partner(Id),
    SharePct             DECIMAL(5,2)  NOT NULL,
    Amount               DECIMAL(18,2) NOT NULL,
    AcknowledgedAt       DATETIME2     NULL,
    AcknowledgedByUserId INT           NULL REFERENCES dbo.AppUser(Id)
);

