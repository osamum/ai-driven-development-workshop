// 工場設備管理システム API サービス
// 現在はサンプルデータを使用し、後でAzure Functions URLに切り替え可能な構造

class ApiService {
  constructor() {
    // Azure Functions のベースURL（後で設定）
    this.baseUrl = process.env.VUE_APP_API_BASE_URL || '';
    this.useMockData = !this.baseUrl; // ベースURLが未設定の場合はモックデータを使用
  }

  /**
   * 設備稼働状況データを取得（フィルタリング対応）
   * @param {Object} filters - フィルタリング条件
   * @returns {Promise<Object>} 設備、センサー、センサーデータを含むオブジェクト
   */
  async getEquipmentStatus(filters = {}) {
    try {
      if (this.useMockData) {
        return await this.getMockEquipmentStatus();
      }
      
      // クエリパラメータの構築
      const queryParams = new URLSearchParams();
      if (filters.groupId) queryParams.append('groupId', filters.groupId);
      if (filters.equipmentType) queryParams.append('equipmentType', filters.equipmentType);
      if (filters.status) queryParams.append('status', filters.status);
      if (filters.location) queryParams.append('location', filters.location);
      
      const queryString = queryParams.toString();
      const url = `${this.baseUrl}/api/equipment-status${queryString ? '?' + queryString : ''}`;
      
      // 実際のAPI呼び出し（Azure Functions）
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.json();
      
    } catch (error) {
      console.warn('API呼び出しエラー、モックデータを使用:', error);
      return await this.getMockEquipmentStatus();
    }
  }

  /**
   * 設備別センサーデータを取得
   * @param {number} equipmentId - 設備ID
   * @param {Object} options - オプション（fromDate, toDate）
   * @returns {Promise<Array>} センサーデータ配列
   */
  async getEquipmentSensorData(equipmentId, options = {}) {
    try {
      if (this.useMockData) {
        // モックデータの場合は既存のセンサーデータから対象設備のものを抽出
        const mockData = await this.getMockEquipmentStatus();
        const equipmentSensors = mockData.sensors.filter(s => s.equipment_id === equipmentId);
        const sensorIds = equipmentSensors.map(s => s.sensor_id);
        return mockData.sensorData.filter(sd => sensorIds.includes(sd.sensor_id));
      }
      
      // クエリパラメータの構築
      const queryParams = new URLSearchParams();
      if (options.fromDate) queryParams.append('fromDate', options.fromDate);
      if (options.toDate) queryParams.append('toDate', options.toDate);
      
      const queryString = queryParams.toString();
      const url = `${this.baseUrl}/api/equipment/${equipmentId}/sensor-data${queryString ? '?' + queryString : ''}`;
      
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.json();
      
    } catch (error) {
      console.warn('設備センサーデータの取得エラー:', error);
      return [];
    }
  }

  /**
   * モックデータから設備稼働状況を取得
   * @returns {Promise<Object>} モックデータ
   */
  async getMockEquipmentStatus() {
    try {
      // 並列でサンプルデータを読み込み
      const [equipmentResponse, groupsResponse, sensorsResponse, sensorDataResponse] = await Promise.all([
        fetch('/sample-data/equipment.json'),
        fetch('/sample-data/equipment-groups.json'),
        fetch('/sample-data/sensors.json'),
        fetch('/sample-data/sensor-data.json')
      ]);

      const [equipmentData, groupsData, sensorsData, sensorDataValues] = await Promise.all([
        equipmentResponse.json(),
        groupsResponse.json(),
        sensorsResponse.json(),
        sensorDataResponse.json()
      ]);

      // データを統合して返却
      return {
        equipment: equipmentData,
        groups: groupsData,
        sensors: sensorsData,
        sensorData: sensorDataValues,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      console.error('モックデータ読み込みエラー:', error);
      // フォールバックデータを返却
      return this.getFallbackData();
    }
  }

  /**
   * センサーデータを設備データに関連付け
   * @param {number} equipmentId 設備ID
   * @param {Array} sensorsData センサーマスターデータ
   * @param {Array} sensorDataValues センサー値データ
   * @returns {Array} 関連付けられたセンサーデータ
   */
  getEquipmentSensors(equipmentId, sensorsData, sensorDataValues) {
    const equipmentSensors = sensorsData.filter(sensor => sensor.equipment_id === equipmentId);
    return equipmentSensors.map(sensor => {
      const latestData = sensorDataValues.find(data => data.sensor_id === sensor.sensor_id);
      return {
        ...sensor,
        current_value: latestData ? latestData.value : 0,
        status: latestData ? latestData.status : '不明',
        unit: sensor.measurement_unit || ''
      };
    });
  }

  /**
   * フォールバックデータを返却
   * @returns {Object} 最小限の設備データ
   */
  getFallbackData() {
    return {
      equipment: [
        {
          id: 'eq1',
          equipment_id: 1,
          equipment_name: 'CNC加工機A1',
          equipment_type: 'CNC加工機',
          model_number: 'CNC-1000X',
          manufacturer: 'マキノ精機',
          location: '工場棟A-1F-001',
          status: '稼働中',
          installation_date: '2023-06-15',
          updated_at: new Date().toISOString()
        }
      ],
      groups: [
        {
          id: 1,
          group_name: '加工機',
          description: 'CNC加工機グループ'
        }
      ],
      sensors: [
        {
          sensor_id: 1,
          equipment_id: 1,
          sensor_name: '温度',
          sensor_type: '温度',
          measurement_unit: '℃',
          normal_min: 20,
          normal_max: 60,
          status: '正常'
        }
      ],
      sensorData: [
        {
          data_id: 1,
          sensor_id: 1,
          value: 45.2,
          status: '正常',
          timestamp: new Date().toISOString()
        }
      ],
      timestamp: new Date().toISOString()
    };
  }

  /**
   * 設備データの統計情報を計算
   * @param {Array} equipmentList 設備リスト
   * @returns {Object} ステータス集計
   */
  calculateStatusCounts(equipmentList) {
    return {
      active: equipmentList.filter(eq => eq.status === '稼働中').length,
      stopped: equipmentList.filter(eq => eq.status === '停止中').length,
      error: equipmentList.filter(eq => eq.status === '故障').length,
      maintenance: equipmentList.filter(eq => eq.status === 'メンテナンス' || eq.status === '保守中').length
    };
  }
}

// シングルトンパターンでエクスポート
export default new ApiService();