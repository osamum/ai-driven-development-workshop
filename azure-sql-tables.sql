-- ===============================================
-- 工場設備管理システム - Azure SQL Database テーブル作成スクリプト
-- Database Version: Azure SQL Database v12
-- Generated Date: 2024-06-24
-- ===============================================

-- データベース照合順序の設定（日本語対応）
-- ALTER DATABASE [DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- ALTER DATABASE [DatabaseName] COLLATE Japanese_CI_AS;
-- ALTER DATABASE [DatabaseName] SET MULTI_USER;

-- ===============================================
-- 1. 設備関連テーブル
-- ===============================================

-- 設備グループテーブル
CREATE TABLE EquipmentGroup (
    group_id INT IDENTITY(1,1) PRIMARY KEY,
    group_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_EquipmentGroup_group_name CHECK (LEN(TRIM(group_name)) > 0)
);

-- 設備テーブル
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    group_id INT NOT NULL,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type NVARCHAR(50) NOT NULL,
    model_number NVARCHAR(50),
    serial_number NVARCHAR(50),
    manufacturer NVARCHAR(100),
    installation_date DATE,
    location NVARCHAR(200),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Equipment_EquipmentGroup FOREIGN KEY (group_id) REFERENCES EquipmentGroup(group_id),
    CONSTRAINT CK_Equipment_equipment_name CHECK (LEN(TRIM(equipment_name)) > 0),
    CONSTRAINT CK_Equipment_status CHECK (status IN ('Active', 'Inactive', 'Maintenance', 'Decommissioned'))
);

-- センサーテーブル
CREATE TABLE Sensor (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_name NVARCHAR(100) NOT NULL,
    sensor_type NVARCHAR(50) NOT NULL,
    measurement_unit NVARCHAR(20),
    min_value DECIMAL(18,6),
    max_value DECIMAL(18,6),
    normal_min DECIMAL(18,6),
    normal_max DECIMAL(18,6),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Sensor_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT CK_Sensor_sensor_name CHECK (LEN(TRIM(sensor_name)) > 0),
    CONSTRAINT CK_Sensor_status CHECK (status IN ('Active', 'Inactive', 'Error', 'Calibrating')),
    CONSTRAINT CK_Sensor_value_range CHECK (min_value IS NULL OR max_value IS NULL OR min_value <= max_value),
    CONSTRAINT CK_Sensor_normal_range CHECK (normal_min IS NULL OR normal_max IS NULL OR normal_min <= normal_max)
);

-- センサーデータテーブル（大容量データ対応）
CREATE TABLE SensorData (
    data_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sensor_id INT NOT NULL,
    value DECIMAL(18,6) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Normal',
    timestamp DATETIME2(7) NOT NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_SensorData_Sensor FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id),
    CONSTRAINT CK_SensorData_status CHECK (status IN ('Normal', 'Warning', 'Error', 'Anomaly'))
);

-- 設備状態テーブル
CREATE TABLE EquipmentStatus (
    status_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    operational_status NVARCHAR(20) NOT NULL,
    availability_rate DECIMAL(5,4) CHECK (availability_rate >= 0 AND availability_rate <= 1),
    performance_rate DECIMAL(5,4) CHECK (performance_rate >= 0 AND performance_rate <= 1),
    quality_rate DECIMAL(5,4) CHECK (quality_rate >= 0 AND quality_rate <= 1),
    oee_rate DECIMAL(5,4) CHECK (oee_rate >= 0 AND oee_rate <= 1),
    status_timestamp DATETIME2(7) NOT NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_EquipmentStatus_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT CK_EquipmentStatus_operational_status CHECK (operational_status IN ('Running', 'Stopped', 'Error', 'Maintenance', 'Idle'))
);

-- ===============================================
-- 2. ユーザー関連テーブル
-- ===============================================

-- ユーザー役割テーブル
CREATE TABLE UserRole (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500),
    permissions NVARCHAR(MAX), -- JSON形式で権限情報を格納
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_UserRole_role_name CHECK (LEN(TRIM(role_name)) > 0)
);

-- ユーザーテーブル
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(254) NOT NULL UNIQUE,
    full_name NVARCHAR(100) NOT NULL,
    department NVARCHAR(100),
    phone_number NVARCHAR(20),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    last_login DATETIME2(7),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_User_UserRole FOREIGN KEY (role_id) REFERENCES UserRole(role_id),
    CONSTRAINT CK_User_username CHECK (LEN(TRIM(username)) >= 3),
    CONSTRAINT CK_User_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT CK_User_full_name CHECK (LEN(TRIM(full_name)) > 0),
    CONSTRAINT CK_User_status CHECK (status IN ('Active', 'Inactive', 'Suspended', 'Deleted'))
);

-- ===============================================
-- 3. アラート関連テーブル
-- ===============================================

-- アラート種別テーブル
CREATE TABLE AlertType (
    alert_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500),
    severity NVARCHAR(20) NOT NULL,
    color_code NVARCHAR(7), -- カラーコード（例：#FF0000）
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_AlertType_type_name CHECK (LEN(TRIM(type_name)) > 0),
    CONSTRAINT CK_AlertType_severity CHECK (severity IN ('Critical', 'High', 'Medium', 'Low', 'Info')),
    CONSTRAINT CK_AlertType_color_code CHECK (color_code IS NULL OR color_code LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]')
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
    status NVARCHAR(20) NOT NULL DEFAULT 'Open',
    detected_at DATETIME2(7) NOT NULL,
    acknowledged_at DATETIME2(7),
    resolved_at DATETIME2(7),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Alert_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT FK_Alert_Sensor FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id),
    CONSTRAINT FK_Alert_AlertType FOREIGN KEY (alert_type_id) REFERENCES AlertType(alert_type_id),
    CONSTRAINT FK_Alert_User FOREIGN KEY (assigned_user_id) REFERENCES [User](user_id),
    CONSTRAINT CK_Alert_title CHECK (LEN(TRIM(title)) > 0),
    CONSTRAINT CK_Alert_severity CHECK (severity IN ('Critical', 'High', 'Medium', 'Low', 'Info')),
    CONSTRAINT CK_Alert_status CHECK (status IN ('Open', 'Acknowledged', 'In Progress', 'Resolved', 'Closed', 'Cancelled')),
    CONSTRAINT CK_Alert_dates CHECK (acknowledged_at IS NULL OR acknowledged_at >= detected_at),
    CONSTRAINT CK_Alert_resolve_dates CHECK (resolved_at IS NULL OR acknowledged_at IS NULL OR resolved_at >= acknowledged_at)
);

-- アラート対応テーブル
CREATE TABLE AlertAction (
    action_id INT IDENTITY(1,1) PRIMARY KEY,
    alert_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    action_type NVARCHAR(50) NOT NULL,
    action_description NVARCHAR(MAX),
    action_timestamp DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_AlertAction_Alert FOREIGN KEY (alert_id) REFERENCES Alert(alert_id) ON DELETE CASCADE,
    CONSTRAINT FK_AlertAction_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT CK_AlertAction_action_type CHECK (action_type IN ('Acknowledged', 'Investigation', 'Repair', 'Part Replacement', 'Resolved', 'Escalated', 'Comment'))
);

-- ===============================================
-- 4. 保全関連テーブル
-- ===============================================

-- 保全種別テーブル
CREATE TABLE MaintenanceType (
    maintenance_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500),
    default_duration_hours INT,
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_MaintenanceType_type_name CHECK (LEN(TRIM(type_name)) > 0),
    CONSTRAINT CK_MaintenanceType_duration CHECK (default_duration_hours IS NULL OR default_duration_hours > 0)
);

-- 保全計画テーブル
CREATE TABLE MaintenancePlan (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_type_id INT NOT NULL,
    assigned_user_id INT,
    plan_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    scheduled_start DATETIME2(7) NOT NULL,
    scheduled_end DATETIME2(7) NOT NULL,
    estimated_duration_hours INT,
    priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    status NVARCHAR(20) NOT NULL DEFAULT 'Planned',
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_MaintenancePlan_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT FK_MaintenancePlan_MaintenanceType FOREIGN KEY (maintenance_type_id) REFERENCES MaintenanceType(maintenance_type_id),
    CONSTRAINT FK_MaintenancePlan_User FOREIGN KEY (assigned_user_id) REFERENCES [User](user_id),
    CONSTRAINT CK_MaintenancePlan_plan_name CHECK (LEN(TRIM(plan_name)) > 0),
    CONSTRAINT CK_MaintenancePlan_dates CHECK (scheduled_end > scheduled_start),
    CONSTRAINT CK_MaintenancePlan_duration CHECK (estimated_duration_hours IS NULL OR estimated_duration_hours > 0),
    CONSTRAINT CK_MaintenancePlan_priority CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    CONSTRAINT CK_MaintenancePlan_status CHECK (status IN ('Planned', 'Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Postponed'))
);

-- 保全作業テーブル
CREATE TABLE MaintenanceWork (
    work_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_id INT,
    equipment_id INT NOT NULL,
    technician_id INT,
    actual_start DATETIME2(7),
    actual_end DATETIME2(7),
    actual_duration_hours INT,
    work_description NVARCHAR(MAX),
    findings NVARCHAR(MAX),
    status NVARCHAR(20) NOT NULL DEFAULT 'Not Started',
    cost DECIMAL(15,2),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_MaintenanceWork_MaintenancePlan FOREIGN KEY (plan_id) REFERENCES MaintenancePlan(plan_id),
    CONSTRAINT FK_MaintenanceWork_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT FK_MaintenanceWork_User FOREIGN KEY (technician_id) REFERENCES [User](user_id),
    CONSTRAINT CK_MaintenanceWork_dates CHECK (actual_end IS NULL OR actual_start IS NULL OR actual_end >= actual_start),
    CONSTRAINT CK_MaintenanceWork_duration CHECK (actual_duration_hours IS NULL OR actual_duration_hours >= 0),
    CONSTRAINT CK_MaintenanceWork_status CHECK (status IN ('Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled')),
    CONSTRAINT CK_MaintenanceWork_cost CHECK (cost IS NULL OR cost >= 0)
);

-- 部品テーブル
CREATE TABLE Part (
    part_id INT IDENTITY(1,1) PRIMARY KEY,
    part_number NVARCHAR(50) NOT NULL UNIQUE,
    part_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    manufacturer NVARCHAR(100),
    unit_cost DECIMAL(15,2),
    stock_quantity INT NOT NULL DEFAULT 0,
    min_stock_level INT NOT NULL DEFAULT 0,
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_Part_part_number CHECK (LEN(TRIM(part_number)) > 0),
    CONSTRAINT CK_Part_part_name CHECK (LEN(TRIM(part_name)) > 0),
    CONSTRAINT CK_Part_unit_cost CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT CK_Part_stock_quantity CHECK (stock_quantity >= 0),
    CONSTRAINT CK_Part_min_stock_level CHECK (min_stock_level >= 0),
    CONSTRAINT CK_Part_status CHECK (status IN ('Active', 'Inactive', 'Discontinued'))
);

-- 保全部品使用テーブル
CREATE TABLE MaintenancePartUsage (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    work_id INT NOT NULL,
    part_id INT NOT NULL,
    quantity_used INT NOT NULL,
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    used_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_MaintenancePartUsage_MaintenanceWork FOREIGN KEY (work_id) REFERENCES MaintenanceWork(work_id) ON DELETE CASCADE,
    CONSTRAINT FK_MaintenancePartUsage_Part FOREIGN KEY (part_id) REFERENCES Part(part_id),
    CONSTRAINT CK_MaintenancePartUsage_quantity CHECK (quantity_used > 0),
    CONSTRAINT CK_MaintenancePartUsage_unit_cost CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT CK_MaintenancePartUsage_total_cost CHECK (total_cost IS NULL OR total_cost >= 0)
);

-- ===============================================
-- 5. 分析・レポート関連テーブル
-- ===============================================

-- 分析レポートテーブル
CREATE TABLE AnalyticsReport (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    report_type NVARCHAR(50) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    period_start DATETIME2(7),
    period_end DATETIME2(7),
    report_data NVARCHAR(MAX), -- JSON形式でレポートデータを格納
    file_path NVARCHAR(500),
    generated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_AnalyticsReport_User FOREIGN KEY (created_by_user_id) REFERENCES [User](user_id),
    CONSTRAINT CK_AnalyticsReport_title CHECK (LEN(TRIM(title)) > 0),
    CONSTRAINT CK_AnalyticsReport_type CHECK (report_type IN ('Daily', 'Weekly', 'Monthly', 'Quarterly', 'Annual', 'Custom', 'Alert Summary', 'Equipment Performance', 'Maintenance Report')),
    CONSTRAINT CK_AnalyticsReport_period CHECK (period_end IS NULL OR period_start IS NULL OR period_end >= period_start)
);

-- KPI指標テーブル
CREATE TABLE KPIMetrics (
    metric_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT,
    metric_name NVARCHAR(100) NOT NULL,
    metric_value DECIMAL(18,6) NOT NULL,
    unit NVARCHAR(20),
    measurement_timestamp DATETIME2(7) NOT NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_KPIMetrics_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT CK_KPIMetrics_metric_name CHECK (LEN(TRIM(metric_name)) > 0)
);

-- ===============================================
-- 6. 通知関連テーブル
-- ===============================================

-- 通知種別テーブル
CREATE TABLE NotificationType (
    notification_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_NotificationType_type_name CHECK (LEN(TRIM(type_name)) > 0)
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
    priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    is_read BIT NOT NULL DEFAULT 0,
    sent_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    read_at DATETIME2(7),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Notification_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Notification_NotificationType FOREIGN KEY (notification_type_id) REFERENCES NotificationType(notification_type_id),
    CONSTRAINT FK_Notification_Alert FOREIGN KEY (related_alert_id) REFERENCES Alert(alert_id),
    CONSTRAINT FK_Notification_MaintenancePlan FOREIGN KEY (related_plan_id) REFERENCES MaintenancePlan(plan_id),
    CONSTRAINT CK_Notification_title CHECK (LEN(TRIM(title)) > 0),
    CONSTRAINT CK_Notification_priority CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    CONSTRAINT CK_Notification_read_date CHECK (read_at IS NULL OR is_read = 1)
);

-- ===============================================
-- 7. AI/ML関連テーブル
-- ===============================================

-- 予測モデルテーブル
CREATE TABLE PredictiveModel (
    model_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT,
    model_name NVARCHAR(100) NOT NULL,
    model_type NVARCHAR(50) NOT NULL,
    model_parameters NVARCHAR(MAX), -- JSON形式でモデルパラメーターを格納
    accuracy DECIMAL(5,4),
    trained_at DATETIME2(7),
    last_prediction_at DATETIME2(7),
    status NVARCHAR(20) NOT NULL DEFAULT 'Draft',
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_PredictiveModel_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT CK_PredictiveModel_model_name CHECK (LEN(TRIM(model_name)) > 0),
    CONSTRAINT CK_PredictiveModel_accuracy CHECK (accuracy IS NULL OR (accuracy >= 0 AND accuracy <= 1)),
    CONSTRAINT CK_PredictiveModel_status CHECK (status IN ('Draft', 'Training', 'Active', 'Inactive', 'Deprecated'))
);

-- 予測結果テーブル
CREATE TABLE PredictionResult (
    prediction_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    model_id INT NOT NULL,
    equipment_id INT,
    prediction_type NVARCHAR(50) NOT NULL,
    prediction_value DECIMAL(18,6),
    confidence_score DECIMAL(5,4),
    predicted_failure_date DATETIME2(7),
    recommendation NVARCHAR(MAX),
    prediction_timestamp DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_PredictionResult_PredictiveModel FOREIGN KEY (model_id) REFERENCES PredictiveModel(model_id),
    CONSTRAINT FK_PredictionResult_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT CK_PredictionResult_confidence CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CONSTRAINT CK_PredictionResult_type CHECK (prediction_type IN ('Failure Prediction', 'Remaining Life', 'Performance Degradation', 'Quality Issue', 'Anomaly Detection'))
);

-- ===============================================
-- 8. 外部システム連携テーブル
-- ===============================================

-- 外部システムテーブル
CREATE TABLE ExternalSystem (
    system_id INT IDENTITY(1,1) PRIMARY KEY,
    system_name NVARCHAR(100) NOT NULL UNIQUE,
    system_type NVARCHAR(50) NOT NULL,
    connection_string NVARCHAR(MAX),
    api_endpoint NVARCHAR(500),
    authentication_type NVARCHAR(50),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    last_sync DATETIME2(7),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT CK_ExternalSystem_system_name CHECK (LEN(TRIM(system_name)) > 0),
    CONSTRAINT CK_ExternalSystem_type CHECK (system_type IN ('ERP', 'MES', 'SCADA', 'PLM', 'CRM', 'WMS', 'API')),
    CONSTRAINT CK_ExternalSystem_auth_type CHECK (authentication_type IN ('None', 'Basic', 'Bearer', 'OAuth2', 'API Key', 'Certificate')),
    CONSTRAINT CK_ExternalSystem_status CHECK (status IN ('Active', 'Inactive', 'Error', 'Maintenance'))
);

-- データ同期ログテーブル
CREATE TABLE DataSyncLog (
    sync_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    system_id INT NOT NULL,
    sync_type NVARCHAR(50) NOT NULL,
    sync_start DATETIME2(7) NOT NULL,
    sync_end DATETIME2(7),
    records_processed INT DEFAULT 0,
    records_success INT DEFAULT 0,
    records_failed INT DEFAULT 0,
    error_message NVARCHAR(MAX),
    created_at DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_DataSyncLog_ExternalSystem FOREIGN KEY (system_id) REFERENCES ExternalSystem(system_id),
    CONSTRAINT CK_DataSyncLog_sync_type CHECK (sync_type IN ('Full', 'Incremental', 'Real-time', 'Manual')),
    CONSTRAINT CK_DataSyncLog_records CHECK (records_processed >= 0 AND records_success >= 0 AND records_failed >= 0),
    CONSTRAINT CK_DataSyncLog_record_sum CHECK (records_processed = records_success + records_failed)
);

-- ===============================================
-- インデックス作成
-- ===============================================

-- 設備関連インデックス
CREATE NONCLUSTERED INDEX IX_Equipment_group_id ON Equipment(group_id);
CREATE NONCLUSTERED INDEX IX_Equipment_status ON Equipment(status);
CREATE NONCLUSTERED INDEX IX_Sensor_equipment_id ON Sensor(equipment_id);
CREATE NONCLUSTERED INDEX IX_Sensor_type_status ON Sensor(sensor_type, status);

-- センサーデータの高性能インデックス（時系列データ対応）
CREATE NONCLUSTERED INDEX IX_SensorData_sensor_timestamp ON SensorData(sensor_id, timestamp DESC);
CREATE NONCLUSTERED INDEX IX_SensorData_timestamp ON SensorData(timestamp DESC);
CREATE NONCLUSTERED INDEX IX_EquipmentStatus_equipment_timestamp ON EquipmentStatus(equipment_id, status_timestamp DESC);

-- アラート関連インデックス
CREATE NONCLUSTERED INDEX IX_Alert_equipment_detected ON Alert(equipment_id, detected_at DESC);
CREATE NONCLUSTERED INDEX IX_Alert_status_severity ON Alert(status, severity);
CREATE NONCLUSTERED INDEX IX_Alert_assigned_user ON Alert(assigned_user_id) WHERE assigned_user_id IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_AlertAction_alert_timestamp ON AlertAction(alert_id, action_timestamp DESC);

-- 保全関連インデックス
CREATE NONCLUSTERED INDEX IX_MaintenancePlan_equipment_scheduled ON MaintenancePlan(equipment_id, scheduled_start);
CREATE NONCLUSTERED INDEX IX_MaintenancePlan_status_priority ON MaintenancePlan(status, priority);
CREATE NONCLUSTERED INDEX IX_MaintenanceWork_equipment_dates ON MaintenanceWork(equipment_id, actual_start, actual_end);

-- 通知関連インデックス
CREATE NONCLUSTERED INDEX IX_Notification_user_sent ON Notification(user_id, sent_at DESC);
CREATE NONCLUSTERED INDEX IX_Notification_unread ON Notification(user_id, is_read, sent_at DESC) WHERE is_read = 0;

-- KPI関連インデックス
CREATE NONCLUSTERED INDEX IX_KPIMetrics_equipment_timestamp ON KPIMetrics(equipment_id, measurement_timestamp DESC);
CREATE NONCLUSTERED INDEX IX_KPIMetrics_metric_timestamp ON KPIMetrics(metric_name, measurement_timestamp DESC);

-- 予測関連インデックス
CREATE NONCLUSTERED INDEX IX_PredictionResult_model_timestamp ON PredictionResult(model_id, prediction_timestamp DESC);
CREATE NONCLUSTERED INDEX IX_PredictionResult_equipment_timestamp ON PredictionResult(equipment_id, prediction_timestamp DESC);

-- 外部システム連携インデックス
CREATE NONCLUSTERED INDEX IX_DataSyncLog_system_start ON DataSyncLog(system_id, sync_start DESC);

-- ===============================================
-- データベース設定とパフォーマンス最適化
-- ===============================================

-- 自動統計更新の有効化
-- ALTER DATABASE [DatabaseName] SET AUTO_UPDATE_STATISTICS ON;
-- ALTER DATABASE [DatabaseName] SET AUTO_CREATE_STATISTICS ON;

-- Azure SQL Database固有の設定
-- ALTER DATABASE [DatabaseName] SET QUERY_STORE = ON;
-- ALTER DATABASE [DatabaseName] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);

-- ===============================================
-- 初期データ挿入（サンプル）
-- ===============================================

-- ユーザー役割の初期データ
INSERT INTO UserRole (role_name, description, permissions) VALUES
(N'システム管理者', N'システム全体の管理権限', N'{"admin": true, "read": true, "write": true, "delete": true}'),
(N'設備管理者', N'設備情報の管理権限', N'{"equipment": true, "maintenance": true, "reports": true}'),
(N'保全担当者', N'保全作業の実行権限', N'{"maintenance": true, "alerts": true, "reports": true}'),
(N'製造オペレーター', N'設備監視の読取権限', N'{"monitoring": true, "alerts": true}'),
(N'品質管理者', N'品質データの分析権限', N'{"quality": true, "reports": true, "analytics": true}');

-- アラート種別の初期データ
INSERT INTO AlertType (type_name, description, severity, color_code) VALUES
(N'設備故障', N'設備の故障を検知', 'Critical', '#FF0000'),
(N'異常値検知', N'センサー値の異常を検知', 'High', '#FF8000'),
(N'保全期限', N'保全作業の期限が近づいている', 'Medium', '#FFFF00'),
(N'部品交換', N'部品の交換時期が近づいている', 'Medium', '#00FF00'),
(N'性能低下', N'設備性能の低下を検知', 'Low', '#0080FF');

-- 保全種別の初期データ
INSERT INTO MaintenanceType (type_name, description, default_duration_hours) VALUES
(N'予防保全', N'定期的な予防保全作業', 4),
(N'予知保全', N'AI予測に基づく保全作業', 6),
(N'事後保全', N'故障後の修理作業', 8),
(N'改良保全', N'設備の改良・改善作業', 16),
(N'日常点検', N'日常的な点検作業', 1);

-- 通知種別の初期データ
INSERT INTO NotificationType (type_name, description) VALUES
(N'アラート通知', N'システムアラートの通知'),
(N'保全リマインダー', N'保全作業のリマインダー'),
(N'レポート配信', N'定期レポートの配信'),
(N'システム通知', N'システム関連の通知'),
(N'緊急通知', N'緊急事態の通知');

-- ===============================================
-- スクリプト完了
-- ===============================================
PRINT N'Azure SQL Database テーブル作成スクリプトが正常に完了しました。';
PRINT N'作成されたテーブル数: 18';
PRINT N'作成されたインデックス数: 15';
PRINT N'挿入された初期データ: ユーザー役割(5件), アラート種別(5件), 保全種別(5件), 通知種別(5件)';