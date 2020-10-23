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
  String _defualtConfig = '''[
    {
    "id": 10,
    "name": "HR",
    "compare": 0,
    "range_min": 200.0,
    "range_max": 0.0,
    "duration": 15,
    "version": 1
    },
    {
      "id": 11,
      "name": "HR",
      "compare": 1,
      "range_min": 0.0,
      "range_max": 40.0,
      "duration": 15,
      "version": 1
    },
    {
      "id": 12,
      "name": "HR",
      "compare": 2,
      "range_min": 147.0,
      "range_max": 153.0,
      "duration": 300,
      "version": 1
    },
    {
      "id": 13,
      "name": "HR",
      "compare": 1,
      "range_min": 0.0,
      "range_max": 1.0,
      "duration": 5,
      "version": 1
    },
    {
      "id": 14,
      "name": "TEM",
      "compare": 0,
      "range_min": 38.0,
      "range_max": 0.0,
      "duration": 300,
      "version": 1
    },
    {
      "id": 15,
      "name": "TEM",
      "compare": 1,
      "range_min": 0.0,
      "range_max": 35.0,
      "duration": 300,
      "version": 1
    },
    {
      "id": 16,
      "name": "O2S",
      "compare": 1,
      "range_min": 0.0,
      "range_max": 0.99,
      "duration": 60,
      "version": 1
    },
    {
      "id": 17,
      "name": "RR",
      "compare": 0,
      "range_min": 25.0,
      "range_max": 0.0,
      "duration": 120,
      "version": 1
    },
    {
      "id": 18,
      "name": "RR",
      "compare": 0,
      "range_min": 30.0,
      "range_max": 0.0,
      "duration": 60,
      "version": 1
    }
  ]''';

  /// Constructor
  AlertConfigurationLoader(){
    _fileManager = new FileManager(_fileName);
  }

  /// Read the configuration on the local file
  Future<List<AlertConfiguration>> loadLocalConfig() async{
    return _fileManager.readAll().then((String content){
      List<AlertConfiguration> configs = [];

      if(content.length == 0){
        content = _defualtConfig;
      }

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