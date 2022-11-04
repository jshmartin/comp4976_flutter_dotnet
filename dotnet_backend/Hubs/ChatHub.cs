using Microsoft.AspNetCore.SignalR;

namespace SignalrChat.Hubs;

public class ChatHub : Hub
{
    public async Task SendMessage(string user, string message)
    {
        await Clients.All.SendAsync("ReceiveMessage", user, message);
        Console.WriteLine($"SendMessage: {user} {message}");
    }
}