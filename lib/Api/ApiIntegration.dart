import 'dart:convert';
import 'package:crm_flutter/Model/User.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetchPost(String username,String password) async {

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  var response = await http.get(Uri.parse('http://164.52.200.38:90/DeliveryPanel/Login?Username=$username&Password=$password'),headers: headers);

  User user = User.fromJson(json.decode(response.body));

  if (user.empid!=null && user.empid > 0) {

    /*SharePreference*/

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Role','admin');
    prefs.setString('Name',username);
    prefs.setString('Password',password);
    prefs.setString('empid',user.empid.toString());

    return "Logged In Successfully";

  } else{

    return "Please check your credentials";
  }
}