import 'package:flutter/material.dart';
import 'package:flutter_app_file/AlertConfiguration/alertConfigurationManager.dart';
import 'package:flutter_app_file/AlertConfiguration/alertConfiguration.dart';
import 'dart:convert';

class AlertConfigPage extends StatefulWidget{
  AlertConfigPage({Key key}): super(key:key);

  @override
  State<StatefulWidget> createState() => _AlertConfigPage();

}

class _AlertConfigPage extends State<AlertConfigPage> {
  int _version;
  List<AlertConfiguration> _configs;
  AlertConfigurationManager _manager = new AlertConfigurationManager();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _manager.init().then((bool success){
      setState(() {
        _version = _manager.version;
        _configs = _manager.configs;
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