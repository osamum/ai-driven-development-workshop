import json
import logging
import os
from datetime import datetime
from typing import List, Dict, Any, Optional

import azure.functions as func

app = func.FunctionApp()

def load_sample_data(filename: str) -> List[Dict[str, Any]]:
    """サンプルデータファイルを読み込む"""
    try:
        # sample-data ディレクトリからファイルを読み込み
        base_path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
        file_path = os.path.join(base_path, "sample-data", filename)
        
        if not os.path.exists(file_path):
            logging.warning(f"サンプルデータファイルが見つかりません: {file_path}")
            return []
            
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logging.error(f"データ読み込みエラー: {e}")
        return []

@app.route(route="analytics/equipment-efficiency", methods=["GET"])
def equipment_efficiency(req: func.HttpRequest) -> func.HttpResponse:
    """設備効率分析API"""
    logging.info('設備効率分析API が呼び出されました')
    
    try:
        # 設備データとセンサーデータを読み込み
        equipment_data = load_sample_data("02_equipment.json")
        sensor_data = load_sample_data("11_sensor_data.json")
        
        # フィルター適用
        group_id = req.params.get('groupId')
        if group_id:
            group_id = int(group_id)
            equipment_data = [e for e in equipment_data if e.get('group_id') == group_id]
        
        # 設備効率計算（サンプル実装）
        efficiency_data = []
        for equipment in equipment_data:
            equipment_id = equipment.get('equipment_id')
            
            # 該当設備のセンサーデータを取得
            equipment_sensors = [s for s in sensor_data if s.get('sensor_id') in [1, 2, 3]]  # サンプルセンサーID
            
            # 効率計算（サンプル値）
            efficiency = {
                "equipment_id": equipment_id,
                "equipment_name": equipment.get('equipment_name'),
                "availability_rate": 85.2,  # サンプル値
                "performance_rate": 92.7,   # サンプル値  
                "quality_rate": 98.1,       # サンプル値
                "oee_rate": 77.5,           # 総合設備効率
                "last_updated": datetime.now().isoformat(),
                "status": equipment.get('status'),
                "sensor_count": len(equipment_sensors)
            }
            efficiency_data.append(efficiency)
        
        return func.HttpResponse(
            json.dumps(efficiency_data, ensure_ascii=False, indent=2),
            status_code=200,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )
        
    except Exception as e:
        logging.error(f"設備効率分析エラー: {e}")
        return func.HttpResponse(
            json.dumps({"error": f"エラーが発生しました: {str(e)}"}, ensure_ascii=False),
            status_code=500,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )

@app.route(route="analytics/predictive-maintenance", methods=["GET"])
def predictive_maintenance(req: func.HttpRequest) -> func.HttpResponse:
    """予知保全分析API"""
    logging.info('予知保全分析API が呼び出されました')
    
    try:
        # 設備データとセンサーデータを読み込み
        equipment_data = load_sample_data("02_equipment.json")
        sensor_data = load_sample_data("11_sensor_data.json")
        
        equipment_id = req.params.get('equipmentId')
        if equipment_id:
            equipment_id = int(equipment_id)
            equipment_data = [e for e in equipment_data if e.get('equipment_id') == equipment_id]
        
        # 予知保全分析結果（サンプル実装）
        maintenance_predictions = []
        for equipment in equipment_data:
            eq_id = equipment.get('equipment_id')
            
            # AI分析結果（サンプル値）
            prediction = {
                "equipment_id": eq_id,
                "equipment_name": equipment.get('equipment_name'),
                "failure_probability": 15.3,  # 故障確率%
                "predicted_failure_date": "2024-12-15",
                "maintenance_priority": "中",
                "recommended_actions": [
                    "振動センサー値の継続監視",
                    "潤滑油の点検・交換",
                    "ベアリングの状態確認"
                ],
                "confidence_score": 78.5,
                "analysis_date": datetime.now().isoformat(),
                "risk_factors": [
                    {"factor": "振動レベル", "risk_score": 65},
                    {"factor": "温度上昇", "risk_score": 45},
                    {"factor": "運転時間", "risk_score": 72}
                ]
            }
            maintenance_predictions.append(prediction)
        
        return func.HttpResponse(
            json.dumps(maintenance_predictions, ensure_ascii=False, indent=2),
            status_code=200,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )
        
    except Exception as e:
        logging.error(f"予知保全分析エラー: {e}")
        return func.HttpResponse(
            json.dumps({"error": f"エラーが発生しました: {str(e)}"}, ensure_ascii=False),
            status_code=500,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )

@app.route(route="analytics/sensor-statistics", methods=["GET"])
def sensor_statistics(req: func.HttpRequest) -> func.HttpResponse:
    """センサーデータ統計分析API"""
    logging.info('センサーデータ統計分析API が呼び出されました')
    
    try:
        # センサーデータを読み込み
        sensor_data = load_sample_data("11_sensor_data.json")
        sensors = load_sample_data("03_sensors.json")
        
        sensor_id = req.params.get('sensorId')
        if sensor_id:
            sensor_id = int(sensor_id)
            sensor_data = [s for s in sensor_data if s.get('sensor_id') == sensor_id]
        
        # 統計分析（サンプル実装）
        statistics = []
        
        # センサーごとの統計を計算
        sensor_groups = {}
        for data in sensor_data:
            s_id = data.get('sensor_id')
            if s_id not in sensor_groups:
                sensor_groups[s_id] = []
            sensor_groups[s_id].append(data.get('value', 0))
        
        for s_id, values in sensor_groups.items():
            # 対応するセンサー情報を取得
            sensor_info = next((s for s in sensors if s.get('sensor_id') == s_id), {})
            
            if values:
                stat = {
                    "sensor_id": s_id,
                    "sensor_name": sensor_info.get('sensor_name', f'センサー{s_id}'),
                    "sensor_type": sensor_info.get('sensor_type', 'Unknown'),
                    "measurement_unit": sensor_info.get('measurement_unit', ''),
                    "data_count": len(values),
                    "average": sum(values) / len(values),
                    "minimum": min(values),
                    "maximum": max(values),
                    "normal_range": {
                        "min": sensor_info.get('normal_min', 0),
                        "max": sensor_info.get('normal_max', 100)
                    },
                    "anomaly_count": sum(1 for v in values if v < sensor_info.get('normal_min', 0) or v > sensor_info.get('normal_max', 100)),
                    "analysis_date": datetime.now().isoformat()
                }
                statistics.append(stat)
        
        return func.HttpResponse(
            json.dumps(statistics, ensure_ascii=False, indent=2),
            status_code=200,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )
        
    except Exception as e:
        logging.error(f"センサー統計分析エラー: {e}")
        return func.HttpResponse(
            json.dumps({"error": f"エラーが発生しました: {str(e)}"}, ensure_ascii=False),
            status_code=500,
            headers={'Content-Type': 'application/json; charset=utf-8'}
        )