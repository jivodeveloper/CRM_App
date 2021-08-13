import 'package:crm_flutter/Code.dart';
import 'package:crm_flutter/ui/ConnectionProblem.dart';
import 'package:crm_flutter/ui/DeliveryData.dart';
import 'package:crm_flutter/ui/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(new MyApp());
 //  runApp(MaterialApp(
 //      theme: ThemeData(
 //        primarySwatch: Colors.blue,
 //      ),
 //    debugShowCheckedModeBanner: false,
 //      home: DeliveryData()
 //  )
 // );
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


