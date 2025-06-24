-- 工場設備管理システム - サンプルデータ挿入SQL
-- Azure SQL Database用サンプルデータスクリプト

USE FactoryManagementDB;
GO

-- 設備グループデータ
INSERT INTO EquipmentGroup (group_name, description) VALUES
('製造ライン1', '第1製造ラインの設備群'),
('製造ライン2', '第2製造ラインの設備群'),
('品質管理', '品質管理関連設備'),
('電力システム', '電力供給・管理システム'),
('空調システム', '工場内空調管理システム');

-- 設備データ
INSERT INTO Equipment (group_id, equipment_name, equipment_type, model_number, serial_number, manufacturer, installation_date, location, status) VALUES
(1, 'プレス機A-001', 'プレス機', 'PM-2000X', 'PM2000X-001', 'ABC機械工業', '2020-01-15', '工場A棟-1F-製造ライン1', 'Active'),
(1, '射出成型機B-001', '射出成型機', 'IM-500Z', 'IM500Z-001', 'XYZ産業機械', '2019-06-20', '工場A棟-1F-製造ライン1', 'Active'),
(1, 'コンベア1-001', 'コンベアベルト', 'CB-100M', 'CB100M-001', 'コンベア技研', '2020-03-10', '工場A棟-1F-製造ライン1', 'Active'),
(2, 'プレス機A-002', 'プレス機', 'PM-2000X', 'PM2000X-002', 'ABC機械工業', '2020-02-10', '工場A棟-1F-製造ライン2', 'Active'),
(2, '射出成型機B-002', '射出成型機', 'IM-500Z', 'IM500Z-002', 'XYZ産業機械', '2019-07-25', '工場A棟-1F-製造ライン2', 'Active'),
(3, '品質検査機Q-001', '品質検査装置', 'QI-300A', 'QI300A-001', '品質機器メーカー', '2020-05-15', '工場A棟-2F-品質管理室', 'Active'),
(4, '変電設備P-001', '変電設備', 'PS-1000KV', 'PS1000KV-001', '電力機器株式会社', '2018-12-01', '工場A棟-B1F-電気室', 'Active'),
(5, '空調機AC-001', '空調設備', 'AC-5000', 'AC5000-001', '空調システムズ', '2019-04-01', '工場A棟-屋上', 'Active');

-- センサーデータ
INSERT INTO Sensor (equipment_id, sensor_name, sensor_type, measurement_unit, min_value, max_value, normal_min, normal_max, status) VALUES
(1, '温度センサー', 'Temperature', '℃', -10, 100, 20, 60, 'Active'),
(1, '振動センサー', 'Vibration', 'mm/s', 0, 50, 0, 10, 'Active'),
(1, '圧力センサー', 'Pressure', 'MPa', 0, 20, 5, 15, 'Active'),
(2, '温度センサー', 'Temperature', '℃', -10, 150, 50, 120, 'Active'),
(2, '流量センサー', 'Flow', 'L/min', 0, 100, 10, 80, 'Active'),
(3, '振動センサー', 'Vibration', 'mm/s', 0, 30, 0, 5, 'Active'),
(3, '電流センサー', 'Current', 'A', 0, 100, 10, 50, 'Active'),
(4, '温度センサー', 'Temperature', '℃', -10, 100, 20, 60, 'Active'),
(4, '振動センサー', 'Vibration', 'mm/s', 0, 50, 0, 10, 'Active'),
(5, '温度センサー', 'Temperature', '℃', -10, 150, 50, 120, 'Active'),
(6, '精度センサー', 'Precision', 'μm', 0, 100, 0, 10, 'Active'),
(7, '電圧センサー', 'Voltage', 'V', 0, 500, 200, 240, 'Active'),
(7, '電流センサー', 'Current', 'A', 0, 1000, 100, 800, 'Active'),
(8, '温度センサー', 'Temperature', '℃', -20, 50, 18, 26, 'Active'),
(8, '湿度センサー', 'Humidity', '%', 0, 100, 40, 60, 'Active');

-- ユーザー役割データ
INSERT INTO UserRole (role_name, description, permissions) VALUES
('システム管理者', 'システム全体の管理権限', '{"admin": true, "read": true, "write": true, "delete": true}'),
('設備管理者', '設備の監視・管理権限', '{"equipment": true, "read": true, "write": true, "maintenance": true}'),
('保全担当者', '保全作業の実施権限', '{"maintenance": true, "read": true, "write": true}'),
('品質管理者', '品質データの確認・分析権限', '{"quality": true, "read": true, "analytics": true}'),
('オペレーター', '基本的な監視・操作権限', '{"monitor": true, "read": true}');

-- ユーザーデータ
INSERT INTO [User] (role_id, username, email, full_name, department, phone_number, status) VALUES
(1, 'admin', 'admin@factory.com', '山田太郎', 'システム部', '03-1234-5678', 'Active'),
(2, 'equipment_mgr1', 'equipment1@factory.com', '佐藤花子', '設備管理部', '03-1234-5679', 'Active'),
(2, 'equipment_mgr2', 'equipment2@factory.com', '田中次郎', '設備管理部', '03-1234-5680', 'Active'),
(3, 'maintenance1', 'maint1@factory.com', '鈴木一郎', '保全部', '03-1234-5681', 'Active'),
(3, 'maintenance2', 'maint2@factory.com', '高橋三郎', '保全部', '03-1234-5682', 'Active'),
(4, 'quality_mgr', 'quality@factory.com', '伊藤美咲', '品質管理部', '03-1234-5683', 'Active'),
(5, 'operator1', 'op1@factory.com', '渡辺五郎', '製造部', '03-1234-5684', 'Active'),
(5, 'operator2', 'op2@factory.com', '中村六子', '製造部', '03-1234-5685', 'Active');

-- アラート種別データ
INSERT INTO AlertType (type_name, description, severity, color_code) VALUES
('温度異常', '設備の温度が正常範囲を超えた場合', 'High', '#FF0000'),
('振動異常', '設備の振動が正常範囲を超えた場合', 'High', '#FF6600'),
('故障予兆', 'AIによる故障予兆の検知', 'Medium', '#FFCC00'),
('保全期限', '保全作業の期限が近づいている', 'Medium', '#0066FF'),
('電力異常', '電力系統の異常検知', 'Critical', '#CC0000'),
('品質異常', '品質基準を下回る製品の検出', 'High', '#FF3300');

-- 保全種別データ
INSERT INTO MaintenanceType (type_name, description, default_duration_hours) VALUES
('定期保全', '定期的に実施する予防保全', 4),
('予知保全', 'AIによる予測に基づく保全', 6),
('緊急保全', '故障発生時の緊急対応', 8),
('オーバーホール', '設備の大規模メンテナンス', 24),
('部品交換', '消耗部品の交換作業', 2);

-- 部品データ
INSERT INTO Part (part_number, part_name, description, manufacturer, unit_cost, stock_quantity, min_stock_level, status) VALUES
('PART-001', 'オイルフィルター', 'プレス機用オイルフィルター', 'フィルター工業', 1500.00, 50, 10, 'Active'),
('PART-002', 'ベアリング', '高精度ベアリング 6208', 'ベアリング製作所', 8000.00, 30, 5, 'Active'),
('PART-003', 'Vベルト', 'コンベア用Vベルト A-120', 'ベルト技研', 3200.00, 20, 3, 'Active'),
('PART-004', '温度センサー', '熱電対温度センサー K型', 'センサー技術', 12000.00, 15, 3, 'Active'),
('PART-005', '油圧ホース', '高圧油圧ホース 10m', 'ホース工業', 5500.00, 25, 5, 'Active'),
('PART-006', 'モーター', 'ACサーボモーター 1kW', 'モーター株式会社', 45000.00, 8, 2, 'Active'),
('PART-007', 'シール材', 'Oリングセット', 'シール工業', 800.00, 100, 20, 'Active'),
('PART-008', '制御基板', 'PLC制御基板', '制御技術', 80000.00, 5, 1, 'Active');

-- 通知種別データ
INSERT INTO NotificationType (type_name, description) VALUES
('アラート通知', 'システムアラートの通知'),
('保全通知', '保全作業に関する通知'),
('レポート通知', 'レポート生成完了の通知'),
('システム通知', 'システムメンテナンス等の通知');

-- 外部システムデータ
INSERT INTO ExternalSystem (system_name, system_type, connection_string, api_endpoint, authentication_type, status) VALUES
('生産管理システム', 'ERP', 'Server=erp.company.com;Database=Production;', 'https://erp.company.com/api/v1', 'OAuth2', 'Active'),
('SCADA システム', 'SCADA', 'OPC.TCP://scada.factory.local:4840', 'opc.tcp://scada.factory.local:4840', 'Certificate', 'Active'),
('在庫管理システム', 'WMS', 'Server=wms.company.com;Database=Inventory;', 'https://wms.company.com/api/v2', 'ApiKey', 'Active');

-- センサーデータのサンプル挿入（最近1週間分）
DECLARE @StartDate DATETIME2 = DATEADD(DAY, -7, GETDATE());
DECLARE @EndDate DATETIME2 = GETDATE();
DECLARE @CurrentDate DATETIME2 = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- プレス機A-001の温度データ
    INSERT INTO SensorData (sensor_id, value, status, timestamp)
    VALUES (1, 45.5 + (RAND() * 10 - 5), 'Normal', @CurrentDate);
    
    -- プレス機A-001の振動データ
    INSERT INTO SensorData (sensor_id, value, status, timestamp)
    VALUES (2, 3.2 + (RAND() * 2 - 1), 'Normal', @CurrentDate);
    
    -- 射出成型機B-001の温度データ
    INSERT INTO SensorData (sensor_id, value, status, timestamp)
    VALUES (4, 85.0 + (RAND() * 20 - 10), 'Normal', @CurrentDate);
    
    SET @CurrentDate = DATEADD(HOUR, 1, @CurrentDate);
END;

-- 設備状態データのサンプル挿入
INSERT INTO EquipmentStatus (equipment_id, operational_status, availability_rate, performance_rate, quality_rate, oee_rate, status_timestamp) VALUES
(1, 'Running', 95.5, 88.2, 99.1, 83.4, DATEADD(HOUR, -1, GETDATE())),
(2, 'Running', 92.8, 85.6, 98.5, 78.3, DATEADD(HOUR, -1, GETDATE())),
(3, 'Running', 98.2, 92.1, 99.8, 90.3, DATEADD(HOUR, -1, GETDATE())),
(4, 'Running', 94.1, 87.9, 99.2, 82.1, DATEADD(HOUR, -1, GETDATE())),
(5, 'Running', 91.5, 84.3, 97.8, 75.5, DATEADD(HOUR, -1, GETDATE()));

-- アラートデータ
INSERT INTO Alert (equipment_id, sensor_id, alert_type_id, assigned_user_id, title, description, severity, status, detected_at) VALUES
(1, 1, 1, 2, 'プレス機A-001 温度異常', 'プレス機A-001の温度が65℃を超えました', 'High', 'Open', DATEADD(HOUR, -2, GETDATE())),
(2, 4, 3, 2, '射出成型機B-001 故障予兆', 'AIモデルが3日以内の故障可能性を検知しました', 'Medium', 'Investigating', DATEADD(HOUR, -4, GETDATE())),
(7, 12, 5, 3, '変電設備P-001 電流異常', '変電設備の電流値が正常範囲を超過しています', 'Critical', 'Open', DATEADD(HOUR, -1, GETDATE()));

-- アラート対応データ
INSERT INTO AlertAction (alert_id, user_id, action_type, action_description, action_timestamp) VALUES
(1, 2, 'Acknowledged', '温度異常を確認しました。現場にて詳細調査を開始します。', DATEADD(MINUTE, -30, GETDATE())),
(2, 2, 'Acknowledged', 'AI予測アラートを確認しました。保全計画を調整します。', DATEADD(HOUR, -3, GETDATE())),
(3, 3, 'Acknowledged', '電流異常を確認しました。緊急点検を実施します。', DATEADD(MINUTE, -10, GETDATE()));

-- 保全計画データ
INSERT INTO MaintenancePlan (equipment_id, maintenance_type_id, assigned_user_id, plan_name, description, scheduled_start, scheduled_end, estimated_duration_hours, priority, status) VALUES
(1, 1, 4, 'プレス機A-001 定期保全', 'プレス機A-001の月次定期保全作業', DATEADD(DAY, 3, GETDATE()), DATEADD(DAY, 3, DATEADD(HOUR, 4, GETDATE())), 4, 'Normal', 'Scheduled'),
(2, 2, 4, '射出成型機B-001 予知保全', 'AI予測に基づく早期保全実施', DATEADD(DAY, 1, GETDATE()), DATEADD(DAY, 1, DATEADD(HOUR, 6, GETDATE())), 6, 'High', 'Scheduled'),
(3, 1, 5, 'コンベア1-001 定期保全', 'コンベアベルトの定期点検・調整', DATEADD(DAY, 7, GETDATE()), DATEADD(DAY, 7, DATEADD(HOUR, 4, GETDATE())), 4, 'Normal', 'Scheduled');

-- 保全作業データ
INSERT INTO MaintenanceWork (plan_id, equipment_id, technician_id, actual_start, actual_end, actual_duration_hours, work_description, findings, status, cost) VALUES
(1, 1, 4, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, DATEADD(HOUR, 3, GETDATE())), 3, 'プレス機A-001の定期保全を実施。オイル交換、フィルター清掃、各部点検を実行。', '特に異常は見つからず。次回保全まで正常稼働可能。', 'Completed', 15000.00);

-- 保全部品使用データ
INSERT INTO MaintenancePartUsage (work_id, part_id, quantity_used, unit_cost, total_cost, used_at) VALUES
(1, 1, 2, 1500.00, 3000.00, DATEADD(DAY, -7, GETDATE())),
(1, 7, 1, 800.00, 800.00, DATEADD(DAY, -7, GETDATE()));

-- KPI指標データ
INSERT INTO KPIMetrics (equipment_id, metric_name, metric_value, unit, measurement_timestamp) VALUES
(1, 'OEE', 83.4, '%', DATEADD(HOUR, -1, GETDATE())),
(1, '稼働率', 95.5, '%', DATEADD(HOUR, -1, GETDATE())),
(1, '性能率', 88.2, '%', DATEADD(HOUR, -1, GETDATE())),
(1, '品質率', 99.1, '%', DATEADD(HOUR, -1, GETDATE())),
(2, 'OEE', 78.3, '%', DATEADD(HOUR, -1, GETDATE())),
(2, '稼働率', 92.8, '%', DATEADD(HOUR, -1, GETDATE())),
(2, '性能率', 85.6, '%', DATEADD(HOUR, -1, GETDATE())),
(2, '品質率', 98.5, '%', DATEADD(HOUR, -1, GETDATE()));

-- 分析レポートデータ
INSERT INTO AnalyticsReport (created_by_user_id, report_type, title, description, period_start, period_end, report_data, file_path, generated_at) VALUES
(2, '週次レポート', '設備稼働状況 週次レポート', '製造ライン1の週次稼働状況分析レポート', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -1, GETDATE()), '{"summary": "週次OEE平均: 80.9%", "details": "..."}', '/reports/weekly_20241124.pdf', DATEADD(HOUR, -2, GETDATE()));

-- 予測モデルデータ
INSERT INTO PredictiveModel (equipment_id, model_name, model_type, model_parameters, accuracy, trained_at, last_prediction_at, status) VALUES
(1, 'プレス機故障予測モデル', 'RandomForest', '{"n_estimators": 100, "max_depth": 10}', 0.8520, DATEADD(DAY, -30, GETDATE()), DATEADD(HOUR, -1, GETDATE()), 'Active'),
(2, '射出成型機故障予測モデル', 'LSTM', '{"layers": 3, "neurons": 50}', 0.8935, DATEADD(DAY, -25, GETDATE()), DATEADD(HOUR, -2, GETDATE()), 'Active');

-- 予測結果データ
INSERT INTO PredictionResult (model_id, equipment_id, prediction_type, prediction_value, confidence_score, predicted_failure_date, recommendation, prediction_timestamp) VALUES
(1, 1, '故障確率', 15.3, 0.8520, DATEADD(DAY, 15, GETDATE()), 'ベアリング部分の早期点検を推奨します', DATEADD(HOUR, -1, GETDATE())),
(2, 2, '故障確率', 35.7, 0.8935, DATEADD(DAY, 3, GETDATE()), '射出ユニットの詳細診断と予防保全の実施を強く推奨します', DATEADD(HOUR, -2, GETDATE()));

-- 通知データ
INSERT INTO Notification (user_id, notification_type_id, related_alert_id, title, message, priority, is_read, sent_at) VALUES
(2, 1, 1, '温度異常アラート', 'プレス機A-001で温度異常が検出されました。すぐに対応してください。', 'High', 0, DATEADD(HOUR, -2, GETDATE())),
(2, 1, 2, '故障予兆アラート', '射出成型機B-001でAIが故障予兆を検知しました。', 'Medium', 1, DATEADD(HOUR, -4, GETDATE())),
(4, 2, NULL, '保全作業完了', 'プレス機A-001の定期保全が完了しました。', 'Normal', 1, DATEADD(DAY, -7, GETDATE()));

-- データ同期ログデータ
INSERT INTO DataSyncLog (system_id, sync_type, sync_start, sync_end, records_processed, records_success, records_failed, error_message) VALUES
(1, '生産実績同期', DATEADD(HOUR, -1, GETDATE()), DATEADD(MINUTE, -50, GETDATE()), 1250, 1250, 0, NULL),
(2, 'SCADA データ同期', DATEADD(MINUTE, -30, GETDATE()), DATEADD(MINUTE, -25, GETDATE()), 3600, 3598, 2, '2件のデータでタイムスタンプエラー'),
(3, '在庫データ同期', DATEADD(HOUR, -2, GETDATE()), DATEADD(HOUR, -2, DATEADD(MINUTE, 5, GETDATE())), 85, 85, 0, NULL);

PRINT 'サンプルデータの挿入が完了しました。';
PRINT '挿入されたデータ件数:';
PRINT '- 設備グループ: 5件';
PRINT '- 設備: 8件';
PRINT '- センサー: 15件';
PRINT '- ユーザー役割: 5件';
PRINT '- ユーザー: 8件';
PRINT '- アラート種別: 6件';
PRINT '- 保全種別: 5件';
PRINT '- 部品: 8件';
PRINT '- 通知種別: 4件';
PRINT '- 外部システム: 3件';
PRINT '- その他関連データを含む全テーブルにサンプルデータが挿入されました。';