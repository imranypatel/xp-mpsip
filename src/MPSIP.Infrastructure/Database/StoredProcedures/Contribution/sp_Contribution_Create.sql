CREATE OR ALTER PROCEDURE dbo.sp_Contribution_Create
    @ProjectId       INT,
    @ProjectTaskId   INT = NULL,
    @ContributorId   INT,
    @ResourceType    NVARCHAR(20),
    @Description     NVARCHAR(500),
    @Quantity        DECIMAL(18,4),
    @Unit            NVARCHAR(50) = NULL,
    @MonetaryValue   DECIMAL(18,2) = NULL,
    @ContributionDate DATE,
    @CreatedBy       INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Contribution (ProjectId, ProjectTaskId, ContributorId, ResourceType,
                                   Description, Quantity, Unit, MonetaryValue, ContributionDate, CreatedBy)
    VALUES (@ProjectId, @ProjectTaskId, @ContributorId, @ResourceType,
            @Description, @Quantity, @Unit, @MonetaryValue, @ContributionDate, @CreatedBy);
    SELECT SCOPE_IDENTITY() AS Id;
END

