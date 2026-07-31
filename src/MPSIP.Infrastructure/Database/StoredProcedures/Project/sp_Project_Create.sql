CREATE OR ALTER PROCEDURE dbo.sp_Project_Create
    @OwnerId           INT,
    @OpportunityKindId INT,
    @TemplateId        INT = NULL,
    @Name              NVARCHAR(200),
    @Description       NVARCHAR(2000) = NULL,
    @StartDate         DATE,
    @ExpectedEndDate   DATE,
    @RiskDeclaration   NVARCHAR(2000) = NULL,
    @Contingency       NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Project (OwnerId, OpportunityKindId, TemplateId, Name, Description,
                              StartDate, ExpectedEndDate, RiskDeclaration, Contingency, CreatedBy)
    VALUES (@OwnerId, @OpportunityKindId, @TemplateId, @Name, @Description,
            @StartDate, @ExpectedEndDate, @RiskDeclaration, @Contingency, @OwnerId);
    SELECT SCOPE_IDENTITY() AS Id;
END

