using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public interface INotificationService
{
    Task<int> CreateAsync(CreateNotificationCommand cmd);
    Task<IEnumerable<Notification>> GetForUserAsync(int userId);
    Task MarkReadAsync(int notificationId);
    Task MarkAllReadAsync(int userId);
    Task<int> GetUnreadCountAsync(int userId);
}

public class NotificationService(INotificationRepository repo) : INotificationService
{
    public async Task<int> CreateAsync(CreateNotificationCommand cmd) =>
        await repo.CreateAsync(cmd);

    public async Task<IEnumerable<Notification>> GetForUserAsync(int userId) =>
        await repo.ListByUserAsync(userId);

    public async Task MarkReadAsync(int notificationId) =>
        await repo.MarkReadAsync(notificationId);

    public async Task MarkAllReadAsync(int userId) =>
        await repo.MarkAllReadAsync(userId);

    public async Task<int> GetUnreadCountAsync(int userId) =>
        await repo.GetUnreadCountAsync(userId);
}
