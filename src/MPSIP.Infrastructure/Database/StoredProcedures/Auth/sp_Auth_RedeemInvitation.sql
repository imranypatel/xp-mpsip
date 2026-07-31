CREATE OR ALTER PROCEDURE dbo.sp_Auth_RedeemInvitation
    @Token  UNIQUEIDENTIFIER,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.InvitationToken SET UsedAt = GETUTCDATE()
    WHERE Token = @Token AND UsedAt IS NULL;

    -- Also activate the partner record if exists
    UPDATE p SET p.StatusCode = 'Active', p.JoinedAt = GETUTCDATE()
    FROM dbo.Partner p
    INNER JOIN dbo.InvitationToken it ON it.ProjectId = p.ProjectId AND it.Token = @Token
    WHERE p.UserId = @UserId;
END

