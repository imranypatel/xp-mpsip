IF NOT EXISTS (SELECT 1 FROM dbo.ProjectTemplate WHERE Name = 'Manufacturing Standard' AND IsBuiltIn = 1)
BEGIN
    DECLARE @KindId INT;
    SELECT @KindId = Id FROM dbo.OpportunityKind WHERE Code = 'Manufacturing';

    INSERT INTO dbo.ProjectTemplate (OpportunityKindId, Name, Description, IsBuiltIn)
    VALUES (@KindId, 'Manufacturing Standard', 'Standard manufacturing project template with 7 phases', 1);

    DECLARE @TplId INT = SCOPE_IDENTITY();

    -- Ideation
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 1, 'Ideation');
    DECLARE @P1 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P1, 1, 'Define concept', 'Man'),
        (@P1, 2, 'Feasibility analysis', 'Man'),
        (@P1, 3, 'Stakeholder alignment', 'Man');

    -- Planning
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 2, 'Planning');
    DECLARE @P2 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P2, 1, 'Resource planning', 'Man'),
        (@P2, 2, 'Budget estimation', 'Money'),
        (@P2, 3, 'Risk assessment', 'Man');

    -- Procurement
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 3, 'Procurement');
    DECLARE @P3 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P3, 1, 'Source materials', 'Material'),
        (@P3, 2, 'Vendor agreements', 'Man'),
        (@P3, 3, 'Purchase orders', 'Money');

    -- Production
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 4, 'Production');
    DECLARE @P4 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P4, 1, 'Manufacturing run', 'Man'),
        (@P4, 2, 'Quality checks', 'Man');

    -- Quality Assurance
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 5, 'Quality Assurance');
    DECLARE @P5 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P5, 1, 'Final inspection', 'Man'),
        (@P5, 2, 'Defect resolution', 'Man');

    -- Delivery
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 6, 'Delivery');
    DECLARE @P6 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P6, 1, 'Packaging', 'Material'),
        (@P6, 2, 'Logistics', 'Man'),
        (@P6, 3, 'Customer handover', 'Man');

    -- Closure
    INSERT INTO dbo.TemplatePhase (TemplateId, SortOrder, Name) VALUES (@TplId, 7, 'Closure');
    DECLARE @P7 INT = SCOPE_IDENTITY();
    INSERT INTO dbo.TemplateTask (TemplatePhaseId, SortOrder, Name, ResourceType) VALUES
        (@P7, 1, 'Final accounts', 'Money'),
        (@P7, 2, 'Partner distributions', 'Money'),
        (@P7, 3, 'Project review', 'Man');
END

