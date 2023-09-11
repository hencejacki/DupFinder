import 'package:flutter/material.dart';

/// 系统设置界面


class Settings extends StatefulWidget {

  const Settings({super.key});
  
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: 
        Text("Setting Page"),
    );
  }
}