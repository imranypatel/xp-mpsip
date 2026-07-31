CREATE OR ALTER PROCEDURE dbo.sp_Closure_SubmitFeedback
    @ClosureId  INT,
    @PartnerId  INT,
    @Rating     TINYINT = NULL,
    @Comments   NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.PartnerFeedback WHERE ClosureId = @ClosureId AND PartnerId = @PartnerId)
        UPDATE dbo.PartnerFeedback
        SET Rating = @Rating, Comments = @Comments, SubmittedAt = GETUTCDATE()
        WHERE ClosureId = @ClosureId AND PartnerId = @PartnerId;
    ELSE
        INSERT INTO dbo.PartnerFeedback (ClosureId, PartnerId, Rating, Comments, SubmittedAt)
        VALUES (@ClosureId, @PartnerId, @Rating, @Comments, GETUTCDATE());
END

