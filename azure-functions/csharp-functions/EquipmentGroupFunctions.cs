using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{

public class EquipmentGroupFunctions
{
    private readonly ILogger _logger;
    private readonly IDataService _dataService;

    public EquipmentGroupFunctions(ILoggerFactory loggerFactory, IDataService dataService)
    {
        _logger = loggerFactory.CreateLogger<EquipmentGroupFunctions>();
        _dataService = dataService;
    }

    [Function("GetEquipmentGroups")]
    public async Task<HttpResponseData> GetEquipmentGroups(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment-groups")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all equipment groups");

        try
        {
            var groups = await _dataService.GetEquipmentGroupsAsync();
            
            // Apply filters if provided
            var groupId = req.Query["groupId"];
            if (!string.IsNullOrEmpty(groupId) && int.TryParse(groupId, out var id))
            {
                groups = groups.Where(g => g.GroupId == id).ToList();
            }

            var groupName = req.Query["groupName"];
            if (!string.IsNullOrEmpty(groupName))
            {
                groups = groups.Where(g => g.GroupName.Contains(groupName, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(groups, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting equipment groups");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }

    [Function("GetEquipmentGroupById")]
    public async Task<HttpResponseData> GetEquipmentGroupById(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment-groups/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Getting equipment group with ID: {id}");

        try
        {
            var groups = await _dataService.GetEquipmentGroupsAsync();
            var group = groups.FirstOrDefault(g => g.GroupId == id);

            if (group == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync($"設備グループ ID {id} が見つかりません");
                return notFoundResponse;
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(group, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting equipment group {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}