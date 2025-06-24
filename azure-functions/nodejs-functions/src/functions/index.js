const { app } = require('@azure/functions');
const fs = require('fs').promises;
const path = require('path');

// サンプルデータ読み込み関数
async function loadSampleData(filename) {
    try {
        const basePath = path.join(__dirname, '..', '..', '..', '..', 'sample-data');
        const filePath = path.join(basePath, filename);
        const data = await fs.readFile(filePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error(`データ読み込みエラー: ${error.message}`);
        return [];
    }
}

// リアルタイム通知API
app.http('realtime-notifications', {
    methods: ['GET'],
    route: 'notifications/realtime',
    handler: async (request, context) => {
        context.log('リアルタイム通知API が呼び出されました');

        try {
            // アラートデータを読み込み
            const alerts = await loadSampleData('13_alerts.json');
            
            // フィルター適用
            const severity = request.query.get('severity');
            const equipmentId = request.query.get('equipmentId');
            const limit = parseInt(request.query.get('limit')) || 10;

            let filteredAlerts = alerts;

            if (severity) {
                filteredAlerts = filteredAlerts.filter(alert => 
                    alert.severity.toLowerCase().includes(severity.toLowerCase())
                );
            }

            if (equipmentId) {
                const eqId = parseInt(equipmentId);
                filteredAlerts = filteredAlerts.filter(alert => 
                    alert.equipment_id === eqId
                );
            }

            // 最新のアラートを取得
            const recentAlerts = filteredAlerts
                .sort((a, b) => new Date(b.triggered_at) - new Date(a.triggered_at))
                .slice(0, limit)
                .map(alert => ({
                    ...alert,
                    notification_type: 'alert',
                    timestamp: new Date().toISOString(),
                    realtime: true
                }));

            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'Cache-Control': 'no-cache'
                },
                body: JSON.stringify(recentAlerts, null, 2)
            };

        } catch (error) {
            context.error(`リアルタイム通知エラー: ${error.message}`);
            return {
                status: 500,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ error: `エラーが発生しました: ${error.message}` })
            };
        }
    }
});

// WebSocket接続シミュレーション
app.http('websocket-status', {
    methods: ['GET'],
    route: 'websocket/status',
    handler: async (request, context) => {
        context.log('WebSocket状態確認API が呼び出されました');

        try {
            // 設備の稼働状況をリアルタイムで返す（サンプル実装）
            const equipment = await loadSampleData('02_equipment.json');
            const sensorData = await loadSampleData('11_sensor_data.json');

            const statusData = equipment.map(eq => {
                // サンプルのリアルタイムステータス
                const randomStatus = Math.random();
                let operationalStatus = '正常';
                let statusColor = 'green';

                if (randomStatus < 0.1) {
                    operationalStatus = 'エラー';
                    statusColor = 'red';
                } else if (randomStatus < 0.2) {
                    operationalStatus = '警告';
                    statusColor = 'yellow';
                }

                return {
                    equipment_id: eq.equipment_id,
                    equipment_name: eq.equipment_name,
                    operational_status: operationalStatus,
                    status_color: statusColor,
                    last_updated: new Date().toISOString(),
                    connection_status: 'connected',
                    sensor_count: Math.floor(Math.random() * 5) + 1,
                    active_alerts: Math.floor(Math.random() * 3)
                };
            });

            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'Cache-Control': 'no-cache'
                },
                body: JSON.stringify({
                    timestamp: new Date().toISOString(),
                    connected_equipment: statusData.length,
                    equipment_status: statusData
                }, null, 2)
            };

        } catch (error) {
            context.error(`WebSocket状態エラー: ${error.message}`);
            return {
                status: 500,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ error: `エラーが発生しました: ${error.message}` })
            };
        }
    }
});

// チャット通知（Teams/Slack風）
app.http('chat-notifications', {
    methods: ['POST'],
    route: 'notifications/chat',
    handler: async (request, context) => {
        context.log('チャット通知API が呼び出されました');

        try {
            const requestBody = await request.json();
            const { message, channel, priority = 'normal', equipment_id } = requestBody;

            // 通知データの構築
            const notification = {
                id: `notification_${Date.now()}`,
                message: message || 'テスト通知メッセージ',
                channel: channel || 'general',
                priority: priority,
                equipment_id: equipment_id,
                timestamp: new Date().toISOString(),
                sender: 'factory-management-system',
                type: 'chat_notification',
                status: 'sent'
            };

            // 実際の実装では、ここでTeamsやSlackのAPIを呼び出す
            context.log(`チャット通知送信: ${JSON.stringify(notification)}`);

            return {
                status: 200,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({
                    success: true,
                    notification_id: notification.id,
                    message: '通知が正常に送信されました',
                    details: notification
                }, null, 2)
            };

        } catch (error) {
            context.error(`チャット通知エラー: ${error.message}`);
            return {
                status: 500,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ 
                    success: false,
                    error: `エラーが発生しました: ${error.message}` 
                })
            };
        }
    }
});

// システム健全性チェック
app.http('health-check', {
    methods: ['GET'],
    route: 'system/health',
    handler: async (request, context) => {
        context.log('システム健全性チェックAPI が呼び出されました');

        try {
            // 各コンポーネントの状態をチェック（サンプル実装）
            const healthStatus = {
                timestamp: new Date().toISOString(),
                overall_status: 'healthy',
                components: {
                    database: {
                        status: 'healthy',
                        response_time_ms: Math.floor(Math.random() * 50) + 10
                    },
                    api_gateway: {
                        status: 'healthy',
                        response_time_ms: Math.floor(Math.random() * 30) + 5
                    },
                    message_queue: {
                        status: 'healthy',
                        queue_length: Math.floor(Math.random() * 100)
                    },
                    sensors: {
                        status: 'healthy',
                        connected_count: 24,
                        total_count: 25
                    },
                    ai_services: {
                        status: 'healthy',
                        model_accuracy: 0.952
                    }
                },
                system_metrics: {
                    cpu_usage_percent: Math.floor(Math.random() * 30) + 40,
                    memory_usage_percent: Math.floor(Math.random() * 20) + 60,
                    disk_usage_percent: Math.floor(Math.random() * 15) + 25,
                    network_latency_ms: Math.floor(Math.random() * 20) + 10
                }
            };

            return {
                status: 200,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify(healthStatus, null, 2)
            };

        } catch (error) {
            context.error(`健全性チェックエラー: ${error.message}`);
            return {
                status: 500,
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ 
                    overall_status: 'unhealthy',
                    error: `エラーが発生しました: ${error.message}`,
                    timestamp: new Date().toISOString()
                })
            };
        }
    }
});