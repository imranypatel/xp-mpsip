CREATE OR ALTER PROCEDURE dbo.sp_Closure_GetByProject
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pc.Id, pc.ProjectId, pc.ClosureNotes, pc.FinalDistEventId,
           pc.InitiatedAt, pc.InitiatedBy, pc.CompletedAt,
           pf.Id AS FeedbackId, pf.PartnerId, pf.Rating, pf.Comments, pf.SubmittedAt,
           u.DisplayName AS PartnerName
    FROM dbo.ProjectClosure pc
    LEFT JOIN dbo.PartnerFeedback pf ON pf.ClosureId = pc.Id
    LEFT JOIN dbo.Partner p ON p.Id = pf.PartnerId
    LEFT JOIN dbo.AppUser u ON u.Id = p.UserId
    WHERE pc.ProjectId = @ProjectId;
END

