// Vue.js から Azure Functions API を呼び出すためのサービスクラス

class FactoryManagementApiService {
  constructor() {
    // Azure Functions のベースURL（環境に応じて変更）
    this.baseUrls = {
      csharp: 'https://factory-csharp-functions-XXXXX.azurewebsites.net',
      python: 'https://factory-python-functions-XXXXX.azurewebsites.net', 
      nodejs: 'https://factory-nodejs-functions-XXXXX.azurewebsites.net'
    };
    
    // 開発環境用の設定
    if (process.env.NODE_ENV === 'development') {
      this.baseUrls = {
        csharp: 'http://localhost:7071',
        python: 'http://localhost:7072',
        nodejs: 'http://localhost:7073'
      };
    }
  }

  // C# Functions - 基本CRUD操作

  async getEquipmentGroups(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/equipment-groups?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getEquipment(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/equipment?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getSensors(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/sensors?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getSensorData(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/sensor-data?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getUsers(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/users?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getAlerts(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.csharp}/api/alerts?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  // Python Functions - 分析機能

  async getEquipmentEfficiency(groupId = null) {
    const params = groupId ? `?groupId=${groupId}` : '';
    const response = await fetch(`${this.baseUrls.python}/api/analytics/equipment-efficiency${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getPredictiveMaintenance(equipmentId = null) {
    const params = equipmentId ? `?equipmentId=${equipmentId}` : '';
    const response = await fetch(`${this.baseUrls.python}/api/analytics/predictive-maintenance${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getSensorStatistics(sensorId = null) {
    const params = sensorId ? `?sensorId=${sensorId}` : '';
    const response = await fetch(`${this.baseUrls.python}/api/analytics/sensor-statistics${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  // Node.js Functions - リアルタイム・通知機能

  async getRealtimeNotifications(filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await fetch(`${this.baseUrls.nodejs}/api/notifications/realtime?${params}`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getWebSocketStatus() {
    const response = await fetch(`${this.baseUrls.nodejs}/api/websocket/status`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async sendChatNotification(notification) {
    const response = await fetch(`${this.baseUrls.nodejs}/api/notifications/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(notification)
    });
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  async getSystemHealth() {
    const response = await fetch(`${this.baseUrls.nodejs}/api/system/health`);
    if (!response.ok) {
      throw new Error(`エラー: ${response.status} ${response.statusText}`);
    }
    return await response.json();
  }

  // ユーティリティメソッド

  // すべてのAPI関数をまとめて呼び出すダッシュボード用メソッド
  async getDashboardData() {
    try {
      const [
        equipmentGroups,
        equipment,
        alerts,
        efficiency,
        systemHealth,
        realtimeNotifications
      ] = await Promise.all([
        this.getEquipmentGroups(),
        this.getEquipment({ limit: 10 }),
        this.getAlerts({ limit: 5 }),
        this.getEquipmentEfficiency(),
        this.getSystemHealth(),
        this.getRealtimeNotifications({ limit: 5 })
      ]);

      return {
        equipmentGroups,
        equipment,
        alerts,
        efficiency,
        systemHealth,
        realtimeNotifications,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('ダッシュボードデータ取得エラー:', error);
      throw error;
    }
  }

  // リアルタイム更新用のポーリング
  startRealtimePolling(callback, interval = 30000) {
    const poll = async () => {
      try {
        const [status, notifications] = await Promise.all([
          this.getWebSocketStatus(),
          this.getRealtimeNotifications({ limit: 10 })
        ]);
        callback({ status, notifications });
      } catch (error) {
        console.error('リアルタイムポーリングエラー:', error);
      }
    };

    // 初回実行
    poll();
    
    // 定期実行
    return setInterval(poll, interval);
  }

  stopRealtimePolling(intervalId) {
    if (intervalId) {
      clearInterval(intervalId);
    }
  }
}

// Vue.js での使用例
const apiService = new FactoryManagementApiService();

export default apiService;