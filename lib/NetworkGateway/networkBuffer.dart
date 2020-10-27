import 'dart:io';

/// Network buffer for storing the unsuccessful POST request
/// @author: Yizhou Zhao
/// @date: 2020-10-26 12:01
/// @lastUpdate: 2020-10-27 10:28

import 'package:flutter_app_file/fileManager.dart';
import 'dart:async';
import 'dart:convert';

class NetworkBuffer{
  /// Attributes
  String _fileName;
  FileManager _fileManager;
  List<Map<String, dynamic>> _cache;
  Map<String, dynamic> _typeValidator = new Map<String, dynamic>();
  int _capacity;
  bool _empty;

  /// Constructor
  NetworkBuffer({String fileName:"cacheRequest.json", int capacity:50}){
    _fileName = fileName;
    _fileManager = new FileManager(_fileName);
    _cache = [];
    _capacity = capacity;
    _empty = true;
  }

  /// ====== Methods ======
  /// Get all cached requests
  /// Arguments:
  ///   - None
  /// Return:
  ///   - Future<List<Map<String, dynamic>>>
  Future<List<Map<String, dynamic>>> get cache async{
    String cacheOnFile = await _fileManager.readAll();
    if(cacheOnFile != ""){
      for (var req in json.decode(cacheOnFile)){
        _cache.add(req);
      }

    }
    return _cache;
  }

  /// Add to Cache.
  /// parse arguments to the format: {method: String, endpoint: String, body: dynamic}
  /// Arguments:
  ///   - method: String, HTTP method
  ///   - endpoint: String, endpoint of the api
  ///   - body: dynamic, can be string or Map<String, dynamic>
  /// Return:
  ///   - Future<void>
  /// Throw:
  ///   - FormatException if body is neither String nor Map<String, dynamic>
  Future<void> add(String method, String endpoint, dynamic body) async{
    _empty = false;
    String payload;
    Map<String, dynamic> request = new Map<String, dynamic>();

    // determine the body's type, update payload based on the type
    if(body.runtimeType == "".runtimeType || body.runtimeType == _typeValidator.runtimeType){
      if(body.runtimeType == "".runtimeType){
        // validate json format
        Map<String, dynamic> temp = json.decode(body);

        temp['time'] = DateTime.now().toUtc().toString();

        payload = body;
      }else{
        body['time'] = DateTime.now().toUtc().toString();
        print(body['time']);
        payload = json.encode(body);
      }
    }else{
      throw FormatException("body has to be either String or Map<String, dynamic>, but get ${_typeValidator.runtimeType}");
    }

    // fill the request
    request['method'] = method;
    request['endpoint'] = endpoint;
    request['body'] = payload;

    // add request to cache queue
    _cache.add(request);

    // if cache queue is over capacity, append it to the cache file
    if(_cache.length > _capacity){
      print("Writing to file");
      List<dynamic> temp = [];
      String content = await _fileManager.readAll();
      if(content != ""){
        temp = json.decode(content);
      }
      temp.addAll(_cache);
      _cache = [];
      await _fileManager.flush();
      await _fileManager.writeLine(json.encode(temp));

    }
  }

  Future<void> flush() async{
    await _fileManager.flush();
    _cache = [];
    _empty = true;
  }



  /// Getter of the empty
  bool get empty{
    return _empty;
  }

}