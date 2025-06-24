const express = require('express');
const router = express.Router();
const cosmosDbService = require('../services/cosmosDbService');

// 設備一覧取得（フィルター機能付き）
router.get('/', async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      equipment_type: req.query.equipment_type,
      search: req.query.search,
      group_id: req.query.group_id
    };

    // 空文字列を除去
    Object.keys(filters).forEach(key => {
      if (!filters[key]) {
        delete filters[key];
      }
    });

    console.log('設備検索フィルター:', filters);

    const equipment = await cosmosDbService.getEquipment(filters);
    const sensors = await cosmosDbService.getSensors();
    const sensorData = await cosmosDbService.getLatestSensorData();

    // 設備にセンサー情報を結合
    const equipmentWithSensors = equipment.map(eq => {
      const equipmentSensors = sensors.filter(sensor => sensor.equipment_id === eq.equipment_id);
      const sensorsWithData = equipmentSensors.map(sensor => {
        const latestData = sensorData.find(data => data.sensor_id === sensor.sensor_id);
        return {
          ...sensor,
          current_value: latestData ? latestData.value : null,
          sensor_status: latestData ? latestData.status : '不明',
          last_update: latestData ? latestData.timestamp : null
        };
      });

      return {
        ...eq,
        sensors: sensorsWithData
      };
    });

    res.json({
      success: true,
      data: equipmentWithSensors,
      total: equipmentWithSensors.length,
      filters: filters
    });

  } catch (error) {
    console.error('設備データ取得エラー:', error);
    res.status(500).json({
      success: false,
      error: 'サーバーエラーが発生しました',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 特定設備の詳細取得
router.get('/:id', async (req, res) => {
  try {
    const equipmentId = parseInt(req.params.id);
    
    if (isNaN(equipmentId)) {
      return res.status(400).json({
        success: false,
        error: '無効な設備IDです'
      });
    }

    const equipment = await cosmosDbService.getEquipment({ equipment_id: equipmentId });
    
    if (!equipment || equipment.length === 0) {
      return res.status(404).json({
        success: false,
        error: '指定された設備が見つかりません'
      });
    }

    const sensors = await cosmosDbService.getSensors(equipmentId);
    const sensorData = await cosmosDbService.getLatestSensorData(equipmentId);

    // センサー情報を結合
    const sensorsWithData = sensors.map(sensor => {
      const latestData = sensorData.find(data => data.sensor_id === sensor.sensor_id);
      return {
        ...sensor,
        current_value: latestData ? latestData.value : null,
        sensor_status: latestData ? latestData.status : '不明',
        last_update: latestData ? latestData.timestamp : null
      };
    });

    const equipmentDetail = {
      ...equipment[0],
      sensors: sensorsWithData
    };

    res.json({
      success: true,
      data: equipmentDetail
    });

  } catch (error) {
    console.error('設備詳細取得エラー:', error);
    res.status(500).json({
      success: false,
      error: 'サーバーエラーが発生しました',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 設備グループ一覧取得
router.get('/groups/list', async (req, res) => {
  try {
    const groups = await cosmosDbService.getEquipmentGroups();
    
    res.json({
      success: true,
      data: groups
    });

  } catch (error) {
    console.error('設備グループ取得エラー:', error);
    res.status(500).json({
      success: false,
      error: 'サーバーエラーが発生しました',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// データベース接続状態確認
router.get('/health/db', async (req, res) => {
  try {
    const isConnected = await cosmosDbService.testConnection();
    
    res.json({
      success: isConnected,
      database: process.env.COSMOS_DB_DATABASE_NAME || 'FactoryManagementDB',
      status: isConnected ? 'connected' : 'disconnected'
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'データベース接続確認エラー',
      message: error.message
    });
  }
});

module.exports = router;