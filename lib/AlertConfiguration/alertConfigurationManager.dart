import 'alertConfiguration.dart';
import 'package:flutter_app_file/AlertConfiguration/_alertConfigurationLoader.dart';
import 'dart:convert';

class AlertConfigurationManager{
  /// attributes
  AlertConfigurationLoader _loader;
  int _version;
  List<AlertConfiguration> _configs;


  /// Constructor
  AlertConfigurationManager(){
    _loader = AlertConfigurationLoader();
  }


  /// getters
  int get version {
    return _version;
  }

  List<AlertConfiguration> get configs {
    return _configs;
  }

  /// Initialization Method
  Future<bool> init() async{
    bool success;
    // try to update and load all configs. Or load local config if exception happens
    try{
      success = await _loader.updateConfig();
    }catch (e){
      success = false;
    }

    // get all local configs
    _configs = await _loader.loadLocalConfig();
    _version = _configs[0].version;

    return success;
  }

}