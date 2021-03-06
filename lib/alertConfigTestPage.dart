import 'package:flutter/material.dart';
import 'package:flutter_app_file/AlertManager/AlertConfiguration/alertConfiguration.dart';
import 'package:flutter_app_file/AlertManager/AlertConfiguration/alertConfigurationManager.dart';


class AlertConfigPage extends StatefulWidget{
  AlertConfigPage({Key key}): super(key:key);

  @override
  State<StatefulWidget> createState() => _AlertConfigPage();

}

class _AlertConfigPage extends State<AlertConfigPage> {
  int _version;
  List<AlertConfiguration> _configs;
  AlertConfigurationManager alertConfigManager = new AlertConfigurationManager();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    // Init the global instance alertConfigManager
    alertConfigManager.init().then((bool val){
      setState(() {
        _version = alertConfigManager.version;
        _configs = alertConfigManager.configs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 100),
            Text("Version = $_version"),
            Text("$_configs"),
          ],
        ),
      ),
    );
  }

}