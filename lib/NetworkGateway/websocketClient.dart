import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;


class WebSocketClient{
  String _ipToConnect;
  bool _nursingHome;
  String _api;
  IOWebSocketChannel _channel;

  /// Constructor
  /// Arguments:
  ///   - ipAddr: String, full ip address if nursingHome is false, or only the
  ///             last two groups of ip address if nursingHome is true
  ///   - nursingHome: bool, optional. Tell NetworkManager if it's connecting to
  ///             nursing home or not
  WebSocketClient(String ipAddr, String api, {bool nursingHome: true, String apiLogout:'/api/logout/', String port:""}){
    _nursingHome = nursingHome;
    _api = api;
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
      _ipToConnect += port;
    }else{
      // connect to server in cloud
      this._ipToConnect = ipAddr;
    }

    _channel = IOWebSocketChannel.connect("ws://$_ipToConnect/$_api");
  }

}