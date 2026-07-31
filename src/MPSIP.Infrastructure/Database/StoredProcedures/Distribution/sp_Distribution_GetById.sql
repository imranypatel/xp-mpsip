CREATE OR ALTER PROCEDURE dbo.sp_Distribution_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT de.Id, de.ProjectId, de.Name, de.TotalAmount, de.EventDate, de.Notes,
           de.StatusCode, de.CreatedAt, de.CreatedBy
    FROM dbo.DistributionEvent de
    WHERE de.Id = @Id;
END
