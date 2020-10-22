/// Class for updating, saving, and reading alert configurations
/// @author: Yizhou Zhao
/// @date: 2020-10-22 13:21
/// @lastUpdate: 2020-10-22 13:21

import 'package:flutter_app_file/NetworkGateway/networkManager.dart' show networkManager;
import 'package:flutter_app_file/fileManager.dart';
import 'package:flutter_app_file/AlertConfiguration/alertConfiguration.dart';
import 'dart:async';
import 'dart:convert';

class AlertConfigurationLoader{
  String _fileName = "config.json";
  FileManager _fileManager;

  /// Constructor
  AlertConfigurationLoader(){
    _fileManager = new FileManager(_fileName);
  }

  /// Read the configuration on the local file
  Future<List<AlertConfiguration>> loadLocalConfig() async{
    return _fileManager.readAll().then((String content){
      List<AlertConfiguration> configs = [];

      // read the content of the local config file
      List<dynamic> configsMap = json.decode(content);

      // parse configurations
      for(var map in configsMap){
        AlertConfiguration config = new AlertConfiguration(
            map['name'],
            map['compare'],
            map['range_min'],
            map['range_max'],
            map['duration'],
            map['version']
        );

        configs.add(config);
      }
      return configs;
    });
  }

  /// Getting the latest configurations from the server
  /// return:
  ///   - String: the json formatted response from the server
  /// throws:
  ///   - Exception: when status code is not 200
  ///   - TimeoutException: when the server is unable to connect
  Future<String> _loadLatestConfig() async{
    var response = await networkManager.get('/api/latestconfig/');
    if(response.statusCode != 200){
      throw Exception("Service is current unavailable. Using local config.");
    }
    return response.body;
  }

  /// Load the latest config from the server and update the local config file
  /// return:
  ///   - bool: true if configurations is successfully updated or it's already
  ///     the latest version
  /// throws:
  ///   - TimeoutException
  Future<bool> updateConfig() async{

    try{
      String latestConfig = await _loadLatestConfig();
      Map<String, dynamic> map = json.decode(latestConfig);
      // clear current config content
      _fileManager.flush();
      // write to the file
      _fileManager.writeLine(json.encode(map['config']));
      return true;
    }catch (e) {
      return false;
    }
  }

}