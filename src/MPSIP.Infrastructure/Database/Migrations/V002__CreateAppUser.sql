IF OBJECT_ID('dbo.AppUser', 'U') IS NULL
CREATE TABLE dbo.AppUser (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    OwnerId      INT           NULL,
    Email        NVARCHAR(256) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(512) NOT NULL,
    Salt         NVARCHAR(128) NOT NULL,
    DisplayName  NVARCHAR(100) NOT NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy    INT           NULL,
    ModifiedAt   DATETIME2     NULL,
    ModifiedBy   INT           NULL,
    IsDeleted    BIT           NOT NULL DEFAULT 0
);

IF OBJECT_ID('dbo.InvitationToken', 'U') IS NULL
CREATE TABLE dbo.InvitationToken (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Token     UNIQUEIDENTIFIER  NOT NULL DEFAULT NEWID() UNIQUE,
    ProjectId INT               NOT NULL,
    Email     NVARCHAR(256)     NOT NULL,
    ExpiresAt DATETIME2         NOT NULL,
    UsedAt    DATETIME2         NULL,
    CreatedAt DATETIME2         NOT NULL DEFAULT GETUTCDATE()
);

