using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;
using FactoryManagementApi.Models;
using FactoryManagementApi.Services;

namespace FactoryManagementApi.Functions
{

public class AlertFunctions
{
    private readonly ILogger _logger;
    private readonly IDataService _dataService;

    public AlertFunctions(ILoggerFactory loggerFactory, IDataService dataService)
    {
        _logger = loggerFactory.CreateLogger<AlertFunctions>();
        _dataService = dataService;
    }

    [Function("GetAlerts")]
    public async Task<HttpResponseData> GetAlerts(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "alerts")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all alerts");

        try
        {
            var alerts = await _dataService.GetAlertsAsync();
            
            // Apply filters if provided
            var equipmentId = req.Query["equipmentId"];
            if (!string.IsNullOrEmpty(equipmentId) && int.TryParse(equipmentId, out var eId))
            {
                alerts = alerts.Where(a => a.EquipmentId == eId).ToList();
            }

            var severity = req.Query["severity"];
            if (!string.IsNullOrEmpty(severity))
            {
                alerts = alerts.Where(a => a.Severity.Contains(severity, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var status = req.Query["status"];
            if (!string.IsNullOrEmpty(status))
            {
                alerts = alerts.Where(a => a.Status.Contains(status, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var fromDate = req.Query["fromDate"];
            if (!string.IsNullOrEmpty(fromDate) && DateTime.TryParse(fromDate, out var from))
            {
                alerts = alerts.Where(a => a.TriggeredAt >= from).ToList();
            }

            var toDate = req.Query["toDate"];
            if (!string.IsNullOrEmpty(toDate) && DateTime.TryParse(toDate, out var to))
            {
                alerts = alerts.Where(a => a.TriggeredAt <= to).ToList();
            }

            var assignedTo = req.Query["assignedTo"];
            if (!string.IsNullOrEmpty(assignedTo) && int.TryParse(assignedTo, out var aId))
            {
                alerts = alerts.Where(a => a.AssignedTo == aId).ToList();
            }

            // Sort by triggered date descending by default
            alerts = alerts.OrderByDescending(a => a.TriggeredAt).ToList();

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(alerts, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting alerts");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }

    [Function("GetAlertById")]
    public async Task<HttpResponseData> GetAlertById(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "alerts/{id:long}")] HttpRequestData req,
        long id)
    {
        _logger.LogInformation($"Getting alert with ID: {id}");

        try
        {
            var alerts = await _dataService.GetAlertsAsync();
            var alert = alerts.FirstOrDefault(a => a.AlertId == id);

            if (alert == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync($"アラート ID {id} が見つかりません");
                return notFoundResponse;
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            
            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true
            };
            
            await response.WriteStringAsync(JsonSerializer.Serialize(alert, jsonOptions));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting alert {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"エラーが発生しました: {ex.Message}");
            return errorResponse;
        }
    }
}
}
