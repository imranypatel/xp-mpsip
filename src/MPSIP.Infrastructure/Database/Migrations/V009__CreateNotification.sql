IF OBJECT_ID('dbo.Notification', 'U') IS NULL
CREATE TABLE dbo.Notification (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    UserId    INT            NOT NULL REFERENCES dbo.AppUser(Id),
    ProjectId INT            NULL     REFERENCES dbo.Project(Id),
    TypeCode  NVARCHAR(50)   NOT NULL,
    Title     NVARCHAR(200)  NOT NULL,
    Body      NVARCHAR(1000) NOT NULL,
    IsRead    BIT            NOT NULL DEFAULT 0,
    CreatedAt DATETIME2      NOT NULL DEFAULT GETUTCDATE()
);

