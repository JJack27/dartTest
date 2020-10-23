import 'package:flutter_app_file/AlertManager/AlertConfiguration/alertConfiguration.dart';
import 'package:flutter_app_file/AlertManager/AlertConfiguration/_alertConfigurationLoader.dart';

class AlertConfigurationManager{
  /// attributes
  AlertConfigurationLoader _loader;
  int _version;
  List<AlertConfiguration> _configs;
  bool _inited;


  /// Constructor
  AlertConfigurationManager(){
    _inited = false;
    _loader = AlertConfigurationLoader();
  }


  /// getters
  int get version {
    if(!_inited){
      throw Exception("You need to call AlertManager.init() first before getting info.");
    }
    return _version;
  }

  List<AlertConfiguration> get configs {
    if(!_inited){
      throw Exception("You need to call AlertManager.init() first before getting info.");
    }
    return _configs;
  }

  /// Initialization Method
  /// !Note: this method must be called before getting any information.
  /// Return:
  ///   - Future<bool>: true if configurations are successfully initialized.
  Future<bool> init() async{

    // get local config first
    _configs = await _loader.loadLocalConfig();
    _version = _configs[0].version;
    _inited = true;

    // try to update and load all configs. Or load local config if exception happens
    try{
      _loader.updateConfig().then((bool val) async {
        _configs = await _loader.loadLocalConfig();
        _version = _configs[0].version;
      });
      return true;
    }catch (e){
      print("Loading local config");
      return true;
    }
  }

}

/// Global instance
/// AlertConfigurationManager alertConfigManager = new AlertConfigurationManager();