using System.Security.Claims;
using Microsoft.AspNetCore.Components.Authorization;
using MPSIP.Application.Services;

namespace MPSIP.Web.Services;

public class MpsipAuthStateProvider(IHttpContextAccessor httpContextAccessor, AuthService authService)
    : AuthenticationStateProvider
{
    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        var userIdClaim = httpContextAccessor.HttpContext?.User
            .FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);

        if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            return Unauthenticated();

        var user = await authService.GetUserByIdAsync(userId);
        if (user == null || !user.IsActive)
            return Unauthenticated();

        var identity = new ClaimsIdentity(
        [
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.DisplayName)
        ], "cookie");

        return new AuthenticationState(new ClaimsPrincipal(identity));
    }

    public void NotifyAuthChanged() =>
        NotifyAuthenticationStateChanged(GetAuthenticationStateAsync());

    private static AuthenticationState Unauthenticated() =>
        new(new ClaimsPrincipal(new ClaimsIdentity()));
}
