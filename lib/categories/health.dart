import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Health extends StatefulWidget {
  const Health({Key? key}) : super(key: key);

  @override
  _HealthState createState() => _HealthState();
}

class _HealthState extends State<Health> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health"),
      ),
    );
  }
}
