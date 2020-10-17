import 'dart:io';

import 'package:flutter/material.dart';
/// Network manager responsible for fetching data from the internet as well as
/// sending HTTP requests.
/// @author: Yizhou Zhao
/// @date: 2020-10-16 13:19
/// @lastUpdate: 2020-10-16 13:19

//import 'package:flutter_app_file/fileManager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
class NetworkManager{
  // attributes
  String _ipToConnect;
  String _apiLogout;
  Map<String, String> _headers = {'content-type':'application/json'};
  bool _nursingHome;
  var _client = http.Client();
  Map<String, dynamic> _formatValidator = {"Validate": "Purpose"};

  /// Constructor
  /// Arguments:
  ///   - ipAddr: String, full ip address if nursingHome is false, or only the
  ///             last two groups of ip address if nursingHome is true
  ///   - nursingHome: bool, optional. Tell NetworkManager if it's connecting to
  ///             nursing home or not
  NetworkManager(String ipAddr, {bool nursingHome: true, String apiLogout}){
    _nursingHome = nursingHome;
    _apiLogout = apiLogout;

    // If the user is connecting to nursing home's raspberry pi
    if(_nursingHome){
      // Validate the first group of ip address
      if(int.parse(ipAddr.substring(0, 3)) < 0 || int.parse(ipAddr.substring(0, 3)) > 255) {
        FormatException("Your input is invalid");
      }
      // validate the second group of ip address
      if(int.parse(ipAddr.substring(3, 6)) < 0 || int.parse(ipAddr.substring(3, 6)) > 255){
        FormatException("Your input is invalid");
      }
      this._ipToConnect = '192.168.'+ int.parse(ipAddr.substring(0, 3)).toString() + "." + int.parse(ipAddr.substring(3, 6)).toString();
      //_ipToConnect += ":8000";
    }else{
      // connect to server in cloud
      this._ipToConnect = ipAddr;
    }
  }


  void initClient(){
    this._client = new http.Client();
  }

  void closeClient(){
    this._client.close();
  }

  /// Abstract the http.Client.get() method
  /// Arguments:
  ///   - apiUri: String. Started and ended with '/'
  /// Return:
  ///   - Future<http.Response>
  Future<http.Response> get(String apiUri) async {
    var uriResponse = await _client.get('http://'+_ipToConnect+apiUri, headers: _headers);
    return uriResponse;
  }


  /// Abstract the http.Client.post() method
  /// Arguments:
  ///   - apiUri: String. Started and ended with '/'
  ///   - body: Dynamic. Can be String in JSON format, or Map<String, String>.
  ///           Note that Map<String, dynamic> will be converted to JSON format.
  /// Return:
  ///   - Future<http.Response>
  Future<http.Response> post(String apiUri, dynamic body) async{
    String payload;

    // check the argument types
    if(body.runtimeType != "".runtimeType && body.runtimeType != _formatValidator.runtimeType){
      throw FormatException("Format of body is incorrect");
    }

    // If body is Map<String, dynamic>
    if(body.runtimeType == _formatValidator.runtimeType){
      payload = json.encode(body);
    }else{
      // validate format if it's string
      json.decode(body);
      payload = body;
    }

    // Send post request
    var uriResponse = await _client.post('http://'+_ipToConnect+apiUri, headers: _headers, body: payload);
    // Update header
    _updateHeaders(uriResponse.headers, apiUri);

    return uriResponse;
  }


  /// Update headers of request that _client used to send request
  /// Arguments:
  ///   - headers: Map<String, dynamic>, headers from response
  ///   - apiUri: String, the api uri just sent
  /// Return:
  ///   - Void
  void _updateHeaders(Map<String, dynamic> headers, String apiUri){
    // get csrfToken if possible
    if(headers.containsKey('set-cookie')){
      _headers['cookie'] = "";
      List<String> cookies = headers['set-cookie'].split(";");
      for(String cookie in cookies){
        if(cookie.contains("csrftoken")){
          _headers['x-csrftoken'] = cookie.split('=')[1];

        }
        if(cookie.contains('csrftoken') || cookie.contains("SameSite")){
          _headers['cookie'] += cookie.split(",")[0] + ";";
        }
        if(cookie.contains("sessionid")){
          cookie = cookie.split(",")[1];
          _headers['cookie'] += cookie + ";";
        }
      }
    }

    // if user is logged out, discard current csrftoken
    if(apiUri == _apiLogout && _headers.containsKey('x-csrftoken')){
      _headers.remove('x-csrftoken');
    }
  }

  Future<bool> ping() async{
    try {
      var respone = await this.get('');
      return respone.statusCode == 200;
    }on SocketException{
      return false;
    }

  }
}


NetworkManager networkManager;

Future<void> main() async{
  String userId;
  String braceletId;
  NetworkManager networkManager = new NetworkManager('001074');

  /// Testing login
  Map<String, dynamic> loginInfo = {'username':"JJack27", "password":"Apple1996"};
  http.Response response = await networkManager.post('/api/login/', loginInfo);
  assert(response.statusCode == 200, "Incorrect status code, expecting 200, get ${response.statusCode}");
  Map<String, dynamic> responseBody = json.decode(response.body);
  userId = responseBody['id'];
  print("User Id = $userId");

  /// Testing Add bracelet
  Map<String, dynamic> bracelet = {"mac_addr": "12:23:23:23:23:33"};
  http.Response responseBracelet = await networkManager.post('/api/bracelet/$userId/', bracelet);
  assert(responseBracelet.statusCode == 200, "Incorrect status code, expecting 200, get ${responseBracelet.statusCode}");
  responseBody = json.decode(responseBracelet.body);
  braceletId = responseBody['bracelet']['id'];
  print("Bracelet Id = $braceletId");

  /// Testing adding data
  List<Map<String, dynamic>> requestPayloads = [];
  Random randomGenerator = Random();
  for(int i = 0; i < 10; i++){
    Map<String,dynamic> payload = {
      "bracelet": braceletId,
      'tem': randomGenerator.nextDouble(),
      'acx': randomGenerator.nextDouble(),
      'acz': randomGenerator.nextDouble(),
      'bat': randomGenerator.nextDouble(),
      'red': randomGenerator.nextDouble(),
      'ir': randomGenerator.nextDouble()
    };
    requestPayloads.add(payload);
  }
  // send data
  for (var payload in requestPayloads){
    http.Response responseData = await networkManager.post('/api/data/$userId/', payload);
    assert(responseData.statusCode == 200, "Incorrect status code, expecting 200, get ${responseData.statusCode}");
  }
  print("Pass!");
}