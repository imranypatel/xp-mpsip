CREATE OR ALTER PROCEDURE dbo.sp_Partner_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.ProjectId, p.UserId, p.StakePct, p.JoinedAt, p.StatusCode,
           p.IsDeleted, p.CreatedAt, p.CreatedBy,
           u.DisplayName, u.Email
    FROM dbo.Partner p
    INNER JOIN dbo.AppUser u ON u.Id = p.UserId
    WHERE p.Id = @Id;
END

