import 'package:flutter/services.dart';
import 'package:flutter_app_file/AlertManager/AlertManagerPointData.dart' show alertManager;
import 'package:flutter/material.dart';

class AlertManagerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _AlertManagerPage();
}

class _AlertManagerPage extends State<AlertManagerPage>{

  final _hrTextController = TextEditingController();
  final _rrTextController = TextEditingController();
  final _temTextController = TextEditingController();
  final _spo2TextController = TextEditingController();
  bool _buttonDisabled;
  @override
  void initState() {
    super.initState();
    _buttonDisabled = true;
    alertManager.init().then((bool val){
      setState(() {
        _buttonDisabled = false;
      });
    });
  }


  void dispose() {
    _temTextController.dispose();
    _hrTextController.dispose();
    _rrTextController.dispose();
    _spo2TextController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> alertManagerKey = GlobalKey<ScaffoldState>();
    final UniqueKey submitKey = UniqueKey();





    return Scaffold(
        key: alertManagerKey,
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[


                /// Step 1: Write data
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
                      child: TextField(controller: _temTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Temp")),
                    ),
                    Container(
                      width: 75,
                      child: TextField(controller: _hrTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "HR"),),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 75,
                      child: TextField(controller: _rrTextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "RR"),),
                    ),
                    Container(
                      width: 75,
                      child: TextField(controller: _spo2TextController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "SPO2"),),
                    )

                  ],
                ),

                RaisedButton(
                  key: submitKey,

                  onPressed: _buttonDisabled ? null : () async{
                    double tem = double.parse(_temTextController.text);
                    double hr = double.parse(_hrTextController.text);
                    double rr = double.parse(_rrTextController.text);
                    double spo2 = double.parse(_spo2TextController.text);

                    print("$tem, $hr, $rr, $spo2");
                    print("Added to data");

                    bool inDanger = alertManager.listen(hr, rr, spo2, tem);
                    print(inDanger);

                  },
                  child: Text("Add to alarms"),

                ),


              ],
            ),
          ),
        )
    );
  }
}
