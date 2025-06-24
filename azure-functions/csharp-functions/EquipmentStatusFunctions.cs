using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{
    /// <summary>
    /// 設備稼働状況の統合APIエンドポイント
    /// </summary>
    public class EquipmentStatusFunctions
    {
        private readonly ILogger _logger;
        private readonly IDataService _dataService;

        public EquipmentStatusFunctions(ILoggerFactory loggerFactory, IDataService dataService)
        {
            _logger = loggerFactory.CreateLogger<EquipmentStatusFunctions>();
            _dataService = dataService;
        }

        [Function("GetEquipmentStatus")]
        public async Task<HttpResponseData> GetEquipmentStatus(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "equipment-status")] HttpRequestData req)
        {
            _logger.LogInformation("Getting integrated equipment status data");

            try
            {
                // フィルタリングパラメータの取得
                var groupIdStr = req.Query["groupId"];
                int? groupId = null;
                if (!string.IsNullOrEmpty(groupIdStr) && int.TryParse(groupIdStr, out var gId))
                {
                    groupId = gId;
                }

                var equipmentType = req.Query["equipmentType"];
                var status = req.Query["status"];
                var location = req.Query["location"];

                // 並列でデータを取得
                var equipmentTask = GetFilteredEquipmentAsync(groupId, equipmentType, status, location);
                var groupsTask = _dataService.GetEquipmentGroupsAsync();
                var sensorsTask = _dataService.GetSensorsAsync();
                var sensorDataTask = _dataService.GetSensorDataAsync();

                await Task.WhenAll(equipmentTask, groupsTask, sensorsTask, sensorDataTask);

                var equipment = await equipmentTask;
                var groups = await groupsTask;
                var sensors = await sensorsTask;
                var sensorData = await sensorDataTask;

                // レスポンスデータを構築
                var responseData = new
                {
                    equipment = equipment,
                    groups = groups,
                    sensors = sensors,
                    sensorData = sensorData,
                    timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
                    summary = new
                    {
                        totalEquipment = equipment.Count,
                        activeCount = equipment.Count(e => e.Status == "稼働中"),
                        stoppedCount = equipment.Count(e => e.Status == "停止中"),
                        errorCount = equipment.Count(e => e.Status == "故障"),
                        maintenanceCount = equipment.Count(e => e.Status == "保守中" || e.Status == "メンテナンス")
                    }
                };

                var response = req.CreateResponse(HttpStatusCode.OK);
                response.Headers.Add("Content-Type", "application/json; charset=utf-8");
                
                var jsonOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    WriteIndented = true
                };
                
                await response.WriteStringAsync(JsonSerializer.Serialize(responseData, jsonOptions));
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting equipment status");
                var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
                await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
                return errorResponse;
            }
        }

        /// <summary>
        /// フィルタリング付きで設備データを取得（内部メソッド）
        /// </summary>
        private async Task<List<Equipment>> GetFilteredEquipmentAsync(
            int? groupId, string? equipmentType, string? status, string? location)
        {
            try
            {
                return await _dataService.GetEquipmentWithFiltersAsync(groupId, equipmentType, status, location);
            }
            catch (NotImplementedException)
            {
                // フィルタリング機能が実装されていない場合は従来の方法
                var equipment = await _dataService.GetEquipmentAsync();
                
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

                return equipment;
            }
        }
    }
}