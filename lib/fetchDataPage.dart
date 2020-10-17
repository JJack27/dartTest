import 'package:flutter/material.dart';
import 'package:flutter_app_file/NetworkGateway/networkManager.dart' show networkManager;
import 'dart:convert';

class FetchDataPage extends StatefulWidget{
  final String userId;

  FetchDataPage(this.userId,{Key key}): super(key:key);

  @override
  State<StatefulWidget> createState() => _FetchDataPageState();

}

class _FetchDataPageState extends State<FetchDataPage> {
  String _response = "";
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    init().then((result){
      setState(() {
        _response = result;
      });

    });
    print(_response);
  }



  Future<String> init() async{
    print("Getting data");
    String result = "";
    var response = await networkManager.get('/api/data/${widget.userId}/');
    String responseBody = response.body;
    List<String> parsedBody = responseBody.split(",");
    for(var body in parsedBody){
      result += body;
      result += "\n";
    }
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("User Id = ${widget.userId}"),
            SizedBox(height: 100),
            Text("$_response"),
          ],
        ),
      ),
    );
  }

}