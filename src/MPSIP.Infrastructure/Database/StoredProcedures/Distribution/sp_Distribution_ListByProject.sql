CREATE OR ALTER PROCEDURE dbo.sp_Distribution_ListByProject
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT de.Id, de.ProjectId, de.Name, de.TotalAmount, de.EventDate, de.Notes, de.StatusCode, de.CreatedAt, de.CreatedBy,
           ds.Id AS ShareId, ds.PartnerId, ds.SharePct, ds.Amount, ds.AcknowledgedAt, ds.AcknowledgedByUserId,
           u.DisplayName AS PartnerName
    FROM dbo.DistributionEvent de
    LEFT JOIN dbo.DistributionShare ds ON ds.DistributionEventId = de.Id
    LEFT JOIN dbo.Partner p ON p.Id = ds.PartnerId
    LEFT JOIN dbo.AppUser u ON u.Id = p.UserId
    WHERE de.ProjectId = @ProjectId
    ORDER BY de.EventDate DESC;
END

