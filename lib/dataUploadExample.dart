import 'package:flutter/material.dart';
import 'package:flutter_app_file/NetworkGateway/networkManager.dart' show networkManager;
import 'dart:convert';
import 'fetchDataPage.dart';
class DataPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage>{
  String _braceletId;
  String _userId;
  String _addData;
  String _fetchedData;

  double _tem;
  double _acx;
  double _acz;
  double _bat;
  double _red;
  double _ir;

  final _temTextController = TextEditingController();
  final _acxTextController = TextEditingController();
  final _aczTextController = TextEditingController();
  final _batTextController = TextEditingController();
  final _redTextController = TextEditingController();
  final _irTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tem = 0;
    _acx = 0;
    _acz = 0;
    _bat = 0;
    _red = 0;
    _ir = 0;
  }


  void dispose() {
    _temTextController.dispose();
    _acxTextController.dispose();
    _aczTextController.dispose();
    _batTextController.dispose();
    _redTextController.dispose();
    _irTextController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> dataPageKey = GlobalKey<ScaffoldState>();
    final UniqueKey loginKey = UniqueKey();
    final UniqueKey addBraceletKey = UniqueKey();
    final UniqueKey dataKey = UniqueKey();
    Map<String, dynamic> loginInfo = {
      "username": "JJack27",
      "password": "Apple1996"
    };

    Map<String, dynamic> braceletInfo = {
      "mac_addr": "11:22:33:44:55:66",
    };

    Map<String, dynamic> dataInfo = {
      "tem": 0,
      "acx": 0,
      "acz": 0,
      "bat": 0,
      "red": 0,
      "ir": 0,
      "bracelet": "",
    };
    return Scaffold(
      key: dataPageKey,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              /// Step 1
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                    Text("Step 1: Login"),
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                  ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("* Note that the account had been created already. *")],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("* Registering feature is implemented. *")],
              ),
              RaisedButton(
                key: loginKey,
                onPressed: () async {
                  print("Trying to login");

                  var response = await networkManager.post('/api/login/', loginInfo);
                  if(response.statusCode == 200){
                    setState(() {
                      _userId = json.decode(response.body)['id'];
                    });

                  }else{
                    dataPageKey.currentState.showSnackBar(SnackBar(
                      content: Text("Error"),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                child: Text("Login"),

              ),
              Text("Request = ${loginInfo.toString()}"),
              Text("User ID = $_userId"),
              SizedBox(height: 45),

              /// Step 2 Add a bracelet for current login user
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                    Text("Step 2: Add a bracelet"),
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                  ]
              ),
              RaisedButton(
                key: addBraceletKey,
                onPressed: () async {
                  print("Trying to adding a bracelet");

                  var response = await networkManager.post('/api/bracelet/$_userId/', braceletInfo);
                  if(response.statusCode == 200){
                    setState(() {
                      _braceletId = json.decode(response.body)['bracelet']['id'];
                    });

                  }else{
                    dataPageKey.currentState.showSnackBar(SnackBar(
                      content: Text("Error"),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                child: Text("Add bracelet"),

              ),
              Text("Request = ${braceletInfo.toString()}"),
              Text("Bracelet ID = $_braceletId"),
              SizedBox(height: 45),

              /// Step 3: Upload data points
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                    Text("Step 3: Upload vital signs"),
                    Expanded(
                        child: Divider(indent: 20, thickness: 3, endIndent: 20)
                    ),
                  ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Container(
                    width: 75,
                    child: TextField(controller: _temTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "TEM")),
                  ),
                  Container(
                    width: 75,
                    child: TextField(controller: _acxTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "ACX"),),
                  ),
                  Container(
                    width: 75,
                    child: TextField(controller: _aczTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "ACZ"),),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 75,
                    child: TextField(controller: _batTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "BAT"),),
                  ),
                  Container(
                    width: 75,
                    child: TextField(controller: _redTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "RED"),),
                  ),
                  Container(
                    width: 75,
                    child: TextField(controller: _irTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "IR"),),
                  ),
                ],
              ),

              RaisedButton(
                key: dataKey,
                onPressed: () async{
                  _tem = double.parse(_temTextController.text);
                  _acx = double.parse(_acxTextController.text);
                  _acz = double.parse(_aczTextController.text);
                  _bat = double.parse(_batTextController.text);
                  _red = double.parse(_redTextController.text);
                  _ir = double.parse(_irTextController.text);

                  print("$_tem, $_acx, $_acz, $_bat, $_red, $_ir");
                  print("Trying to upload data");

                  dataInfo = {
                    "tem": _tem,
                    "acx": _acx,
                    "acz": _acz,
                    "bat": _bat,
                    "red": _red,
                    "ir": _ir,
                    "bracelet": _braceletId,
                  };

                  var response = await networkManager.request('POST','/api/data/$_userId/', body:dataInfo);
                  if(response.statusCode == 200){
                    dataPageKey.currentState.showSnackBar(SnackBar(
                      content: Text("Data Uploaded"),
                      duration: Duration(seconds: 2),
                    ));
                  }else{
                    dataPageKey.currentState.showSnackBar(SnackBar(
                      content: Text("Error"),
                      duration: Duration(seconds: 2),
                    ));
                  }

                },
                child: Text("Upload"),

              ),

              RaisedButton(
                child: Text("Fetch Data"),
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FetchDataPage(_userId),
                      ),
                  );
                },
              )

            ],
          ),
        ),
      )
    );
  }
}