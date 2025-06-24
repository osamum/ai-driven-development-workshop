const fs = require('fs');
const path = require('path');

class MockDataService {
  constructor() {
    this.sampleDataPath = path.join(__dirname, '../../sample-data');
    this.loadSampleData();
  }

  loadSampleData() {
    try {
      this.equipmentGroups = this.loadJsonFile('01_equipment_groups.json');
      this.equipment = this.loadJsonFile('02_equipment.json');
      this.sensors = this.loadJsonFile('03_sensors.json');
      this.sensorData = this.loadJsonFile('11_sensor_data.json');
      
      console.log('サンプルデータを読み込みました');
    } catch (error) {
      console.error('サンプルデータ読み込みエラー:', error);
      this.initializeEmptyData();
    }
  }

  loadJsonFile(filename) {
    const filePath = path.join(this.sampleDataPath, filename);
    if (fs.existsSync(filePath)) {
      const data = fs.readFileSync(filePath, 'utf8');
      return JSON.parse(data);
    }
    return [];
  }

  initializeEmptyData() {
    this.equipmentGroups = [];
    this.equipment = [];
    this.sensors = [];
    this.sensorData = [];
  }

  async getEquipment(filters = {}) {
    let filteredEquipment = [...this.equipment];

    // フィルター適用
    if (filters.status) {
      filteredEquipment = filteredEquipment.filter(eq => eq.status === filters.status);
    }

    if (filters.equipment_type) {
      filteredEquipment = filteredEquipment.filter(eq => 
        eq.equipment_type.toLowerCase().includes(filters.equipment_type.toLowerCase())
      );
    }

    if (filters.search) {
      const searchTerm = filters.search.toLowerCase();
      filteredEquipment = filteredEquipment.filter(eq => 
        eq.equipment_name.toLowerCase().includes(searchTerm) ||
        eq.equipment_type.toLowerCase().includes(searchTerm)
      );
    }

    if (filters.group_id) {
      filteredEquipment = filteredEquipment.filter(eq => eq.group_id === parseInt(filters.group_id));
    }

    return filteredEquipment;
  }

  async getSensors(equipmentId = null) {
    if (equipmentId) {
      return this.sensors.filter(sensor => sensor.equipment_id === parseInt(equipmentId));
    }
    return this.sensors;
  }

  async getLatestSensorData(equipmentId = null) {
    let data = this.sensorData;
    
    if (equipmentId) {
      data = data.filter(item => item.equipment_id === parseInt(equipmentId));
    }

    // 各センサーの最新データを取得
    const latestData = new Map();
    data.forEach(item => {
      const existing = latestData.get(item.sensor_id);
      if (!existing || new Date(item.timestamp) > new Date(existing.timestamp)) {
        latestData.set(item.sensor_id, item);
      }
    });

    return Array.from(latestData.values());
  }

  async getEquipmentGroups() {
    return this.equipmentGroups;
  }

  async testConnection() {
    return true; // Mock service is always "connected"
  }
}

module.exports = new MockDataService();