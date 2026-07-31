CREATE OR ALTER PROCEDURE dbo.sp_Partner_AssignRole
    @PartnerId INT,
    @RoleCode  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.PartnerRole WHERE PartnerId = @PartnerId AND RoleCode = @RoleCode)
        INSERT INTO dbo.PartnerRole (PartnerId, RoleCode) VALUES (@PartnerId, @RoleCode);
END

