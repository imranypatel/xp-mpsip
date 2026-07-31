-- DEV only seed data
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE Email = 'owner@mpsip.dev')
BEGIN
    -- Password: Dev@12345 (bcrypt hash for testing)
    INSERT INTO dbo.AppUser (Email, PasswordHash, Salt, DisplayName, IsActive)
    VALUES ('owner@mpsip.dev',
            '$2a$11$placeholder_hash_owner', 'bcrypt', 'Demo Owner', 1);
    DECLARE @OwnerId INT = SCOPE_IDENTITY();

    INSERT INTO dbo.AppUser (Email, PasswordHash, Salt, DisplayName, IsActive)
    VALUES ('partner1@mpsip.dev',
            '$2a$11$placeholder_hash_p1', 'bcrypt', 'Partner One', 1);
    DECLARE @P1Id INT = SCOPE_IDENTITY();

    INSERT INTO dbo.AppUser (Email, PasswordHash, Salt, DisplayName, IsActive)
    VALUES ('partner2@mpsip.dev',
            '$2a$11$placeholder_hash_p2', 'bcrypt', 'Partner Two', 1);
    DECLARE @P2Id INT = SCOPE_IDENTITY();

    -- Get Manufacturing kind and template IDs
    DECLARE @KindId INT; SELECT @KindId = Id FROM dbo.OpportunityKind WHERE Code = 'Manufacturing';
    DECLARE @TplId INT; SELECT @TplId = Id FROM dbo.ProjectTemplate WHERE Name = 'Manufacturing Standard';

    -- Create demo project
    INSERT INTO dbo.Project (OwnerId, OpportunityKindId, TemplateId, Name, Description,
        StartDate, ExpectedEndDate, StatusCode, CreatedBy)
    VALUES (@OwnerId, @KindId, @TplId,
        'Demo Steel Frame Project',
        'A demonstration manufacturing project for steel frame production.',
        CAST(GETDATE() AS DATE), DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)),
        'Active', @OwnerId);
    DECLARE @ProjId INT = SCOPE_IDENTITY();

    -- Apply template phases/tasks
    EXEC dbo.sp_Project_ApplyTemplate @ProjectId = @ProjId, @TemplateId = @TplId, @CreatedBy = @OwnerId;

    -- Add partners
    DECLARE @Partner1Id INT;
    EXEC @Partner1Id = dbo.sp_Partner_Create @ProjectId = @ProjId, @UserId = @P1Id, @StakePct = 30, @CreatedBy = @OwnerId;
    EXEC dbo.sp_Partner_AssignRole @PartnerId = @Partner1Id, @RoleCode = 'Investor';
    EXEC dbo.sp_Partner_SaveAgreement @PartnerId = @Partner1Id,
        @ContributionTerms = 'Monthly capital contributions',
        @IncentiveTerms = '30% of net profit distributions',
        @RiskAcceptance = 'Risk acknowledged per signed terms';
    EXEC dbo.sp_Partner_Acknowledge @PartnerId = @Partner1Id,
        @AcknowledgedByUserId = @P1Id, @SignatureText = 'Partner One — Digital Signature';

    DECLARE @Partner2Id INT;
    EXEC @Partner2Id = dbo.sp_Partner_Create @ProjectId = @ProjId, @UserId = @P2Id, @StakePct = 20, @CreatedBy = @OwnerId;
    EXEC dbo.sp_Partner_AssignRole @PartnerId = @Partner2Id, @RoleCode = 'DomainExpert';
    EXEC dbo.sp_Partner_SaveAgreement @PartnerId = @Partner2Id,
        @ContributionTerms = 'Technical expertise and oversight',
        @IncentiveTerms = '20% of net profit distributions',
        @RiskAcceptance = 'Risk acknowledged per signed terms';

    -- Contributions
    INSERT INTO dbo.Contribution (ProjectId, ContributorId, ResourceType, Description, Quantity, Unit, MonetaryValue, ContributionDate, CreatedBy)
    VALUES
        (@ProjId, @P1Id, 'Money', 'Initial capital investment', 1, 'lump sum', 50000.00, CAST(GETDATE() AS DATE), @P1Id),
        (@ProjId, @OwnerId, 'Man', 'Project management — Week 1', 40, 'hrs', NULL, CAST(GETDATE() AS DATE), @OwnerId),
        (@ProjId, @OwnerId, 'Material', 'Steel raw material purchase', 500, 'kg', 12500.00, CAST(GETDATE() AS DATE), @OwnerId);
END

