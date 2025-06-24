class ApiService {
  constructor() {
    this.baseURL = process.env.VUE_APP_API_BASE_URL || 'http://localhost:3001';
  }

  // 設備一覧取得（フィルター付き）
  async getEquipment(filters = {}) {
    try {
      const params = new URLSearchParams();
      
      // フィルターパラメーターを追加
      Object.keys(filters).forEach(key => {
        if (filters[key]) {
          params.append(key, filters[key]);
        }
      });

      const url = `${this.baseURL}/api/equipment${params.toString() ? '?' + params.toString() : ''}`;
      console.log('API呼び出し:', url);

      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (!data.success) {
        throw new Error(data.error || 'API呼び出しに失敗しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('設備データ取得エラー:', error);
      throw error;
    }
  }

  // 特定設備の詳細取得
  async getEquipmentDetail(equipmentId) {
    try {
      const url = `${this.baseURL}/api/equipment/${equipmentId}`;
      console.log('API呼び出し:', url);

      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (!data.success) {
        throw new Error(data.error || 'API呼び出しに失敗しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('設備詳細取得エラー:', error);
      throw error;
    }
  }

  // 設備グループ一覧取得
  async getEquipmentGroups() {
    try {
      const url = `${this.baseURL}/api/equipment/groups/list`;
      console.log('API呼び出し:', url);

      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (!data.success) {
        throw new Error(data.error || 'API呼び出しに失敗しました');
      }
      
      return data.data;
    } catch (error) {
      console.error('設備グループ取得エラー:', error);
      throw error;
    }
  }

  // データベース接続状態確認
  async checkDatabaseHealth() {
    try {
      const url = `${this.baseURL}/api/equipment/health/db`;
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('データベース接続確認エラー:', error);
      throw error;
    }
  }

  // サーバー接続状態確認
  async checkServerHealth() {
    try {
      const url = `${this.baseURL}/health`;
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('サーバー接続確認エラー:', error);
      throw error;
    }
  }
}

export default new ApiService();