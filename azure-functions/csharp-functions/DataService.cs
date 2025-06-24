using FactoryManagementApi.Models;
using Newtonsoft.Json;

namespace FactoryManagementApi.Services
{

public interface IDataService
{
    Task<List<EquipmentGroup>> GetEquipmentGroupsAsync();
    Task<List<Equipment>> GetEquipmentAsync();
    Task<List<Sensor>> GetSensorsAsync();
    Task<List<SensorData>> GetSensorDataAsync();
    Task<List<User>> GetUsersAsync();
    Task<List<Alert>> GetAlertsAsync();
    
    // フィルタリング機能付きメソッド（任意実装）
    Task<List<Equipment>> GetEquipmentWithFiltersAsync(int? groupId = null, string? equipmentType = null, string? status = null, string? location = null);
    Task<List<SensorData>> GetSensorDataByEquipmentAsync(int equipmentId, DateTime? fromDate = null, DateTime? toDate = null);
}

public class DataService : IDataService
{
    private readonly string _dataPath;

    public DataService()
    {
        // Data files are expected to be in the sample-data directory relative to function app
        _dataPath = Path.Combine(Directory.GetCurrentDirectory(), "..", "..", "sample-data");
    }

    public async Task<List<EquipmentGroup>> GetEquipmentGroupsAsync()
    {
        var filePath = Path.Combine(_dataPath, "01_equipment_groups.json");
        if (!File.Exists(filePath))
        {
            return new List<EquipmentGroup>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var groups = JsonConvert.DeserializeObject<List<EquipmentGroup>>(json) ?? new List<EquipmentGroup>();
        
        // Convert property names to match C# conventions
        return groups.Select(g => new EquipmentGroup
        {
            GroupId = g.GroupId,
            GroupName = g.GroupName,
            Description = g.Description,
            CreatedAt = g.CreatedAt,
            UpdatedAt = g.UpdatedAt
        }).ToList();
    }

    public async Task<List<Equipment>> GetEquipmentAsync()
    {
        var filePath = Path.Combine(_dataPath, "02_equipment.json");
        if (!File.Exists(filePath))
        {
            return new List<Equipment>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var equipmentList = JsonConvert.DeserializeObject<List<dynamic>>(json) ?? new List<dynamic>();
        
        return equipmentList.Select(e => new Equipment
        {
            EquipmentId = (int)e.equipment_id,
            GroupId = (int)e.group_id,
            EquipmentName = (string)e.equipment_name,
            EquipmentType = (string)e.equipment_type,
            ModelNumber = (string)e.model_number,
            SerialNumber = (string)e.serial_number,
            Manufacturer = (string)e.manufacturer,
            InstallationDate = DateTime.Parse((string)e.installation_date),
            Location = (string)e.location,
            Status = (string)e.status,
            CreatedAt = DateTime.Parse((string)e.created_at),
            UpdatedAt = DateTime.Parse((string)e.updated_at)
        }).ToList();
    }

    public async Task<List<Sensor>> GetSensorsAsync()
    {
        var filePath = Path.Combine(_dataPath, "03_sensors.json");
        if (!File.Exists(filePath))
        {
            return new List<Sensor>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var sensorList = JsonConvert.DeserializeObject<List<dynamic>>(json) ?? new List<dynamic>();
        
        return sensorList.Select(s => new Sensor
        {
            SensorId = (int)s.sensor_id,
            EquipmentId = (int)s.equipment_id,
            SensorName = (string)s.sensor_name,
            SensorType = (string)s.sensor_type,
            MeasurementUnit = (string)s.measurement_unit,
            MinValue = (decimal)s.min_value,
            MaxValue = (decimal)s.max_value,
            NormalMin = (decimal)s.normal_min,
            NormalMax = (decimal)s.normal_max,
            Status = (string)s.status,
            CreatedAt = DateTime.Parse((string)s.created_at),
            UpdatedAt = DateTime.Parse((string)s.updated_at)
        }).ToList();
    }

    public async Task<List<SensorData>> GetSensorDataAsync()
    {
        var filePath = Path.Combine(_dataPath, "11_sensor_data.json");
        if (!File.Exists(filePath))
        {
            return new List<SensorData>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var sensorDataList = JsonConvert.DeserializeObject<List<dynamic>>(json) ?? new List<dynamic>();
        
        return sensorDataList.Select(sd => new SensorData
        {
            DataId = (long)sd.data_id,
            SensorId = (int)sd.sensor_id,
            Value = (decimal)sd.value,
            Status = (string)sd.status,
            Timestamp = DateTime.Parse((string)sd.timestamp),
            CreatedAt = DateTime.Parse((string)sd.created_at)
        }).ToList();
    }

    public async Task<List<User>> GetUsersAsync()
    {
        var filePath = Path.Combine(_dataPath, "05_users.json");
        if (!File.Exists(filePath))
        {
            return new List<User>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var userList = JsonConvert.DeserializeObject<List<dynamic>>(json) ?? new List<dynamic>();
        
        return userList.Select(u => new User
        {
            UserId = (int)u.user_id,
            RoleId = (int)u.role_id,
            Username = (string)u.username,
            Email = (string)u.email,
            FullName = (string)u.full_name,
            Department = (string)u.department,
            PhoneNumber = (string)u.phone_number,
            Status = (string)u.status,
            LastLogin = u.last_login != null ? DateTime.Parse((string)u.last_login) : null,
            CreatedAt = DateTime.Parse((string)u.created_at),
            UpdatedAt = DateTime.Parse((string)u.updated_at)
        }).ToList();
    }

    public async Task<List<Alert>> GetAlertsAsync()
    {
        var filePath = Path.Combine(_dataPath, "13_alerts.json");
        if (!File.Exists(filePath))
        {
            return new List<Alert>();
        }

        var json = await File.ReadAllTextAsync(filePath);
        var alertList = JsonConvert.DeserializeObject<List<dynamic>>(json) ?? new List<dynamic>();
        
        return alertList.Select(a => new Alert
        {
            AlertId = (long)a.alert_id,
            EquipmentId = (int)a.equipment_id,
            SensorId = (int)a.sensor_id,
            AlertTypeId = (int)a.alert_type_id,
            Severity = (string)a.severity,
            Message = (string)a.message,
            TriggeredAt = DateTime.Parse((string)a.triggered_at),
            Status = (string)a.status,
            AssignedTo = a.assigned_to != null ? (int)a.assigned_to : null,
            AcknowledgedAt = a.acknowledged_at != null ? DateTime.Parse((string)a.acknowledged_at) : null,
            ResolvedAt = a.resolved_at != null ? DateTime.Parse((string)a.resolved_at) : null,
            CreatedAt = DateTime.Parse((string)a.created_at),
            UpdatedAt = DateTime.Parse((string)a.updated_at)
        }).ToList();
    }
    
    /// <summary>
    /// フィルタリング機能付きで設備データを取得（ファイルベース実装）
    /// </summary>
    public async Task<List<Equipment>> GetEquipmentWithFiltersAsync(
        int? groupId = null, 
        string? equipmentType = null, 
        string? status = null, 
        string? location = null)
    {
        var allEquipment = await GetEquipmentAsync();
        var filteredEquipment = allEquipment.AsQueryable();

        if (groupId.HasValue)
        {
            filteredEquipment = filteredEquipment.Where(e => e.GroupId == groupId.Value);
        }

        if (!string.IsNullOrEmpty(equipmentType))
        {
            filteredEquipment = filteredEquipment.Where(e => e.EquipmentType.Contains(equipmentType, StringComparison.OrdinalIgnoreCase));
        }

        if (!string.IsNullOrEmpty(status))
        {
            filteredEquipment = filteredEquipment.Where(e => e.Status.Contains(status, StringComparison.OrdinalIgnoreCase));
        }

        if (!string.IsNullOrEmpty(location))
        {
            filteredEquipment = filteredEquipment.Where(e => e.Location.Contains(location, StringComparison.OrdinalIgnoreCase));
        }

        return filteredEquipment.ToList();
    }

    /// <summary>
    /// 設備別センサーデータを取得（ファイルベース実装）
    /// </summary>
    public async Task<List<SensorData>> GetSensorDataByEquipmentAsync(int equipmentId, DateTime? fromDate = null, DateTime? toDate = null)
    {
        var allSensorData = await GetSensorDataAsync();
        var allSensors = await GetSensorsAsync();
        
        // 指定された設備のセンサーIDを取得
        var equipmentSensorIds = allSensors
            .Where(s => s.EquipmentId == equipmentId)
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

        return filteredData.OrderByDescending(sd => sd.Timestamp).ToList();
    }
}
}