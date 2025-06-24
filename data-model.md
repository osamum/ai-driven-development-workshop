# 工場設備管理システム - データモデル設計書

## 概要

本ドキュメントでは、工場設備管理システムのユースケース仕様書と機能要件定義書に基づいて設計されたデータモデルを定義します。このデータモデルは、IoT技術とAIを活用した工場設備の効率的な監視、予知保全、データ分析機能を実現するために必要な全てのデータ要素を網羅しています。

## データモデル構成

### エンティティ関係図（Mermaid記法）

```mermaid
erDiagram
    %% 設備関連エンティティ
    EquipmentGroup {
        int group_id PK
        string group_name
        string description
        datetime created_at
        datetime updated_at
    }
    
    Equipment {
        int equipment_id PK
        int group_id FK
        string equipment_name
        string equipment_type
        string model_number
        string serial_number
        string manufacturer
        date installation_date
        string location
        string status
        datetime created_at
        datetime updated_at
    }
    
    Sensor {
        int sensor_id PK
        int equipment_id FK
        string sensor_name
        string sensor_type
        string measurement_unit
        decimal min_value
        decimal max_value
        decimal normal_min
        decimal normal_max
        string status
        datetime created_at
        datetime updated_at
    }
    
    SensorData {
        bigint data_id PK
        int sensor_id FK
        decimal value
        string status
        datetime timestamp
        datetime created_at
    }
    
    EquipmentStatus {
        bigint status_id PK
        int equipment_id FK
        string operational_status
        decimal availability_rate
        decimal performance_rate
        decimal quality_rate
        decimal oee_rate
        datetime status_timestamp
        datetime created_at
    }
    
    %% ユーザー関連エンティティ
    UserRole {
        int role_id PK
        string role_name
        string description
        string permissions
        datetime created_at
        datetime updated_at
    }
    
    User {
        int user_id PK
        int role_id FK
        string username
        string email
        string full_name
        string department
        string phone_number
        string status
        datetime last_login
        datetime created_at
        datetime updated_at
    }
    
    %% アラート関連エンティティ
    AlertType {
        int alert_type_id PK
        string type_name
        string description
        string severity
        string color_code
        datetime created_at
        datetime updated_at
    }
    
    Alert {
        bigint alert_id PK
        int equipment_id FK
        int sensor_id FK
        int alert_type_id FK
        int assigned_user_id FK
        string title
        text description
        string severity
        string status
        datetime detected_at
        datetime acknowledged_at
        datetime resolved_at
        datetime created_at
        datetime updated_at
    }
    
    AlertAction {
        int action_id PK
        bigint alert_id FK
        int user_id FK
        string action_type
        text action_description
        datetime action_timestamp
        datetime created_at
    }
    
    %% 保全関連エンティティ
    MaintenanceType {
        int maintenance_type_id PK
        string type_name
        string description
        int default_duration_hours
        datetime created_at
        datetime updated_at
    }
    
    MaintenancePlan {
        int plan_id PK
        int equipment_id FK
        int maintenance_type_id FK
        int assigned_user_id FK
        string plan_name
        text description
        datetime scheduled_start
        datetime scheduled_end
        int estimated_duration_hours
        string priority
        string status
        datetime created_at
        datetime updated_at
    }
    
    MaintenanceWork {
        int work_id PK
        int plan_id FK
        int equipment_id FK
        int technician_id FK
        datetime actual_start
        datetime actual_end
        int actual_duration_hours
        text work_description
        text findings
        string status
        decimal cost
        datetime created_at
        datetime updated_at
    }
    
    Part {
        int part_id PK
        string part_number
        string part_name
        string description
        string manufacturer
        decimal unit_cost
        int stock_quantity
        int min_stock_level
        string status
        datetime created_at
        datetime updated_at
    }
    
    MaintenancePartUsage {
        int usage_id PK
        int work_id FK
        int part_id FK
        int quantity_used
        decimal unit_cost
        decimal total_cost
        datetime used_at
        datetime created_at
    }
    
    %% 分析・レポート関連エンティティ
    AnalyticsReport {
        int report_id PK
        int created_by_user_id FK
        string report_type
        string title
        text description
        datetime period_start
        datetime period_end
        text report_data
        string file_path
        datetime generated_at
        datetime created_at
    }
    
    KPIMetrics {
        bigint metric_id PK
        int equipment_id FK
        string metric_name
        decimal metric_value
        string unit
        datetime measurement_timestamp
        datetime created_at
    }
    
    %% 通知関連エンティティ
    NotificationType {
        int notification_type_id PK
        string type_name
        string description
        datetime created_at
        datetime updated_at
    }
    
    Notification {
        bigint notification_id PK
        int user_id FK
        int notification_type_id FK
        bigint related_alert_id FK
        int related_plan_id FK
        string title
        text message
        string priority
        boolean is_read
        datetime sent_at
        datetime read_at
        datetime created_at
    }
    
    %% AI/ML関連エンティティ
    PredictiveModel {
        int model_id PK
        int equipment_id FK
        string model_name
        string model_type
        text model_parameters
        decimal accuracy
        datetime trained_at
        datetime last_prediction_at
        string status
        datetime created_at
        datetime updated_at
    }
    
    PredictionResult {
        bigint prediction_id PK
        int model_id PK
        int equipment_id FK
        string prediction_type
        decimal prediction_value
        decimal confidence_score
        datetime predicted_failure_date
        text recommendation
        datetime prediction_timestamp
        datetime created_at
    }
    
    %% 外部システム連携エンティティ
    ExternalSystem {
        int system_id PK
        string system_name
        string system_type
        string connection_string
        string api_endpoint
        string authentication_type
        string status
        datetime last_sync
        datetime created_at
        datetime updated_at
    }
    
    DataSyncLog {
        bigint sync_id PK
        int system_id FK
        string sync_type
        datetime sync_start
        datetime sync_end
        int records_processed
        int records_success
        int records_failed
        text error_message
        datetime created_at
    }
    
    %% リレーションシップ定義
    EquipmentGroup ||--o{ Equipment : contains
    Equipment ||--o{ Sensor : has
    Equipment ||--o{ EquipmentStatus : has
    Equipment ||--o{ Alert : generates
    Equipment ||--o{ MaintenancePlan : requires
    Equipment ||--o{ MaintenanceWork : undergoes
    Equipment ||--o{ KPIMetrics : measures
    Equipment ||--o{ PredictiveModel : analyzed_by
    Equipment ||--o{ PredictionResult : has_predictions
    
    Sensor ||--o{ SensorData : generates
    Sensor ||--o{ Alert : triggers
    
    UserRole ||--o{ User : has
    User ||--o{ Alert : assigned_to
    User ||--o{ MaintenancePlan : creates
    User ||--o{ MaintenanceWork : performs
    User ||--o{ AlertAction : performs
    User ||--o{ AnalyticsReport : creates
    User ||--o{ Notification : receives
    
    AlertType ||--o{ Alert : categorizes
    Alert ||--o{ AlertAction : has
    Alert ||--o{ Notification : triggers
    
    MaintenanceType ||--o{ MaintenancePlan : defines
    MaintenancePlan ||--o{ MaintenanceWork : results_in
    MaintenancePlan ||--o{ Notification : triggers
    
    MaintenanceWork ||--o{ MaintenancePartUsage : uses
    Part ||--o{ MaintenancePartUsage : consumed_in
    
    NotificationType ||--o{ Notification : categorizes
    
    PredictiveModel ||--o{ PredictionResult : produces
    
    ExternalSystem ||--o{ DataSyncLog : logs
```

## エンティティ詳細説明

### 1. 設備関連エンティティ

#### EquipmentGroup（設備グループ）
工場内の設備を論理的にグループ化するためのエンティティです。製造ライン、部門、設備タイプなどで分類します。

#### Equipment（設備）
工場内の個々の設備・機械を表現します。設備の基本情報、設置場所、稼働状況を管理します。

#### Sensor（センサー）
各設備に設置されたIoTセンサーの情報を管理します。センサータイプ、測定範囲、正常値範囲を定義します。

#### SensorData（センサーデータ）
センサーから収集されるリアルタイムデータを格納します。大容量データに対応するため、適切なパーティショニング戦略が必要です。

#### EquipmentStatus（設備状態）
設備の稼働状況、可用性、性能、品質を総合したOEE（Overall Equipment Effectiveness）指標を管理します。

### 2. ユーザー関連エンティティ

#### UserRole（ユーザー役割）
システム利用者の役割を定義し、権限管理を行います。設備管理者、保全担当者、製造オペレーターなどの役割を管理します。

#### User（ユーザー）
システム利用者の基本情報と認証情報を管理します。

### 3. アラート関連エンティティ

#### AlertType（アラート種別）
アラートの分類と重要度を定義します。故障予兆、異常値、保全期限などの種別を管理します。

#### Alert（アラート）
設備異常や故障予兆の検知結果を管理します。検知時刻、対応状況、解決時刻を追跡します。

#### AlertAction（アラート対応）
アラートに対する対応履歴を記録します。対応者、対応内容、対応時刻を管理します。

### 4. 保全関連エンティティ

#### MaintenanceType（保全種別）
予防保全、予知保全、事後保全などの保全作業の種別を定義します。

#### MaintenancePlan（保全計画）
設備の保全スケジュールを管理します。予知保全の結果に基づく計画や定期保全計画を含みます。

#### MaintenanceWork（保全作業）
実際に実施された保全作業の記録を管理します。作業時間、コスト、結果を追跡します。

#### Part（部品）
保全作業で使用する部品の在庫情報を管理します。

#### MaintenancePartUsage（保全部品使用）
保全作業で使用された部品の使用履歴を記録します。

### 5. 分析・レポート関連エンティティ

#### AnalyticsReport（分析レポート）
システムで生成される各種分析レポートの情報を管理します。

#### KPIMetrics（KPI指標）
設備パフォーマンスの重要業績評価指標を時系列で管理します。

### 6. 通知関連エンティティ

#### NotificationType（通知種別）
システムから送信される通知の種別を定義します。

#### Notification（通知）
ユーザーへの通知履歴を管理します。アラート通知、保全リマインダー、レポート配信などを含みます。

### 7. AI/ML関連エンティティ

#### PredictiveModel（予測モデル）
設備ごとのAI予測モデルの情報を管理します。モデルの精度、学習日時、状態を追跡します。

#### PredictionResult（予測結果）
AI予測モデルによる故障予測結果を管理します。予測値、信頼度、推奨アクションを記録します。

### 8. 外部システム連携エンティティ

#### ExternalSystem（外部システム）
ERP、MES、SCADAなどの外部システムとの連携情報を管理します。

#### DataSyncLog（データ同期ログ）
外部システムとのデータ同期履歴を記録し、連携状況を監視します。

## データモデル設計の考慮事項

### 1. スケーラビリティ
- センサーデータは大量のデータが生成されるため、時系列データベースの活用を検討
- 履歴データのアーカイブ戦略を定義
- 水平スケーリングに対応したパーティショニング設計

### 2. パフォーマンス
- リアルタイム監視に必要なレスポンス性能を確保
- 分析処理用のデータマートの構築
- 適切なインデックス設計

### 3. データ品質
- センサーデータの欠損値や異常値の処理
- データ整合性制約の定義
- データ入力時のバリデーション

### 4. セキュリティ
- 個人情報の適切な管理
- アクセス制御の実装
- データ暗号化の適用

### 5. 可用性
- データバックアップとリストア戦略
- 災害時の事業継続性確保
- システム冗長化の考慮

## ユースケース対応表

### UC-001: リアルタイム設備監視
- **関連エンティティ**: Equipment, Sensor, SensorData, EquipmentStatus, Alert
- **データフロー**: センサーデータ収集 → 異常検知 → アラート生成 → 通知送信

### UC-002: 予知保全の実施
- **関連エンティティ**: PredictiveModel, PredictionResult, MaintenancePlan, Alert
- **データフロー**: センサーデータ分析 → AI予測 → 保全計画生成 → 通知送信

### UC-003: 設備稼働データの分析
- **関連エンティティ**: SensorData, EquipmentStatus, KPIMetrics, AnalyticsReport
- **データフロー**: 履歴データ抽出 → 分析実行 → レポート生成 → 結果保存

### UC-004: アラート管理と対応
- **関連エンティティ**: Alert, AlertAction, User, Notification
- **データフロー**: アラート検知 → 担当者通知 → 対応実施 → 履歴記録

### UC-005: 設備パフォーマンス可視化
- **関連エンティティ**: Equipment, SensorData, EquipmentStatus, KPIMetrics
- **データフロー**: リアルタイムデータ取得 → 指標計算 → ダッシュボード表示

### UC-006: 保全計画の策定と管理
- **関連エンティティ**: MaintenancePlan, MaintenanceWork, User, Part
- **データフロー**: 予測結果分析 → 計画生成 → リソース調整 → スケジュール登録

### UC-007: データ分析レポートの生成
- **関連エンティティ**: AnalyticsReport, KPIMetrics, SensorData, User
- **データフロー**: データ抽出 → 分析実行 → レポート生成 → 自動配信

## まとめ

本データモデルは、工場設備管理システムの全ユースケースを網羅し、IoT技術とAIを活用した効率的な設備管理を実現するための包括的なデータ構造を提供します。リアルタイムデータ処理、予知保全、分析レポート生成などの機能要件を満たすとともに、将来の機能拡張にも対応できる柔軟性を備えています。

実装時には、データ量、パフォーマンス要件、セキュリティ要件を考慮して、適切なデータベース技術とアーキテクチャを選択することが重要です。