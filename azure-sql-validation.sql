-- ===============================================
-- Azure SQL Database スキーマ検証スクリプト
-- 作成されたテーブルとインデックスの確認用
-- ===============================================

PRINT N'=== Azure SQL Database スキーマ検証開始 ===';

-- ===============================================
-- 1. テーブル作成確認
-- ===============================================
PRINT N'';
PRINT N'1. テーブル作成状況の確認:';
PRINT N'----------------------------------';

SELECT 
    TABLE_SCHEMA as スキーマ名,
    TABLE_NAME as テーブル名,
    TABLE_TYPE as テーブル種別
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- テーブル数のカウント
DECLARE @TableCount INT;
SELECT @TableCount = COUNT(*)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

PRINT N'';
PRINT N'作成されたテーブル数: ' + CAST(@TableCount AS NVARCHAR(10));

-- ===============================================
-- 2. 外部キー制約確認
-- ===============================================
PRINT N'';
PRINT N'2. 外部キー制約の確認:';
PRINT N'----------------------------------';

SELECT 
    FK.CONSTRAINT_NAME as 制約名,
    FK.TABLE_NAME as 参照元テーブル,
    CU.COLUMN_NAME as 参照元カラム,
    PK.TABLE_NAME as 参照先テーブル,
    PT.COLUMN_NAME as 参照先カラム
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK 
    ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK 
    ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU 
    ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE PT 
    ON C.UNIQUE_CONSTRAINT_NAME = PT.CONSTRAINT_NAME
ORDER BY FK.TABLE_NAME, FK.CONSTRAINT_NAME;

-- 外部キー制約数のカウント
DECLARE @ForeignKeyCount INT;
SELECT @ForeignKeyCount = COUNT(*)
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS;

PRINT N'';
PRINT N'作成された外部キー制約数: ' + CAST(@ForeignKeyCount AS NVARCHAR(10));

-- ===============================================
-- 3. インデックス確認
-- ===============================================
PRINT N'';
PRINT N'3. インデックスの確認:';
PRINT N'----------------------------------';

SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) as スキーマ名,
    OBJECT_NAME(i.object_id) as テーブル名,
    i.name as インデックス名,
    i.type_desc as インデックス種別,
    i.is_unique as 一意制約,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') as カラム一覧
FROM sys.indexes i
WHERE i.object_id IN (
    SELECT object_id 
    FROM sys.tables 
    WHERE schema_id = SCHEMA_ID('dbo')
)
AND i.name IS NOT NULL
ORDER BY OBJECT_NAME(i.object_id), i.name;

-- インデックス数のカウント（主キーを除く）
DECLARE @IndexCount INT;
SELECT @IndexCount = COUNT(*)
FROM sys.indexes i
WHERE i.object_id IN (
    SELECT object_id 
    FROM sys.tables 
    WHERE schema_id = SCHEMA_ID('dbo')
)
AND i.name IS NOT NULL
AND i.type_desc != 'CLUSTERED'; -- 主キー（クラスター化インデックス）を除く

PRINT N'';
PRINT N'作成されたインデックス数（主キー除く）: ' + CAST(@IndexCount AS NVARCHAR(10));

-- ===============================================
-- 4. CHECK制約確認
-- ===============================================
PRINT N'';
PRINT N'4. CHECK制約の確認:';
PRINT N'----------------------------------';

SELECT 
    tc.TABLE_NAME as テーブル名,
    tc.CONSTRAINT_NAME as 制約名,
    cc.CHECK_CLAUSE as 制約条件
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc 
    ON tc.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'CHECK'
ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_NAME;

-- CHECK制約数のカウント
DECLARE @CheckConstraintCount INT;
SELECT @CheckConstraintCount = COUNT(*)
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'CHECK';

PRINT N'';
PRINT N'作成されたCHECK制約数: ' + CAST(@CheckConstraintCount AS NVARCHAR(10));

-- ===============================================
-- 5. 初期データ確認
-- ===============================================
PRINT N'';
PRINT N'5. 初期データの確認:';
PRINT N'----------------------------------';

-- ユーザー役割データ
SELECT COUNT(*) as ユーザー役割件数 FROM UserRole;
PRINT N'ユーザー役割: ' + CAST((SELECT COUNT(*) FROM UserRole) AS NVARCHAR(10)) + N'件';

-- アラート種別データ
SELECT COUNT(*) as アラート種別件数 FROM AlertType;
PRINT N'アラート種別: ' + CAST((SELECT COUNT(*) FROM AlertType) AS NVARCHAR(10)) + N'件';

-- 保全種別データ
SELECT COUNT(*) as 保全種別件数 FROM MaintenanceType;
PRINT N'保全種別: ' + CAST((SELECT COUNT(*) FROM MaintenanceType) AS NVARCHAR(10)) + N'件';

-- 通知種別データ
SELECT COUNT(*) as 通知種別件数 FROM NotificationType;
PRINT N'通知種別: ' + CAST((SELECT COUNT(*) FROM NotificationType) AS NVARCHAR(10)) + N'件';

-- ===============================================
-- 6. データベース設定確認
-- ===============================================
PRINT N'';
PRINT N'6. データベース設定の確認:';
PRINT N'----------------------------------';

SELECT 
    name as データベース名,
    collation_name as 照合順序,
    compatibility_level as 互換性レベル,
    is_auto_close_on as 自動クローズ,
    is_auto_shrink_on as 自動縮小,
    is_auto_create_stats_on as 自動統計作成,
    is_auto_update_stats_on as 自動統計更新
FROM sys.databases 
WHERE name = DB_NAME();

-- ===============================================
-- 7. エラーチェック
-- ===============================================
PRINT N'';
PRINT N'7. エラーチェック:';
PRINT N'----------------------------------';

-- 期待されるテーブル数との比較
IF @TableCount = 18
    PRINT N'✓ テーブル数チェック: 正常（18テーブル）';
ELSE
    PRINT N'✗ テーブル数チェック: 異常（期待値: 18、実際: ' + CAST(@TableCount AS NVARCHAR(10)) + N'）';

-- 期待される外部キー制約数との比較（データモデルから算出）
IF @ForeignKeyCount >= 15
    PRINT N'✓ 外部キー制約チェック: 正常（' + CAST(@ForeignKeyCount AS NVARCHAR(10)) + N'個）';
ELSE
    PRINT N'✗ 外部キー制約チェック: 要確認（' + CAST(@ForeignKeyCount AS NVARCHAR(10)) + N'個）';

-- インデックス数チェック
IF @IndexCount >= 15
    PRINT N'✓ インデックスチェック: 正常（' + CAST(@IndexCount AS NVARCHAR(10)) + N'個）';
ELSE
    PRINT N'✗ インデックスチェック: 要確認（' + CAST(@IndexCount AS NVARCHAR(10)) + N'個）';

-- 初期データチェック
DECLARE @InitialDataCount INT = 0;
SELECT @InitialDataCount = 
    (SELECT COUNT(*) FROM UserRole) +
    (SELECT COUNT(*) FROM AlertType) +
    (SELECT COUNT(*) FROM MaintenanceType) +
    (SELECT COUNT(*) FROM NotificationType);

IF @InitialDataCount = 20
    PRINT N'✓ 初期データチェック: 正常（20件）';
ELSE
    PRINT N'✗ 初期データチェック: 要確認（期待値: 20、実際: ' + CAST(@InitialDataCount AS NVARCHAR(10)) + N'）';

-- ===============================================
-- 8. サンプルクエリ実行テスト
-- ===============================================
PRINT N'';
PRINT N'8. サンプルクエリ実行テスト:';
PRINT N'----------------------------------';

BEGIN TRY
    -- 簡単なJOINクエリのテスト
    DECLARE @TestResult INT;
    
    SELECT @TestResult = COUNT(*)
    FROM UserRole ur
    LEFT JOIN [User] u ON ur.role_id = u.role_id
    LEFT JOIN AlertType at ON 1=1  -- クロスジョイン（テスト目的）
    LEFT JOIN MaintenanceType mt ON 1=1;  -- クロスジョイン（テスト目的）
    
    PRINT N'✓ JOINクエリテスト: 正常実行（結果件数: ' + CAST(@TestResult AS NVARCHAR(10)) + N'）';
    
    -- 外部キー制約テスト（無効なデータ挿入試行）
    BEGIN TRY
        INSERT INTO Equipment (group_id, equipment_name, equipment_type) 
        VALUES (99999, N'テスト設備', N'テスト');
        PRINT N'✗ 外部キー制約テスト: 制約が機能していない可能性があります';
        -- テストデータを削除
        DELETE FROM Equipment WHERE group_id = 99999;
    END TRY
    BEGIN CATCH
        PRINT N'✓ 外部キー制約テスト: 正常（制約が機能している）';
    END CATCH
    
END TRY
BEGIN CATCH
    PRINT N'✗ サンプルクエリエラー: ' + ERROR_MESSAGE();
END CATCH

-- ===============================================
-- 検証完了
-- ===============================================
PRINT N'';
PRINT N'=== Azure SQL Database スキーマ検証完了 ===';
PRINT N'';
PRINT N'検証日時: ' + CONVERT(NVARCHAR(19), GETDATE(), 120);
PRINT N'データベース名: ' + DB_NAME();
PRINT N'データベースバージョン: ' + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50));
PRINT N'';
PRINT N'詳細な確認が必要な項目については、上記の結果を参照してください。';