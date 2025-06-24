-- 工場設備管理システム - テーブル作成SQL
-- Azure SQL Database用DDLスクリプト

USE FactoryManagementDB;
GO

-- 設備関連テーブル
-- 設備グループテーブル
CREATE TABLE EquipmentGroup (
    group_id INT IDENTITY(1,1) PRIMARY KEY,
    group_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 設備テーブル
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    group_id INT NOT NULL,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type NVARCHAR(50) NOT NULL,
    model_number NVARCHAR(100),
    serial_number NVARCHAR(100),
    manufacturer NVARCHAR(100),
    installation_date DATE,
    location NVARCHAR(200),
    status NVARCHAR(20) DEFAULT 'Active',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (group_id) REFERENCES EquipmentGroup(group_id)
);

-- センサーテーブル
CREATE TABLE Sensor (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_name NVARCHAR(100) NOT NULL,
    sensor_type NVARCHAR(50) NOT NULL,
    measurement_unit NVARCHAR(20),
    min_value DECIMAL(18,4),
    max_value DECIMAL(18,4),
    normal_min DECIMAL(18,4),
    normal_max DECIMAL(18,4),
    status NVARCHAR(20) DEFAULT 'Active',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- センサーデータテーブル
CREATE TABLE SensorData (
    data_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sensor_id INT NOT NULL,
    value DECIMAL(18,4) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Normal',
    timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id)
);

-- 設備状態テーブル
CREATE TABLE EquipmentStatus (
    status_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    operational_status NVARCHAR(20) NOT NULL,
    availability_rate DECIMAL(5,2),
    performance_rate DECIMAL(5,2),
    quality_rate DECIMAL(5,2),
    oee_rate DECIMAL(5,2),
    status_timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- ユーザー関連テーブル
-- ユーザー役割テーブル
CREATE TABLE UserRole (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(200),
    permissions NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- ユーザーテーブル
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    full_name NVARCHAR(100) NOT NULL,
    department NVARCHAR(50),
    phone_number NVARCHAR(20),
    status NVARCHAR(20) DEFAULT 'Active',
    last_login DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (role_id) REFERENCES UserRole(role_id)
);

-- アラート関連テーブル
-- アラート種別テーブル
CREATE TABLE AlertType (
    alert_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(200),
    severity NVARCHAR(20) NOT NULL,
    color_code NVARCHAR(7),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- アラートテーブル
CREATE TABLE Alert (
    alert_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_id INT,
    alert_type_id INT NOT NULL,
    assigned_user_id INT,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    severity NVARCHAR(20) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Open',
    detected_at DATETIME2 NOT NULL,
    acknowledged_at DATETIME2,
    resolved_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id),
    FOREIGN KEY (alert_type_id) REFERENCES AlertType(alert_type_id),
    FOREIGN KEY (assigned_user_id) REFERENCES [User](user_id)
);

-- アラート対応テーブル
CREATE TABLE AlertAction (
    action_id INT IDENTITY(1,1) PRIMARY KEY,
    alert_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    action_type NVARCHAR(50) NOT NULL,
    action_description NVARCHAR(MAX),
    action_timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (alert_id) REFERENCES Alert(alert_id),
    FOREIGN KEY (user_id) REFERENCES [User](user_id)
);

-- 保全関連テーブル
-- 保全種別テーブル
CREATE TABLE MaintenanceType (
    maintenance_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(200),
    default_duration_hours INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 保全計画テーブル
CREATE TABLE MaintenancePlan (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    assigned_user_id INT NOT NULL,
    plan_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    scheduled_start DATETIME2 NOT NULL,
    scheduled_end DATETIME2 NOT NULL,
    estimated_duration_hours INT,
    priority NVARCHAR(20) DEFAULT 'Normal',
    status NVARCHAR(20) DEFAULT 'Scheduled',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (maintenance_type_id) REFERENCES MaintenanceType(maintenance_type_id),
    FOREIGN KEY (assigned_user_id) REFERENCES [User](user_id)
);

-- 保全作業テーブル
CREATE TABLE MaintenanceWork (
    work_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_id INT NOT NULL,
    equipment_id INT NOT NULL,
    technician_id INT NOT NULL,
    actual_start DATETIME2,
    actual_end DATETIME2,
    actual_duration_hours INT,
    work_description NVARCHAR(MAX),
    findings NVARCHAR(MAX),
    status NVARCHAR(20) DEFAULT 'Planned',
    cost DECIMAL(18,2),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (plan_id) REFERENCES MaintenancePlan(plan_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (technician_id) REFERENCES [User](user_id)
);

-- 部品テーブル
CREATE TABLE Part (
    part_id INT IDENTITY(1,1) PRIMARY KEY,
    part_number NVARCHAR(50) NOT NULL UNIQUE,
    part_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    manufacturer NVARCHAR(100),
    unit_cost DECIMAL(18,2),
    stock_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 0,
    status NVARCHAR(20) DEFAULT 'Active',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 保全部品使用テーブル
CREATE TABLE MaintenancePartUsage (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    work_id INT NOT NULL,
    part_id INT NOT NULL,
    quantity_used INT NOT NULL,
    unit_cost DECIMAL(18,2),
    total_cost DECIMAL(18,2),
    used_at DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (work_id) REFERENCES MaintenanceWork(work_id),
    FOREIGN KEY (part_id) REFERENCES Part(part_id)
);

-- 分析・レポート関連テーブル
-- 分析レポートテーブル
CREATE TABLE AnalyticsReport (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    report_type NVARCHAR(50) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    period_start DATETIME2,
    period_end DATETIME2,
    report_data NVARCHAR(MAX),
    file_path NVARCHAR(500),
    generated_at DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (created_by_user_id) REFERENCES [User](user_id)
);

-- KPI指標テーブル
CREATE TABLE KPIMetrics (
    metric_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    metric_name NVARCHAR(100) NOT NULL,
    metric_value DECIMAL(18,4) NOT NULL,
    unit NVARCHAR(20),
    measurement_timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- 通知関連テーブル
-- 通知種別テーブル
CREATE TABLE NotificationType (
    notification_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(200),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 通知テーブル
CREATE TABLE Notification (
    notification_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type_id INT NOT NULL,
    related_alert_id BIGINT,
    related_plan_id INT,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(MAX),
    priority NVARCHAR(20) DEFAULT 'Normal',
    is_read BIT DEFAULT 0,
    sent_at DATETIME2 NOT NULL,
    read_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES [User](user_id),
    FOREIGN KEY (notification_type_id) REFERENCES NotificationType(notification_type_id),
    FOREIGN KEY (related_alert_id) REFERENCES Alert(alert_id),
    FOREIGN KEY (related_plan_id) REFERENCES MaintenancePlan(plan_id)
);

-- AI/ML関連テーブル
-- 予測モデルテーブル
CREATE TABLE PredictiveModel (
    model_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    model_name NVARCHAR(100) NOT NULL,
    model_type NVARCHAR(50) NOT NULL,
    model_parameters NVARCHAR(MAX),
    accuracy DECIMAL(5,4),
    trained_at DATETIME2,
    last_prediction_at DATETIME2,
    status NVARCHAR(20) DEFAULT 'Active',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- 予測結果テーブル
CREATE TABLE PredictionResult (
    prediction_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    model_id INT NOT NULL,
    equipment_id INT NOT NULL,
    prediction_type NVARCHAR(50) NOT NULL,
    prediction_value DECIMAL(18,4),
    confidence_score DECIMAL(5,4),
    predicted_failure_date DATETIME2,
    recommendation NVARCHAR(MAX),
    prediction_timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (model_id) REFERENCES PredictiveModel(model_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- 外部システム連携テーブル
-- 外部システムテーブル
CREATE TABLE ExternalSystem (
    system_id INT IDENTITY(1,1) PRIMARY KEY,
    system_name NVARCHAR(100) NOT NULL,
    system_type NVARCHAR(50) NOT NULL,
    connection_string NVARCHAR(MAX),
    api_endpoint NVARCHAR(500),
    authentication_type NVARCHAR(50),
    status NVARCHAR(20) DEFAULT 'Active',
    last_sync DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- データ同期ログテーブル
CREATE TABLE DataSyncLog (
    sync_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    system_id INT NOT NULL,
    sync_type NVARCHAR(50) NOT NULL,
    sync_start DATETIME2 NOT NULL,
    sync_end DATETIME2,
    records_processed INT DEFAULT 0,
    records_success INT DEFAULT 0,
    records_failed INT DEFAULT 0,
    error_message NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (system_id) REFERENCES ExternalSystem(system_id)
);

-- インデックス作成
-- センサーデータ用インデックス（時系列データ用）
CREATE INDEX IX_SensorData_Timestamp ON SensorData(timestamp DESC);
CREATE INDEX IX_SensorData_SensorId_Timestamp ON SensorData(sensor_id, timestamp DESC);

-- 設備状態用インデックス
CREATE INDEX IX_EquipmentStatus_EquipmentId_Timestamp ON EquipmentStatus(equipment_id, status_timestamp DESC);

-- アラート用インデックス
CREATE INDEX IX_Alert_Status_DetectedAt ON Alert(status, detected_at DESC);
CREATE INDEX IX_Alert_EquipmentId_Status ON Alert(equipment_id, status);

-- KPI指標用インデックス
CREATE INDEX IX_KPIMetrics_EquipmentId_Timestamp ON KPIMetrics(equipment_id, measurement_timestamp DESC);

-- 通知用インデックス
CREATE INDEX IX_Notification_UserId_IsRead ON Notification(user_id, is_read);

PRINT 'テーブル作成が完了しました。';