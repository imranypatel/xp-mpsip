IF NOT EXISTS (SELECT 1 FROM dbo.OpportunityKind WHERE Code = 'Manufacturing')
BEGIN
    INSERT INTO dbo.OpportunityKind (Code, Name) VALUES
        ('Manufacturing', 'Manufacturing'),
        ('Trading',       'Trading'),
        ('Servicing',     'Servicing');
END

