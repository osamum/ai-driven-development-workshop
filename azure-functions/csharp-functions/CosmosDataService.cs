using Microsoft.Azure.Cosmos;
using FactoryManagementApi.Models;
using System.Text.Json;

namespace FactoryManagementApi.Services
{
    /// <summary>
    /// Azure Cosmos DB を使用したデータアクセスサービス
    /// </summary>
    public class CosmosDataService : IDataService
    {
        private readonly CosmosClient _cosmosClient;
        private readonly Database _database;
        private readonly Container _equipmentContainer;
        private readonly Container _groupsContainer;
        private readonly Container _sensorsContainer;
        private readonly Container _sensorDataContainer;
        private readonly Container _usersContainer;
        private readonly Container _alertsContainer;

        public CosmosDataService(string connectionString, string databaseName)
        {
            _cosmosClient = new CosmosClient(connectionString);
            _database = _cosmosClient.GetDatabase(databaseName);
            
            // コンテナーへの参照を取得
            _equipmentContainer = _database.GetContainer("Equipment");
            _groupsContainer = _database.GetContainer("EquipmentGroups");
            _sensorsContainer = _database.GetContainer("Sensors");
            _sensorDataContainer = _database.GetContainer("SensorData");
            _usersContainer = _database.GetContainer("Users");
            _alertsContainer = _database.GetContainer("Alerts");
        }

        public async Task<List<EquipmentGroup>> GetEquipmentGroupsAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c");
                var iterator = _groupsContainer.GetItemQueryIterator<dynamic>(query);
                var groups = new List<EquipmentGroup>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        groups.Add(new EquipmentGroup
                        {
                            GroupId = (int)item.group_id,
                            GroupName = (string)item.group_name,
                            Description = (string)item.description,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return groups;
            }
            catch (Exception ex)
            {
                throw new Exception($"設備グループデータの取得に失敗しました: {ex.Message}", ex);
            }
        }

        public async Task<List<Equipment>> GetEquipmentAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c");
                var iterator = _equipmentContainer.GetItemQueryIterator<dynamic>(query);
                var equipment = new List<Equipment>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        equipment.Add(new Equipment
                        {
                            EquipmentId = (int)item.equipment_id,
                            GroupId = (int)item.group_id,
                            EquipmentName = (string)item.equipment_name,
                            EquipmentType = (string)item.equipment_type,
                            ModelNumber = (string)item.model_number,
                            SerialNumber = (string)item.serial_number,
                            Manufacturer = (string)item.manufacturer,
                            InstallationDate = DateTime.Parse((string)item.installation_date),
                            Location = (string)item.location,
                            Status = (string)item.status,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return equipment;
            }
            catch (Exception ex)
            {
                throw new Exception($"設備データの取得に失敗しました: {ex.Message}", ex);
            }
        }

        public async Task<List<Sensor>> GetSensorsAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c");
                var iterator = _sensorsContainer.GetItemQueryIterator<dynamic>(query);
                var sensors = new List<Sensor>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        sensors.Add(new Sensor
                        {
                            SensorId = (int)item.sensor_id,
                            EquipmentId = (int)item.equipment_id,
                            SensorName = (string)item.sensor_name,
                            SensorType = (string)item.sensor_type,
                            MeasurementUnit = (string)item.measurement_unit,
                            MinValue = (decimal)item.min_value,
                            MaxValue = (decimal)item.max_value,
                            NormalMin = (decimal)item.normal_min,
                            NormalMax = (decimal)item.normal_max,
                            Status = (string)item.status,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return sensors;
            }
            catch (Exception ex)
            {
                throw new Exception($"センサーデータの取得に失敗しました: {ex.Message}", ex);
            }
        }

        public async Task<List<SensorData>> GetSensorDataAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c ORDER BY c.timestamp DESC");
                var iterator = _sensorDataContainer.GetItemQueryIterator<dynamic>(query);
                var sensorData = new List<SensorData>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        sensorData.Add(new SensorData
                        {
                            DataId = (long)item.data_id,
                            SensorId = (int)item.sensor_id,
                            Value = (decimal)item.value,
                            Status = (string)item.status,
                            Timestamp = DateTime.Parse((string)item.timestamp),
                            CreatedAt = DateTime.Parse((string)item.created_at)
                        });
                    }
                }

                return sensorData;
            }
            catch (Exception ex)
            {
                throw new Exception($"センサーデータの取得に失敗しました: {ex.Message}", ex);
            }
        }

        public async Task<List<FactoryManagementApi.Models.User>> GetUsersAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c");
                var iterator = _usersContainer.GetItemQueryIterator<dynamic>(query);
                var users = new List<FactoryManagementApi.Models.User>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        users.Add(new FactoryManagementApi.Models.User
                        {
                            UserId = (int)item.user_id,
                            RoleId = (int)item.role_id,
                            Username = (string)item.username,
                            Email = (string)item.email,
                            FullName = (string)item.full_name,
                            Department = (string)item.department,
                            PhoneNumber = (string)item.phone_number,
                            Status = (string)item.status,
                            LastLogin = item.last_login != null ? DateTime.Parse((string)item.last_login) : null,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return users;
            }
            catch (Exception ex)
            {
                throw new Exception($"ユーザーデータの取得に失敗しました: {ex.Message}", ex);
            }
        }

        public async Task<List<Alert>> GetAlertsAsync()
        {
            try
            {
                var query = new QueryDefinition("SELECT * FROM c ORDER BY c.triggered_at DESC");
                var iterator = _alertsContainer.GetItemQueryIterator<dynamic>(query);
                var alerts = new List<Alert>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        alerts.Add(new Alert
                        {
                            AlertId = (long)item.alert_id,
                            EquipmentId = (int)item.equipment_id,
                            SensorId = (int)item.sensor_id,
                            AlertTypeId = (int)item.alert_type_id,
                            Severity = (string)item.severity,
                            Message = (string)item.message,
                            TriggeredAt = DateTime.Parse((string)item.triggered_at),
                            Status = (string)item.status,
                            AssignedTo = item.assigned_to != null ? (int)item.assigned_to : null,
                            AcknowledgedAt = item.acknowledged_at != null ? DateTime.Parse((string)item.acknowledged_at) : null,
                            ResolvedAt = item.resolved_at != null ? DateTime.Parse((string)item.resolved_at) : null,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return alerts;
            }
            catch (Exception ex)
            {
                throw new Exception($"アラートデータの取得に失敗しました: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// フィルタリング条件付きで設備データを取得
        /// </summary>
        public async Task<List<Equipment>> GetEquipmentWithFiltersAsync(
            int? groupId = null, 
            string? equipmentType = null, 
            string? status = null, 
            string? location = null)
        {
            try
            {
                var queryText = "SELECT * FROM c WHERE 1=1";
                var parameters = new List<(string Name, object Value)>();

                if (groupId.HasValue)
                {
                    queryText += " AND c.group_id = @groupId";
                    parameters.Add(("@groupId", groupId.Value));
                }

                if (!string.IsNullOrEmpty(equipmentType))
                {
                    queryText += " AND CONTAINS(UPPER(c.equipment_type), UPPER(@equipmentType))";
                    parameters.Add(("@equipmentType", equipmentType));
                }

                if (!string.IsNullOrEmpty(status))
                {
                    queryText += " AND CONTAINS(UPPER(c.status), UPPER(@status))";
                    parameters.Add(("@status", status));
                }

                if (!string.IsNullOrEmpty(location))
                {
                    queryText += " AND CONTAINS(UPPER(c.location), UPPER(@location))";
                    parameters.Add(("@location", location));
                }

                var query = new QueryDefinition(queryText);
                foreach (var param in parameters)
                {
                    query.WithParameter(param.Name, param.Value);
                }

                var iterator = _equipmentContainer.GetItemQueryIterator<dynamic>(query);
                var equipment = new List<Equipment>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        equipment.Add(new Equipment
                        {
                            EquipmentId = (int)item.equipment_id,
                            GroupId = (int)item.group_id,
                            EquipmentName = (string)item.equipment_name,
                            EquipmentType = (string)item.equipment_type,
                            ModelNumber = (string)item.model_number,
                            SerialNumber = (string)item.serial_number,
                            Manufacturer = (string)item.manufacturer,
                            InstallationDate = DateTime.Parse((string)item.installation_date),
                            Location = (string)item.location,
                            Status = (string)item.status,
                            CreatedAt = DateTime.Parse((string)item.created_at),
                            UpdatedAt = DateTime.Parse((string)item.updated_at)
                        });
                    }
                }

                return equipment;
            }
            catch (Exception ex)
            {
                throw new Exception($"フィルタリング付き設備データの取得に失敗しました: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 指定された設備IDに関連するセンサーデータを取得
        /// </summary>
        public async Task<List<SensorData>> GetSensorDataByEquipmentAsync(int equipmentId, DateTime? fromDate = null, DateTime? toDate = null)
        {
            try
            {
                var queryText = @"
                    SELECT sd.* FROM sd 
                    JOIN s IN sd.sensors 
                    WHERE s.equipment_id = @equipmentId";
                
                var parameters = new List<(string Name, object Value)>
                {
                    ("@equipmentId", equipmentId)
                };

                if (fromDate.HasValue)
                {
                    queryText += " AND sd.timestamp >= @fromDate";
                    parameters.Add(("@fromDate", fromDate.Value.ToString("yyyy-MM-ddTHH:mm:ssZ")));
                }

                if (toDate.HasValue)
                {
                    queryText += " AND sd.timestamp <= @toDate";
                    parameters.Add(("@toDate", toDate.Value.ToString("yyyy-MM-ddTHH:mm:ssZ")));
                }

                queryText += " ORDER BY sd.timestamp DESC";

                var query = new QueryDefinition(queryText);
                foreach (var param in parameters)
                {
                    query.WithParameter(param.Name, param.Value);
                }

                var iterator = _sensorDataContainer.GetItemQueryIterator<dynamic>(query);
                var sensorData = new List<SensorData>();

                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    foreach (var item in response)
                    {
                        sensorData.Add(new SensorData
                        {
                            DataId = (long)item.data_id,
                            SensorId = (int)item.sensor_id,
                            Value = (decimal)item.value,
                            Status = (string)item.status,
                            Timestamp = DateTime.Parse((string)item.timestamp),
                            CreatedAt = DateTime.Parse((string)item.created_at)
                        });
                    }
                }

                return sensorData;
            }
            catch (Exception ex)
            {
                throw new Exception($"設備別センサーデータの取得に失敗しました: {ex.Message}", ex);
            }
        }
    }
}