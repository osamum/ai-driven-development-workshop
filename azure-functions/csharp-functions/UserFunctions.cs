using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{

public class UserFunctions
{
    private readonly ILogger _logger;
    private readonly IDataService _dataService;

    public UserFunctions(ILoggerFactory loggerFactory, IDataService dataService)
    {
        _logger = loggerFactory.CreateLogger<UserFunctions>();
        _dataService = dataService;
    }

    [Function("GetUsers")]
    public async Task<HttpResponseData> GetUsers(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all users");

        try
        {
            var users = await _dataService.GetUsersAsync();
            
            // Apply filters if provided
            var department = req.Query["department"];
            if (!string.IsNullOrEmpty(department))
            {
                users = users.Where(u => u.Department.Contains(department, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var status = req.Query["status"];
            if (!string.IsNullOrEmpty(status))
            {
                users = users.Where(u => u.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var roleId = req.Query["roleId"];
            if (!string.IsNullOrEmpty(roleId) && int.TryParse(roleId, out var rId))
            {
                users = users.Where(u => u.RoleId == rId).ToList();
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(users, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting users");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }

    [Function("GetUserById")]
    public async Task<HttpResponseData> GetUserById(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "users/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Getting user with ID: {id}");

        try
        {
            var users = await _dataService.GetUsersAsync();
            var user = users.FirstOrDefault(u => u.UserId == id);

            if (user == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync($"ユーザー ID {id} が見つかりません");
                return notFoundResponse;
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(user, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting user {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}
