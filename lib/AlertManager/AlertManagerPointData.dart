/// Alert manager for point data
/// Allowing user to:
///   - Create alarms based on configurations
///   - Accepting data from other components
///   - Handle alerts
/// ==============================
/// @author: Yizhou Zhao
/// @date: 2020-10-23 13:54
/// @lastUpdate: 2020-10-23 16:27

import 'package:flutter_app_file/AlertManager/AlertConfiguration/alertConfigurationManager.dart';
import 'package:flutter_app_file/AlertManager/AlertPointData.dart';

class AlertManagerPointData{
  List<AlertPointData> _alarms = [];
  AlertConfigurationManager _configManager;

  // A list of alarm configuration ID that triggered the emergency event
  List<int> _raisedAlarms = [];

  /// constructor
  AlertManagerPointData(){
    _configManager = new AlertConfigurationManager();
  }


  /// Initializing components
  Future<bool> init() async{
    await _configManager.init();

    // setting alarms
    for(var config in _configManager.configs){
      AlertPointData alarm = new AlertPointData(config.name, config.id, config.compare, config.rangeMin, config.rangeMax, config.duration);
      _alarms.add(alarm);
    }

    return true;
  }

  /// Listen to data
  /// Arguments:
  ///   - hr: double, heart rate
  ///   - rr: double, respiration rate
  ///   - spo2: double, oxygen saturation
  ///   - temp: double, temperature
  bool listen(double hr, double rr, double spo2, double temp){
    bool warn = false;

    // feed data into alarms
    for(var alarm in _alarms){
      bool tempWarn;
      switch (alarm.name){
        case "HR":{
          tempWarn = alarm.inDanger(hr);
        }break;
        case "TEM":{
          tempWarn = alarm.inDanger(temp);
        }break;
        case "RR":{
          tempWarn = alarm.inDanger(rr);
        }break;
        case "O2S":{
          tempWarn = alarm.inDanger(spo2);
        }break;
      }
      // if current alarm is raised, record
      if(tempWarn){
        _raisedAlarms.add(alarm.configId);
      }

      warn |= tempWarn;
    }
    return warn;
  }

  /// Clear raisedAlarms
  /// Arguments:
  ///   - None
  /// Return:
  ///   - None
  void clearAlarms(){
    _raisedAlarms = [];
  }

  /// getters
  List<int> get raisedAlarms{
    return _raisedAlarms;
  }

}

/// Global instance
AlertManagerPointData alertManager = new AlertManagerPointData();

void main() async {
  /// Example for using alertManager
  double hr, rr, spo2, temp = 0;

  // 1: Init alertManager, it's async so it cannot be done in Constructor
  await alertManager.init();

  // 2: Feed data into the manager
  bool inDanger = alertManager.listen(hr, rr, spo2, temp);

  if(inDanger){
    print("In danger!");
  }


}