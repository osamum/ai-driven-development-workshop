using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{

public class SensorFunctions
{
    private readonly ILogger _logger;
    private readonly IDataService _dataService;

    public SensorFunctions(ILoggerFactory loggerFactory, IDataService dataService)
    {
        _logger = loggerFactory.CreateLogger<SensorFunctions>();
        _dataService = dataService;
    }

    [Function("GetSensors")]
    public async Task<HttpResponseData> GetSensors(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "sensors")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all sensors");

        try
        {
            var sensors = await _dataService.GetSensorsAsync();
            
            // Apply filters if provided
            var equipmentId = req.Query["equipmentId"];
            if (!string.IsNullOrEmpty(equipmentId) && int.TryParse(equipmentId, out var eId))
            {
                sensors = sensors.Where(s => s.EquipmentId == eId).ToList();
            }

            var sensorType = req.Query["sensorType"];
            if (!string.IsNullOrEmpty(sensorType))
            {
                sensors = sensors.Where(s => s.SensorType.Contains(sensorType, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var status = req.Query["status"];
            if (!string.IsNullOrEmpty(status))
            {
                sensors = sensors.Where(s => s.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(sensors, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting sensors");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }

    [Function("GetSensorData")]
    public async Task<HttpResponseData> GetSensorData(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "sensor-data")] HttpRequestData req)
    {
        _logger.LogInformation("Getting sensor data");

        try
        {
            var sensorData = await _dataService.GetSensorDataAsync();
            
            // Apply filters if provided
            var sensorId = req.Query["sensorId"];
            if (!string.IsNullOrEmpty(sensorId) && int.TryParse(sensorId, out var sId))
            {
                sensorData = sensorData.Where(sd => sd.SensorId == sId).ToList();
            }

            var fromDate = req.Query["fromDate"];
            if (!string.IsNullOrEmpty(fromDate) && DateTime.TryParse(fromDate, out var from))
            {
                sensorData = sensorData.Where(sd => sd.Timestamp >= from).ToList();
            }

            var toDate = req.Query["toDate"];
            if (!string.IsNullOrEmpty(toDate) && DateTime.TryParse(toDate, out var to))
            {
                sensorData = sensorData.Where(sd => sd.Timestamp <= to).ToList();
            }

            var status = req.Query["status"];
            if (!string.IsNullOrEmpty(status))
            {
                sensorData = sensorData.Where(sd => sd.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            // Sort by timestamp descending by default
            sensorData = sensorData.OrderByDescending(sd => sd.Timestamp).ToList();

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(sensorData, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting sensor data");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}
