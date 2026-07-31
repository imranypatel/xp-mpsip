using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;
using MPSIP.Application.Interfaces;

namespace MPSIP.Infrastructure.Email;

public class MailKitEmailSender(IConfiguration config) : IEmailSender
{
    public async Task SendInvitationAsync(string toEmail, string toName, string projectName, string invitationLink)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(config["Email:FromAddress"] ?? "noreply@mpsip.local"));
        message.To.Add(new MailboxAddress(toName, toEmail));
        message.Subject = $"You've been invited to join '{projectName}' on MPSIP";
        message.Body = new TextPart("html")
        {
            Text = $"""
                <h2>You've been invited!</h2>
                <p>You have been invited to join the project <strong>{projectName}</strong> on MPSIP.</p>
                <p><a href="{invitationLink}" style="background:#1E3A5F;color:#fff;padding:10px 20px;text-decoration:none;border-radius:4px;">Accept Invitation</a></p>
                <p>This link expires in 48 hours.</p>
                <p>If you did not expect this invitation, you can safely ignore this email.</p>
                """
        };

        using var client = new SmtpClient();
        string host = config["Email:Host"] ?? "localhost";
        int port = int.Parse(config["Email:Port"] ?? "25");
        bool useSsl = bool.Parse(config["Email:UseSsl"] ?? "false");

        await client.ConnectAsync(host, port, useSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.None);
        string? username = config["Email:Username"];
        if (!string.IsNullOrEmpty(username))
            await client.AuthenticateAsync(username, config["Email:Password"]);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
