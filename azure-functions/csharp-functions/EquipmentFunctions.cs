using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{

public class EquipmentFunctions
{
    private readonly ILogger _logger;
    private readonly IDataService _dataService;

    public EquipmentFunctions(ILoggerFactory loggerFactory, IDataService dataService)
    {
        _logger = loggerFactory.CreateLogger<EquipmentFunctions>();
        _dataService = dataService;
    }

    [Function("GetEquipment")]
    public async Task<HttpResponseData> GetEquipment(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all equipment");

        try
        {
            var equipment = await _dataService.GetEquipmentAsync();
            
            // Apply filters if provided
            var groupId = req.Query["groupId"];
            if (!string.IsNullOrEmpty(groupId) && int.TryParse(groupId, out var gId))
            {
                equipment = equipment.Where(e => e.GroupId == gId).ToList();
            }

            var equipmentType = req.Query["equipmentType"];
            if (!string.IsNullOrEmpty(equipmentType))
            {
                equipment = equipment.Where(e => e.EquipmentType.Contains(equipmentType, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var status = req.Query["status"];
            if (!string.IsNullOrEmpty(status))
            {
                equipment = equipment.Where(e => e.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var location = req.Query["location"];
            if (!string.IsNullOrEmpty(location))
            {
                equipment = equipment.Where(e => e.Location.Contains(location, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(equipment, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting equipment");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }

    [Function("GetEquipmentById")]
    public async Task<HttpResponseData> GetEquipmentById(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Getting equipment with ID: {id}");

        try
        {
            var equipment = await _dataService.GetEquipmentAsync();
            var equipmentItem = equipment.FirstOrDefault(e => e.EquipmentId == id);

            if (equipmentItem == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync($"設備 ID {id} が見つかりません");
                return notFoundResponse;
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(equipmentItem, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting equipment {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}
