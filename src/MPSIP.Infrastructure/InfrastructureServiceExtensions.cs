using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MPSIP.Application.Interfaces;
using MPSIP.Application.Services;
using MPSIP.Infrastructure.Data;
using MPSIP.Infrastructure.Email;
using MPSIP.Infrastructure.Repositories;

namespace MPSIP.Infrastructure;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services, IConfiguration config)
    {
        string connStr = config.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("DefaultConnection not configured.");

        services.AddSingleton<IDbConnectionFactory>(new SqlConnectionFactory(connStr));

        services.AddScoped<IAuthRepository, AuthRepository>();
        services.AddScoped<IProjectRepository, ProjectRepository>();
        services.AddScoped<IPartnerRepository, PartnerRepository>();
        services.AddScoped<IContributionRepository, ContributionRepository>();
        services.AddScoped<IDistributionRepository, DistributionRepository>();
        services.AddScoped<ITaskRepository, TaskRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<IClosureRepository, ClosureRepository>();
        services.AddScoped<IEmailSender, MailKitEmailSender>();

        return services;
    }
}
