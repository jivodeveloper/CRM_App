import 'package:crm_flutter/ui/DeliveryData.dart';
import 'package:crm_flutter/ui/PaymentDetails.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    debugShowCheckedModeBanner: false,
      home: DeliveryData()
  )
 );
}


