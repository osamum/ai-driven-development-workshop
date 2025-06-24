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
            // クエリパラメータの取得
            var groupIdStr = req.Query["groupId"];
            int? groupId = null;
            if (!string.IsNullOrEmpty(groupIdStr) && int.TryParse(groupIdStr, out var gId))
            {
                groupId = gId;
            }

            var equipmentType = req.Query["equipmentType"];
            var status = req.Query["status"];
            var location = req.Query["location"];

            // フィルタリング機能付きでデータ取得を試行、失敗時は従来の方法にフォールバック
            List<Equipment> equipment;
            try
            {
                equipment = await _dataService.GetEquipmentWithFiltersAsync(groupId, equipmentType, status, location);
            }
            catch (NotImplementedException)
            {
                // フィルタリング機能が実装されていない場合は従来の方法
                equipment = await _dataService.GetEquipmentAsync();
                
                // メモリ内でフィルタリング
                if (groupId.HasValue)
                {
                    equipment = equipment.Where(e => e.GroupId == groupId.Value).ToList();
                }

                if (!string.IsNullOrEmpty(equipmentType))
                {
                    equipment = equipment.Where(e => e.EquipmentType.Contains(equipmentType, StringComparison.OrdinalIgnoreCase)).ToList();
                }

                if (!string.IsNullOrEmpty(status))
                {
                    equipment = equipment.Where(e => e.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
                }

                if (!string.IsNullOrEmpty(location))
                {
                    equipment = equipment.Where(e => e.Location.Contains(location, StringComparison.OrdinalIgnoreCase)).ToList();
                }
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

    [Function("GetEquipmentSensorData")]
    public async Task<HttpResponseData> GetEquipmentSensorData(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment/{id:int}/sensor-data")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Getting sensor data for equipment ID: {id}");

        try
        {
            // クエリパラメータの取得
            var fromDateStr = req.Query["fromDate"];
            var toDateStr = req.Query["toDate"];
            
            DateTime? fromDate = null;
            DateTime? toDate = null;

            if (!string.IsNullOrEmpty(fromDateStr) && DateTime.TryParse(fromDateStr, out var from))
            {
                fromDate = from;
            }

            if (!string.IsNullOrEmpty(toDateStr) && DateTime.TryParse(toDateStr, out var to))
            {
                toDate = to;
            }

            // 設備別センサーデータの取得を試行
            List<SensorData> sensorData;
            try
            {
                sensorData = await _dataService.GetSensorDataByEquipmentAsync(id, fromDate, toDate);
            }
            catch (NotImplementedException)
            {
                // フィルタリング機能が実装されていない場合は従来の方法でフォールバック
                var allSensorData = await _dataService.GetSensorDataAsync();
                var allSensors = await _dataService.GetSensorsAsync();
                
                // 指定された設備のセンサーIDを取得
                var equipmentSensorIds = allSensors
                    .Where(s => s.EquipmentId == id)
                    .Select(s => s.SensorId)
                    .ToHashSet();

                var filteredData = allSensorData
                    .Where(sd => equipmentSensorIds.Contains(sd.SensorId));

                if (fromDate.HasValue)
                {
                    filteredData = filteredData.Where(sd => sd.Timestamp >= fromDate.Value);
                }

                if (toDate.HasValue)
                {
                    filteredData = filteredData.Where(sd => sd.Timestamp <= toDate.Value);
                }

                sensorData = filteredData.OrderByDescending(sd => sd.Timestamp).ToList();
            }

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
            _logger.LogError(ex, $"Error getting sensor data for equipment {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}
