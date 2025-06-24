-- 工場設備管理システム - データ検証・確認SQL
-- サンプルデータの確認とシステム動作検証用クエリ

USE FactoryManagementDB;
GO

-- ===============================
-- データ件数確認
-- ===============================
PRINT '=== データ件数確認 ===';

SELECT 'EquipmentGroup' AS テーブル名, COUNT(*) AS 件数 FROM EquipmentGroup
UNION ALL
SELECT 'Equipment', COUNT(*) FROM Equipment
UNION ALL
SELECT 'Sensor', COUNT(*) FROM Sensor
UNION ALL
SELECT 'SensorData', COUNT(*) FROM SensorData
UNION ALL
SELECT 'EquipmentStatus', COUNT(*) FROM EquipmentStatus
UNION ALL
SELECT 'UserRole', COUNT(*) FROM UserRole
UNION ALL
SELECT '[User]', COUNT(*) FROM [User]
UNION ALL
SELECT 'AlertType', COUNT(*) FROM AlertType
UNION ALL
SELECT 'Alert', COUNT(*) FROM Alert
UNION ALL
SELECT 'AlertAction', COUNT(*) FROM AlertAction
UNION ALL
SELECT 'MaintenanceType', COUNT(*) FROM MaintenanceType
UNION ALL
SELECT 'MaintenancePlan', COUNT(*) FROM MaintenancePlan
UNION ALL
SELECT 'MaintenanceWork', COUNT(*) FROM MaintenanceWork
UNION ALL
SELECT 'Part', COUNT(*) FROM Part
UNION ALL
SELECT 'MaintenancePartUsage', COUNT(*) FROM MaintenancePartUsage
UNION ALL
SELECT 'AnalyticsReport', COUNT(*) FROM AnalyticsReport
UNION ALL
SELECT 'KPIMetrics', COUNT(*) FROM KPIMetrics
UNION ALL
SELECT 'NotificationType', COUNT(*) FROM NotificationType
UNION ALL
SELECT 'Notification', COUNT(*) FROM Notification
UNION ALL
SELECT 'PredictiveModel', COUNT(*) FROM PredictiveModel
UNION ALL
SELECT 'PredictionResult', COUNT(*) FROM PredictionResult
UNION ALL
SELECT 'ExternalSystem', COUNT(*) FROM ExternalSystem
UNION ALL
SELECT 'DataSyncLog', COUNT(*) FROM DataSyncLog
ORDER BY テーブル名;

-- ===============================
-- 設備とセンサーの関係確認
-- ===============================
PRINT '=== 設備とセンサーの関係確認 ===';

SELECT 
    eg.group_name AS '設備グループ',
    e.equipment_name AS '設備名',
    e.equipment_type AS '設備種別',
    COUNT(s.sensor_id) AS 'センサー数'
FROM EquipmentGroup eg
    INNER JOIN Equipment e ON eg.group_id = e.group_id
    LEFT JOIN Sensor s ON e.equipment_id = s.equipment_id
GROUP BY eg.group_name, e.equipment_name, e.equipment_type
ORDER BY eg.group_name, e.equipment_name;

-- ===============================
-- 最新のセンサーデータ確認
-- ===============================
PRINT '=== 最新のセンサーデータ確認 ===';

SELECT TOP 10
    e.equipment_name AS '設備名',
    s.sensor_name AS 'センサー名',
    s.measurement_unit AS '単位',
    sd.value AS '値',
    sd.status AS '状態',
    sd.timestamp AS '測定時刻'
FROM SensorData sd
    INNER JOIN Sensor s ON sd.sensor_id = s.sensor_id
    INNER JOIN Equipment e ON s.equipment_id = e.equipment_id
ORDER BY sd.timestamp DESC;

-- ===============================
-- アクティブなアラート確認
-- ===============================
PRINT '=== アクティブなアラート確認 ===';

SELECT 
    a.alert_id AS 'アラートID',
    e.equipment_name AS '設備名',
    at.type_name AS 'アラート種別',
    a.title AS 'タイトル',
    a.severity AS '重要度',
    a.status AS '状態',
    u.full_name AS '担当者',
    a.detected_at AS '検出時刻'
FROM Alert a
    INNER JOIN Equipment e ON a.equipment_id = e.equipment_id
    INNER JOIN AlertType at ON a.alert_type_id = at.alert_type_id
    LEFT JOIN [User] u ON a.assigned_user_id = u.user_id
WHERE a.status IN ('Open', 'Investigating')
ORDER BY a.detected_at DESC;

-- ===============================
-- 今後の保全計画確認
-- ===============================
PRINT '=== 今後の保全計画確認 ===';

SELECT 
    mp.plan_name AS '保全計画名',
    e.equipment_name AS '設備名',
    mt.type_name AS '保全種別',
    u.full_name AS '担当者',
    mp.scheduled_start AS '開始予定',
    mp.scheduled_end AS '終了予定',
    mp.priority AS '優先度',
    mp.status AS '状態'
FROM MaintenancePlan mp
    INNER JOIN Equipment e ON mp.equipment_id = e.equipment_id
    INNER JOIN MaintenanceType mt ON mp.maintenance_type_id = mt.maintenance_type_id
    INNER JOIN [User] u ON mp.assigned_user_id = u.user_id
WHERE mp.scheduled_start >= GETDATE() 
    AND mp.status = 'Scheduled'
ORDER BY mp.scheduled_start;

-- ===============================
-- 設備のOEE状況確認
-- ===============================
PRINT '=== 設備のOEE状況確認 ===';

SELECT 
    e.equipment_name AS '設備名',
    es.operational_status AS '稼働状態',
    es.availability_rate AS '稼働率(%)',
    es.performance_rate AS '性能率(%)',
    es.quality_rate AS '品質率(%)',
    es.oee_rate AS 'OEE(%)',
    es.status_timestamp AS '測定時刻'
FROM EquipmentStatus es
    INNER JOIN Equipment e ON es.equipment_id = e.equipment_id
WHERE es.status_timestamp >= DATEADD(HOUR, -24, GETDATE())
ORDER BY es.oee_rate DESC;

-- ===============================
-- 部品在庫状況確認
-- ===============================
PRINT '=== 部品在庫状況確認 ===';

SELECT 
    p.part_number AS '部品番号',
    p.part_name AS '部品名',
    p.stock_quantity AS '在庫数',
    p.min_stock_level AS '最小在庫',
    CASE 
        WHEN p.stock_quantity <= p.min_stock_level THEN '要発注'
        WHEN p.stock_quantity <= p.min_stock_level * 2 THEN '注意'
        ELSE '正常'
    END AS '在庫状態',
    p.unit_cost AS '単価'
FROM Part p
WHERE p.status = 'Active'
ORDER BY 
    CASE 
        WHEN p.stock_quantity <= p.min_stock_level THEN 1
        WHEN p.stock_quantity <= p.min_stock_level * 2 THEN 2
        ELSE 3
    END,
    p.part_name;

-- ===============================
-- AI予測結果確認
-- ===============================
PRINT '=== AI予測結果確認 ===';

SELECT 
    pm.model_name AS 'モデル名',
    e.equipment_name AS '設備名',
    pr.prediction_type AS '予測種別',
    pr.prediction_value AS '予測値',
    pr.confidence_score AS '信頼度',
    pr.predicted_failure_date AS '予測故障日',
    pr.recommendation AS '推奨アクション',
    pr.prediction_timestamp AS '予測時刻'
FROM PredictionResult pr
    INNER JOIN PredictiveModel pm ON pr.model_id = pm.model_id
    INNER JOIN Equipment e ON pr.equipment_id = e.equipment_id
WHERE pr.prediction_timestamp >= DATEADD(DAY, -7, GETDATE())
ORDER BY pr.prediction_value DESC;

-- ===============================
-- 未読通知確認
-- ===============================
PRINT '=== 未読通知確認 ===';

SELECT 
    u.full_name AS 'ユーザー名',
    nt.type_name AS '通知種別',
    n.title AS 'タイトル',
    n.priority AS '優先度',
    n.sent_at AS '送信時刻'
FROM Notification n
    INNER JOIN [User] u ON n.user_id = u.user_id
    INNER JOIN NotificationType nt ON n.notification_type_id = nt.notification_type_id
WHERE n.is_read = 0
ORDER BY n.sent_at DESC;

-- ===============================
-- データ整合性チェック
-- ===============================
PRINT '=== データ整合性チェック ===';

-- 孤立した設備（設備グループに属さない設備）
SELECT COUNT(*) AS '孤立設備数'
FROM Equipment e
LEFT JOIN EquipmentGroup eg ON e.group_id = eg.group_id
WHERE eg.group_id IS NULL;

-- 孤立したセンサー（設備に属さないセンサー）
SELECT COUNT(*) AS '孤立センサー数'
FROM Sensor s
LEFT JOIN Equipment e ON s.equipment_id = e.equipment_id
WHERE e.equipment_id IS NULL;

-- 担当者のいないアラート
SELECT COUNT(*) AS '未割り当てアラート数'
FROM Alert a
WHERE a.assigned_user_id IS NULL 
    AND a.status IN ('Open', 'Investigating');

-- 期限切れの保全計画
SELECT COUNT(*) AS '期限切れ保全計画数'
FROM MaintenancePlan mp
WHERE mp.scheduled_end < GETDATE() 
    AND mp.status = 'Scheduled';

PRINT '=== データ検証完了 ===';
PRINT 'システムは正常にサンプルデータで動作可能な状態です。';