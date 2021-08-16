import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:crm_flutter/ui/Dashboard.dart';
import 'package:crm_flutter/Model/User.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool is_Hidden = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  late ArsProgressDialog progressDialog;
  late ExpandableController categoryController;
  late StreamSubscription<DataConnectionStatus> listener;
  var InternetStatus = "Unknown";
  var contentmessage = "Unknown";
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) =>
      new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit App ?'),
        actions: <Widget>[
          Row(
            children: [
              Expanded(child: new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Padding(padding: EdgeInsets.all(5),
                    child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff18325e),
                          borderRadius:
                          BorderRadius.all(Radius.circular(15.0)),
                        ),
                        width: double.infinity,
                        height: 40,

                        child: Align(
                            alignment: Alignment.center,
                            child: Text("No",
                              style: TextStyle(color: Colors.white),)
                        )

                    ),)


              ),),

              Expanded(child: new GestureDetector(
                  onTap: () => exit(0),
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff18325e),
                            borderRadius:
                            BorderRadius.all(Radius.circular(15.0)),
                          ),
                          width: double.infinity,
                          height: 40,

                          child: Align(
                              alignment: Alignment.center,
                              child: Text("Yes",
                                style: TextStyle(color: Colors.white),)
                          )
                      )
                  )
              ),)

            ],
          )

        ],
      ),
    ) ?? false;
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }

  @override
  void initState() {
    super.initState();
    checkConnection(context);
    categoryController = ExpandableController(initialExpanded: false);
    progressDialog = ArsProgressDialog(
        context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image.asset('assets/Images/logo.png',height: 200,width: 200),
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 150),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Color(0xff18325e),
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 15),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Please login to continue",
                              style: TextStyle(
                                color: Color(0xff18325e),
                                fontSize: 15,),
                            ),
                          )
                        ],
                      )
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 10, top: 40, right: 10),
                              child: Column(
                                children: [
                                  Material(
                                    elevation: 20.0,
                                    child: TextFormField(
                                      controller: username,
                                      // style: TextStyle(
                                      //   height: 3.0,
                                      // ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter username';
                                        }
                                      },
                                      decoration: InputDecoration(
                                        // enabledBorder: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.circular(15.0),
                                        // ),
                                        // focusedBorder: OutlineInputBorder(
                                        //   borderSide: BorderSide(
                                        //       color: Colors.grey, width: 2.0),
                                        //   borderRadius: BorderRadius.circular(15.0),
                                        // ),
                                          prefixIcon: Icon(
                                              Icons.account_circle_sharp),
                                          // border: OutlineInputBorder(),
                                          hintText: 'Username'),
                                    ),
                                  )
                                ],
                              )
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 10, top: 35, right: 10),
                            child: Column(
                              children: [
                                Material(
                                    elevation: 20.0,
                                    child: TextFormField(
                                      controller: password,
                                      obscureText: is_Hidden,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password';
                                        }
                                      },
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.lock),
                                          suffix: InkWell(
                                            onTap: _togglePasswordView,
                                            child: Icon(Icons.visibility),
                                          ),
                                          // border: OutlineInputBorder(),
                                          hintText: 'Password'),
                                    )
                                )
                              ],
                            ),

                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: 10, top: 35, right: 10),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text("Forget Password", style: TextStyle(
                                    fontStyle: FontStyle.italic
                                ),),
                              )
                          ),
                          new GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  progressDialog.show();
                                  initConnectivity();
                                  _connectivitySubscription =
                                      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

                                  // fetchPost(username.text, password.text);
                                  // Future<String> msg = fetchPost(username.text,password.text);

                                  // if(msg=="Logged In Successfully"){
                                  //   Navigator.push(context,MaterialPageRoute(builder: (context) => Dashboard()));
                                  // }else{
                                  //   // Fluttertoast.showToast(
                                  //   //     msg: "Please check your credentials",
                                  //   //     toastLength: Toast.LENGTH_SHORT,
                                  //   //     gravity: ToastGravity.BOTTOM,
                                  //   //     timeInSecForIosWeb: 1,
                                  //   //     backgroundColor: Colors.black,
                                  //   //     textColor: Colors.white,
                                  //   //     fontSize: 16.0);
                                  // }
                                }
                              },
                              child: new Container(
                                margin: EdgeInsets.only(left: 10,
                                    top: 35,
                                    right: 10),
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xff18325e),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                                ),
                                child: Center(
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(color: Colors.white),
                                    )
                                ),
                              )
                          )
                        ],
                      )
                  )
                ],
              ),
            )),
      ),
    );
  }
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  void dispose() {
    listener.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        return fetchPost(username.text, password.text);
      case ConnectivityResult.mobile:
        return fetchPost(username.text, password.text);
      case ConnectivityResult.none:
        progressDialog.dismiss();
        Fluttertoast.showToast(
            msg: "No internet please try again!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        // setState(() => _connectionStatus = result.toString());
        break;
      default:
        progressDialog.dismiss();
        Fluttertoast.showToast(
            msg: "No internet please try again!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        // setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  Future fetchPost(String username, String password) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.get(Uri.parse(
        'http://164.52.200.38:90/DeliveryPanel/Login?Username=$username&Password=$password'),
        headers: headers);

    User user = User.fromJson(json.decode(response.body));

    if (user.empid != null && user.empid > 0) {

      /*SharePreference*/

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Role', 'admin');
      prefs.setString('Name', username);
      prefs.setString('Password', password);

      prefs.setString('empid', user.empid.toString());

      Fluttertoast.showToast(
          msg: "Logged In Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).push(_createRoute());
      // Navigator.push(context,MaterialPageRoute(builder: (context) => Dashboard()));

      //  return "Logged In Successfully";
    } else {
      progressDialog.dismiss();
      Fluttertoast.showToast(
          msg: "Please check your credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      // return "Please check your credentials";
    }
  }

  void _togglePasswordView() {
    setState(() {
      is_Hidden = !is_Hidden;
    });
  }

  checkConnection(BuildContext context) async {
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          InternetStatus = "Connected to the Internet";
          contentmessage = "Connected to the Internet";
          _showDialog(InternetStatus, contentmessage, context);
          break;
        case DataConnectionStatus.disconnected:
          InternetStatus = "You are disconnected to the Internet. ";
          contentmessage = "Please check your internet connection";
          _showDialog(InternetStatus, contentmessage, context);
          break;
      }
    });
    return await DataConnectionChecker().connectionStatus;
  }

  void _showDialog(String title, String content, BuildContext context) async {
    if(content=="Please check your internet connection"){
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if(prefs.getBool("intenet")==true){
        prefs.clear();
      }else{
        prefs.setBool("intenet",true);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: new Text("Message"),
                  content: new Text(content),
                  actions: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text("Close"))
                  ]
              );
            }
        );
      }
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Dashboard(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

