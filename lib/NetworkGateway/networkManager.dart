/// Network manager responsible for fetching data from the internet as well as
/// sending HTTP requests.
/// @author: Yizhou Zhao
/// @date: 2020-10-16 13:19
/// @lastUpdate: 2020-10-26 12:01

// Importing in-package components
import 'package:flutter_app_file/NetworkGateway/httpClient.dart';
import 'package:flutter_app_file/NetworkGateway/networkBuffer.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:math';


class NetworkManager{
  /// attributes
  HttpClient _client = null;
  NetworkBuffer _buffer = null;

  /// constructor
  NetworkManager(String ipAddr, {bool nursingHome: true, String apiLogout:'/api/logout/'}){
    // initialize httpClient
    _client = new HttpClient(ipAddr, nursingHome: nursingHome, apiLogout:apiLogout);

  }


  /// ====== Methods ======
  /// Abstract the HttpClient.post() method
  /// Arguments:
  ///   - apiUri: String. Started and ended with '/'
  ///   - body: Dynamic. Can be String in JSON format, or Map<String, dynamic>.
  ///           Note that Map<String, dynamic> will be converted to JSON format.
  /// Return:
  ///   - Future<http.Response>
  Future<http.Response> post(String apiUri, dynamic body) async{
    return _client.post(apiUri, body);
  }


  /// Abstract the HttpClient.get() method
  /// Arguments:
  ///   - apiUri: String. Started and ended with '/'
  /// Return:
  ///   - Future<http.Response>
  Future<http.Response> get(String apiUri) async {
    return _client.get(apiUri);
  }

  /// Abstract the HttpClient.ping() method
  /// Arguments:
  ///   - void
  /// Return:
  ///   - Future<bool>: true if the server is available.
  Future<bool> ping() async{
    return _client.ping();
  }


  void closeClient(){
    this._client.closeClient();
  }


}


NetworkManager networkManager;

