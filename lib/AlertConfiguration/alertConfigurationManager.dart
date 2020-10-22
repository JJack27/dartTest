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

    // try to update and load all configs. Or load local config if exception happens
    try{
      _loader.updateConfig().then((bool success){
        // get all local configs
        _loader.loadLocalConfig().then((List<AlertConfiguration> configs){
          _configs = configs;
        });
      });
    }catch (e){
      // get all local configs
      _loader.loadLocalConfig().then((List<AlertConfiguration> configs){
        _configs = configs;
      });
    }

    // check if versions of all configs are the same and give warning if not
    _version = _configs[0].version;
    for (var config in _configs){
      if(config.version != _version){
        print("Warning: version of the config rules are not the same");
      }
    }
  }


  /// getters
  int get version{
    return _version;
  }

  List<AlertConfiguration> get configs{
    return _configs;
  }


}