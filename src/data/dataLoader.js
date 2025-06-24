// データローダー - サンプルデータの読み込みと管理

export class DataLoader {
  constructor() {
    this.cache = new Map()
  }

  // 設備データの読み込み
  async loadEquipmentData() {
    if (this.cache.has('equipment')) {
      return this.cache.get('equipment')
    }

    try {
      // サンプルデータ（実際の実装では API から取得）
      const equipmentData = [
        {
          id: 'eq1',
          equipment_id: 1,
          group_id: 1,
          equipment_name: 'CNC加工機A1',
          equipment_type: 'CNC加工機',
          model_number: 'CNC-1000X',
          serial_number: 'CNC1000X-001',
          manufacturer: 'マキノ精機',
          installation_date: '2023-06-15',
          location: '工場棟A-1F-001',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        },
        {
          id: 'eq2',
          equipment_id: 2,
          group_id: 1,
          equipment_name: '搬送ロボット1',
          equipment_type: '搬送ロボット',
          model_number: 'ROBOT-500',
          serial_number: 'ROBOT500-001',
          manufacturer: '安川電機',
          installation_date: '2023-08-10',
          location: '工場棟A-1F-002',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        },
        {
          id: 'eq3',
          equipment_id: 3,
          group_id: 2,
          equipment_name: 'プレス機B1',
          equipment_type: 'プレス機',
          model_number: 'PRESS-2000',
          serial_number: 'PRESS2000-001',
          manufacturer: 'コマツ産機',
          installation_date: '2023-04-20',
          location: '工場棟B-1F-001',
          status: '保守中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        },
        {
          id: 'eq4',
          equipment_id: 4,
          group_id: 3,
          equipment_name: '検査機C1',
          equipment_type: '検査機',
          model_number: 'INSPECT-400',
          serial_number: 'INSPECT400-001',
          manufacturer: 'キーエンス',
          installation_date: '2023-07-01',
          location: '工場棟C-1F-001',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        }
      ]

      // ローカルストレージに保存
      localStorage.setItem('equipmentData', JSON.stringify(equipmentData))
      this.cache.set('equipment', equipmentData)
      
      return equipmentData
    } catch (error) {
      console.error('設備データの読み込みに失敗しました:', error)
      return []
    }
  }

  // アラートデータの読み込み
  async loadAlertsData() {
    if (this.cache.has('alerts')) {
      return this.cache.get('alerts')
    }

    try {
      const alertsData = [
        {
          id: 'alert1',
          alert_id: 1,
          equipment_id: 1,
          sensor_id: 1,
          alert_type_id: 1,
          assigned_user_id: 2,
          title: 'CNC加工機A1 温度異常',
          description: '設備温度が正常範囲(80℃)を超過しました。現在値: 78.9℃',
          severity: '高',
          status: '未対応',
          detected_at: new Date(Date.now() - 30000).toISOString(),
          acknowledged_at: null,
          resolved_at: null,
          created_at: new Date(Date.now() - 30000).toISOString(),
          updated_at: new Date(Date.now() - 30000).toISOString()
        },
        {
          id: 'alert2',
          alert_id: 2,
          equipment_id: 2,
          sensor_id: 2,
          alert_type_id: 2,
          assigned_user_id: 3,
          title: '搬送ロボット1 動作異常',
          description: '搬送速度が通常より20%低下しています。メンテナンスが必要です。',
          severity: '中',
          status: '対応中',
          detected_at: new Date(Date.now() - 300000).toISOString(),
          acknowledged_at: new Date(Date.now() - 240000).toISOString(),
          resolved_at: null,
          created_at: new Date(Date.now() - 300000).toISOString(),
          updated_at: new Date(Date.now() - 240000).toISOString()
        },
        {
          id: 'alert3',
          alert_id: 3,
          equipment_id: 4,
          sensor_id: 4,
          alert_type_id: 1,
          assigned_user_id: 2,
          title: '検査機C1 電力消費異常',
          description: '電力消費量が通常の150%に増加しています。',
          severity: '中',
          status: '未対応',
          detected_at: new Date(Date.now() - 900000).toISOString(),
          acknowledged_at: null,
          resolved_at: null,
          created_at: new Date(Date.now() - 900000).toISOString(),
          updated_at: new Date(Date.now() - 900000).toISOString()
        }
      ]

      localStorage.setItem('alertsData', JSON.stringify(alertsData))
      this.cache.set('alerts', alertsData)
      
      return alertsData
    } catch (error) {
      console.error('アラートデータの読み込みに失敗しました:', error)
      return []
    }
  }

  // センサーデータの読み込み
  async loadSensorData() {
    if (this.cache.has('sensors')) {
      return this.cache.get('sensors')
    }

    try {
      const sensorData = [
        {
          id: 1,
          equipment_id: 1,
          sensor_type: '温度センサー',
          name: '温度',
          value: 78.9,
          unit: '℃',
          status: '注意',
          min_value: 60,
          max_value: 80,
          updated_at: new Date()
        },
        {
          id: 2,
          equipment_id: 1,
          sensor_type: '振動センサー',
          name: '振動',
          value: 2.1,
          unit: 'mm/s',
          status: '正常',
          min_value: 0,
          max_value: 3.0,
          updated_at: new Date()
        },
        {
          id: 3,
          equipment_id: 1,
          sensor_type: '電流センサー',
          name: '電流',
          value: 15.2,
          unit: 'A',
          status: '正常',
          min_value: 10,
          max_value: 20,
          updated_at: new Date()
        }
      ]

      localStorage.setItem('sensorData', JSON.stringify(sensorData))
      this.cache.set('sensors', sensorData)
      
      return sensorData
    } catch (error) {
      console.error('センサーデータの読み込みに失敗しました:', error)
      return []
    }
  }

  // ユーザーデータの読み込み
  async loadUsersData() {
    if (this.cache.has('users')) {
      return this.cache.get('users')
    }

    try {
      const usersData = [
        {
          id: 1,
          username: 'admin',
          display_name: '管理者',
          role: 'administrator',
          department: '管理部',
          email: 'admin@factory.com'
        },
        {
          id: 2,
          username: 'operator',
          display_name: 'オペレーター',
          role: 'operator',
          department: '製造部',
          email: 'operator@factory.com'
        },
        {
          id: 3,
          username: 'maintenance',
          display_name: '保全担当',
          role: 'maintenance',
          department: '保全部',
          email: 'maintenance@factory.com'
        }
      ]

      localStorage.setItem('usersData', JSON.stringify(usersData))
      this.cache.set('users', usersData)
      
      return usersData
    } catch (error) {
      console.error('ユーザーデータの読み込みに失敗しました:', error)
      return []
    }
  }

  // 全データの初期化
  async initializeData() {
    try {
      await Promise.all([
        this.loadEquipmentData(),
        this.loadAlertsData(),
        this.loadSensorData(),
        this.loadUsersData()
      ])
      console.log('すべてのサンプルデータの読み込みが完了しました')
    } catch (error) {
      console.error('データ初期化中にエラーが発生しました:', error)
    }
  }

  // キャッシュクリア
  clearCache() {
    this.cache.clear()
    localStorage.clear()
  }
}

// シングルトンインスタンス
export const dataLoader = new DataLoader()