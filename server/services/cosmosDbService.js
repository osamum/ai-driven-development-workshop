const { CosmosClient } = require('@azure/cosmos');
const mockDataService = require('./mockDataService');

class CosmosDbService {
  constructor() {
    this.endpoint = process.env.COSMOS_DB_ENDPOINT;
    this.key = process.env.COSMOS_DB_KEY;
    this.databaseName = process.env.COSMOS_DB_DATABASE_NAME || 'FactoryManagementDB';
    this.useMockData = false;
    
    if (!this.endpoint || !this.key) {
      console.warn('Cosmos DB接続情報が設定されていません。モックデータを使用します。');
      this.client = null;
      this.useMockData = true;
      return;
    }

    this.client = new CosmosClient({
      endpoint: this.endpoint,
      key: this.key,
      userAgentSuffix: 'FactoryManagementSystem'
    });

    this.database = this.client.database(this.databaseName);
  }

  // 接続テスト
  async testConnection() {
    try {
      if (!this.client) {
        throw new Error('Cosmos DB クライアントが初期化されていません');
      }
      
      const { resource: databaseDefinition } = await this.database.read();
      console.log(`Cosmos DB接続成功: ${databaseDefinition.id}`);
      return true;
    } catch (error) {
      console.error('Cosmos DB接続エラー:', error.message);
      return false;
    }
  }

  // コンテナー取得
  getContainer(containerName) {
    if (!this.database) {
      throw new Error('データベース接続が初期化されていません');
    }
    return this.database.container(containerName);
  }

  // 設備データ取得（フィルター付き）
  async getEquipment(filters = {}) {
    if (this.useMockData) {
      return await mockDataService.getEquipment(filters);
    }
    
    try {
      const container = this.getContainer('Equipment');
      
      let query = 'SELECT * FROM c WHERE 1=1';
      const parameters = [];

      // フィルター条件の追加
      if (filters.status) {
        query += ' AND c.status = @status';
        parameters.push({ name: '@status', value: filters.status });
      }

      if (filters.equipment_type) {
        query += ' AND CONTAINS(LOWER(c.equipment_type), LOWER(@equipment_type))';
        parameters.push({ name: '@equipment_type', value: filters.equipment_type });
      }

      if (filters.search) {
        query += ' AND (CONTAINS(LOWER(c.equipment_name), LOWER(@search)) OR CONTAINS(LOWER(c.equipment_type), LOWER(@search)))';
        parameters.push({ name: '@search', value: filters.search });
      }

      if (filters.group_id) {
        query += ' AND c.group_id = @group_id';
        parameters.push({ name: '@group_id', value: parseInt(filters.group_id) });
      }

      query += ' ORDER BY c.equipment_name';

      const querySpec = {
        query: query,
        parameters: parameters
      };

      const { resources } = await container.items.query(querySpec).fetchAll();
      return resources;
    } catch (error) {
      console.error('設備データ取得エラー:', error);
      throw error;
    }
  }

  // センサーデータ取得
  async getSensors(equipmentId = null) {
    if (this.useMockData) {
      return await mockDataService.getSensors(equipmentId);
    }
    
    try {
      const container = this.getContainer('Sensors');
      
      let query = 'SELECT * FROM c';
      const parameters = [];

      if (equipmentId) {
        query += ' WHERE c.equipment_id = @equipment_id';
        parameters.push({ name: '@equipment_id', value: parseInt(equipmentId) });
      }

      const querySpec = {
        query: query,
        parameters: parameters
      };

      const { resources } = await container.items.query(querySpec).fetchAll();
      return resources;
    } catch (error) {
      console.error('センサーデータ取得エラー:', error);
      throw error;
    }
  }

  // 最新センサー値取得
  async getLatestSensorData(equipmentId = null) {
    if (this.useMockData) {
      return await mockDataService.getLatestSensorData(equipmentId);
    }
    
    try {
      const container = this.getContainer('SensorData');
      
      let query = `
        SELECT c.sensor_id, c.equipment_id, c.value, c.status, c.timestamp,
               ROW_NUMBER() OVER (PARTITION BY c.sensor_id ORDER BY c.timestamp DESC) as rn
        FROM c
      `;
      const parameters = [];

      if (equipmentId) {
        query = `
          SELECT c.sensor_id, c.equipment_id, c.value, c.status, c.timestamp,
                 ROW_NUMBER() OVER (PARTITION BY c.sensor_id ORDER BY c.timestamp DESC) as rn
          FROM c WHERE c.equipment_id = @equipment_id
        `;
        parameters.push({ name: '@equipment_id', value: parseInt(equipmentId) });
      }

      const querySpec = {
        query: query,
        parameters: parameters
      };

      const { resources } = await container.items.query(querySpec).fetchAll();
      // Row_number = 1 のレコードのみ返す（最新データ）
      return resources.filter(item => item.rn === 1);
    } catch (error) {
      console.error('最新センサーデータ取得エラー:', error);
      throw error;
    }
  }

  // 設備グループ取得
  async getEquipmentGroups() {
    if (this.useMockData) {
      return await mockDataService.getEquipmentGroups();
    }
    
    try {
      const container = this.getContainer('EquipmentGroups');
      const { resources } = await container.items.readAll().fetchAll();
      return resources;
    } catch (error) {
      console.error('設備グループ取得エラー:', error);
      throw error;
    }
  }
}

module.exports = new CosmosDbService();