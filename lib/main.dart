// @dart=2.9
import 'package:crm_flutter/ui/ConnectionProblem.dart';
import 'package:crm_flutter/ui/DeliveryData.dart';
import 'package:crm_flutter/ui/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen()
    );
  }

}


