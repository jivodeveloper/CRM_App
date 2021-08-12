import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crm_flutter/Helper/DatabaseHelper.dart';
import 'package:crm_flutter/Model/PaymentJSON.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding, timeDilation;
import 'package:crm_flutter/Helper/PaymentDatabaseHelper.dart';
import 'package:crm_flutter/Model/Items.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
import 'package:crm_flutter/Model/Payment.dart';
import 'package:crm_flutter/Model/Paymentdetails.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NumberList {
  String number;
  int index;
  NumberList({required this.number, required this.index});
}

class DeliveryDatas extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DeliveryDataState();
  }
}

class DeliveryDataState extends State<DeliveryDatas> {
  List<OrderList> order_list = [];
  // Set<OrderList> order_list = Set<Ord;
  List<String> payment_details = [];
  late ArsProgressDialog progressDialog;
  bool select_all = false;
  String empid = "", name = "", mobile = "";
  double amount = 0.0;
  // String payment_details = "";
  Map<String, bool> values = {
    'COD': false,
    'PAYTM': false,
  };

  List<NumberList> nList = [
    NumberList(
      index: 1,
      number: "COD",
    ),
    NumberList(
      index: 2,
      number: "Paytm",
    ),
    NumberList(
      index: 3,
      number: "Net Banking",
    ),
  ];

  MultiSelectController controller = new MultiSelectController();
  TextEditingController reference_id = new TextEditingController();
  TextEditingController bal_amtc = new TextEditingController();
  List _selecteCategorysID = [];

  bool valuefirst = false;
  bool valuesecond = false;
  List<Items> json_data = [];
  List<int> amnt_total = [];
  int item_val = 0;
  List<int> json_payment = [];
  List<PaymentJSON> list_data = [];
  List<Paymentdetails> payment_data = [];
  List<Payment> delivery_data = [];
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late ExpandableController categoryController;
  final paymenthepler = PaymentDatabaseHelper.instance;
  String radioItemHolder = '';
  final _formKey = GlobalKey<FormState>();
  bool bal_amt = false, ref_amt = false;
  // Group Value for Radio Button.
  int id = 1;

  @override
  void initState() {
    super.initState();
    categoryController = ExpandableController(initialExpanded: false);
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    // Provider.of<ConnectivityProvider>(context,listen:false).startMonitioring();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
    // updatepaymentdata();
    getuserdata();
    _queryAll();
    _queryPaymentAll();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /*init*/
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = 'Failed to get connectivity');
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  /*checkconnnection*/
  checkuserconnection() {}

  /* to receive empid*/
  getuserdata() async {
    progressDialog.dismiss();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   empid = prefs.getString('empid')!;
    //   // print("empid$empid");
    // });

    progressDialog.show();
    getdeliverydata(empid);
  }

  /*check interet for delivery data*/
  checkinternetconnection(String status) async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (status == 'Cancel') {
          updatestatus(status);
        } else {
          updatepaymentdata(status);
        }
        progressDialog.dismiss();
      }
    } on SocketException catch (_) {
      int result = 0;
      int bal = 0;
      // print("${bal_amtc.text}");

      if (bal_amtc.text == "") {
        bal = 0;
        result = amount.toInt();
      } else {
        bal = int.tryParse(bal_amtc.text)!;
        if (amount.toInt() > bal) {
          result = amount.toInt() - int.tryParse(bal_amtc.text)!;
        }
      }

      // list_data.add(PaymentJSON(
      //     element.item_id, paymentelement, amount.toInt(), 10044,reference_id.text));

      json_data.forEach((element) {
        payment_details.forEach((paymentelement) {
          if (paymentelement.trim() == "PAYTM" &&
              ref_amt == true &&
              bal_amt == false) {
            print(
                "Paytm${element.item_id}$paymentelement${amount.toInt()}${reference_id.text}");

            insertpayment(element.item_id, paymentelement, amount.toInt(),
                "10044", reference_id.text, status);
          } else if (paymentelement == "COD") {
            print("CODD${element.item_id}$paymentelement$result");
            insertpayment(element.item_id, paymentelement, amount.toInt(),
                "10044", reference_id.text, status);
          } else {
            print("CODDCODD${element.item_id}$paymentelement$bal");
            insertpayment(element.item_id, paymentelement, amount.toInt(),
                "10044", reference_id.text, status);
          }
        });
      });

      // json_data.forEach((element) {
      //   _insert(element.item_id, status);
      // });
      progressDialog.dismiss();
    }
  }

  /*check internet for payment data*/
  // checkinternetpayment(String name, String mobile, double amount,
  //     String reference, String payment_details) async {
  //   try {
  //     final result = await InternetAddress.lookup('www.google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       updatepaymentdata();
  //       //  insertpayment(name, mobile, amount, reference_id.text, payment_details);
  //     }
  //   } on SocketException catch (_) {
  //     insertpayment(name, mobile, amount, reference_id.text, payment_details);
  //   }
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    var isSelected = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff18325e),
          title: Text("Delivery Details"),
          actions: <Widget>[
            Visibility(
                visible:
                select_all == true ? select_all = true : select_all = false,
                child: Row(
                  children: [
                    IconButton(
                        icon: new Icon(Icons.save),
                        onPressed: () =>
                            _displayTextInputDialog(context, "Delivered")),
                    IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: () => checkinternetconnection('Cancel')),
                  ],
                ))
          ],
        ),
        body: _connectionStatus == "Failed to get connectivity."
            ? nointernet()
            : getlayout());
  }

  showlist() {
    json_data.forEach((element) {
      print("${element.item_id}");
    });
  }

  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit App ?'),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: new GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
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
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.white),
                              ))),
                    )),
              ),
              Expanded(
                child: new GestureDetector(
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
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.white),
                                ))))),
              )
            ],
          )
        ],
      ),
    ) ??
        false;
  }

  nointernet() {
    Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget getlayout() {
    return ExpandableTheme(
      data: const ExpandableThemeData(
        iconColor: Colors.blue,
        useInkWell: true,
      ),
      child: ListView.builder(
          itemCount: order_list.length,
          itemBuilder: (context, indexx) {
            return Container(
                child: Column(children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ExpandableNotifier(
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color: Color(0xFFCFD8DC),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: <Widget>[
                                ScrollOnExpand(
                                  scrollOnExpand: true,
                                  scrollOnCollapse: false,
                                  child: ExpandablePanel(
                                    //  controller: categoryController,
                                    theme: const ExpandableThemeData(
                                      headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                      tapBodyToCollapse: false,
                                    ),
                                    header: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(50.0),
                                              topRight: Radius.circular(10.0),
                                              bottomLeft: Radius.circular(10.0),
                                              bottomRight: Radius.circular(10.0))),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 10, right: 10, bottom: 10),
                                          child: Container(
                                            child: Column(children: [
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(
                                                      order_list[indexx].custName,
                                                      style: GoogleFonts.lato(
                                                        textStyle: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ),
                                                  )),
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(
                                                          order_list[indexx].custMobile,
                                                          style: GoogleFonts.lato(
                                                            textStyle: TextStyle(),
                                                          )))),
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(
                                                          order_list[indexx].address,
                                                          style: GoogleFonts.lato(
                                                            textStyle: TextStyle(),
                                                          )))),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                    collapsed: Container(
                                      child: Column(children: []),
                                    ),
                                    expanded: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                    "Id",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                    "Items",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                    "Rate",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                    "Quantity",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                    "Total",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                    "Status",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 5,
                                          thickness: 5,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(10),
                                            height: 200,
                                            width: MediaQuery.of(context).size.width,
                                            child: ListView.builder(
                                                itemCount: order_list[indexx]
                                                    .itemDetails
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                      onLongPress: () {},
                                                      child: MultiSelectItem(
                                                          isSelecting:
                                                          controller.isSelecting,
                                                          onSelected: () {
                                                            setState(() {
                                                              order_list[index]
                                                                  .itemDetails[index]
                                                                  .IsSelect = true;
                                                              controller.toggle(index);
                                                              select_all = true;
                                                              controller
                                                                  .isSelected(index)
                                                                  ? addlist(
                                                                  indexx, index)
                                                                  : removedata(
                                                                  indexx,
                                                                  index,
                                                                  order_list[indexx]
                                                                      .itemDetails[
                                                                  index]
                                                                      .itemId);
                                                              name = order_list[indexx]
                                                                  .custName;
                                                              mobile =
                                                                  order_list[indexx]
                                                                      .custMobile;
                                                              amount = order_list[
                                                              indexx]
                                                                  .itemDetails[index]
                                                                  .itemTotalAmount;
                                                              // amount =
                                                              //     amnt_total
                                                              //         .fold(
                                                              //         0, (p,
                                                              //         c) =>
                                                              //     p + c);
                                                              json_payment.add(
                                                                  order_list[indexx]
                                                                      .itemDetails[
                                                                  index]
                                                                      .itemId);
                                                            });
                                                          },
                                                          child: Container(
                                                            child: Padding(
                                                                padding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                                child: Row(
                                                                  children: [
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                    //  progressDialog.dismiss(),
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .itemId
                                                                                .toString(),
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .itemName,
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .itemRate
                                                                                .toString(),
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .itemQty
                                                                                .toString(),
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .itemTotalAmount
                                                                                .toString(),
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                    if (order_list[
                                                                    indexx]
                                                                        .itemDetails[
                                                                    index]
                                                                        .active ==
                                                                        "Pending")
                                                                      Expanded(
                                                                          child: Text(
                                                                            order_list[
                                                                            indexx]
                                                                                .itemDetails[
                                                                            index]
                                                                                .active
                                                                                .toString(),
                                                                            textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                          )),
                                                                  ],
                                                                )),
                                                            decoration: order_list[
                                                            indexx]
                                                                .itemDetails[
                                                            index]
                                                                .IsSelect ==
                                                                true &&
                                                                controller
                                                                    .isSelected(
                                                                    index)
                                                                ? new BoxDecoration(
                                                                color: Colors
                                                                    .grey[500])
                                                                : new BoxDecoration(),
                                                          )));
                                                })),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ]));
          }),
    );
  }

  addlist(int i, int index) {
    // print(order_list[i].itemDetails[index].itemId);
    order_list[i].itemDetails[index].IsSelect = true;

    json_data.clear();
    json_data.add(Items(order_list[i].itemDetails[index].itemId));
    amnt_total.add(order_list[i].itemDetails[index].itemTotalAmount.toInt());
    json_data.forEach((element) {
      print("add item${element.item_id}");
    });
  }

  removedata(int i, int index, int val) {
    // reference_id="" as TextEditingController;
    // bal_amtc= "" as TextEditingController;
    reference_id.clear();
    bal_amtc.clear();
    order_list[i].itemDetails[index].IsSelect = false;

    json_data.removeWhere((item) => item.item_id == val);

    print(json_data.length);
    if (json_data.length == 0 && select_all == true) {
      setState(() {
        select_all = false;
      });
    }
  }

  /*get delivery details online*/
  Future getdeliverydata(String empid) async {

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.get(
        Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/10040'),
        headers: headers);

    var order_data = Order_List.fromJson(json.decode(response.body));

    for (int i = 0; i < order_data.orderList.length; i++) {
      for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++) {
        if (order_data.orderList[i].itemDetails[j].active == "Pending") {
          setState(() {
            order_list.add(order_data.orderList[i]);
          });
        }
        //   if (order_data.orderList[i].itemDetails[j].active == "Pending") {
        //    if(order_list.contains(orderList[i]))
        //    setState(() {
        //      order_list.add(element.orderList[i]);
        //    });

        progressDialog.dismiss();
        //  } else {
        //    progressDialog.dismiss();
        //   }
      }
    }

    if (order_list.length == 0) {
      Fluttertoast.showToast(
          msg: "Sorry No Data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => super.widget));
    }
    //
    // for (int i = 0; i < order_data.orderList.length; i++) {
    //   for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++) {
    //     //if (order_data.orderList[i].itemDetails[j].active == "Pending") {
    //     print(order_data.orderList[i].custName +
    //         "" +
    //         order_data.orderList[i].itemDetails[j].itemName +
    //         "" +
    //         order_data.orderList[i].itemDetails[j].active);
    //     //  }
    //   }
    // }
  }

  /*insert update online*/
  Future updatestatus(String status) async {
    var response = await http.post(
      Uri.parse(
          'http://164.52.200.38:90/DeliveryPanel/PostDelivery?ActionName=$status'),
      body: jsonEncode(json_data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> response_data = json.decode(response.body);
    if (response_data['message'] == "Record Updated Successfully..") {
      Fluttertoast.showToast(
          msg: "Delivery Record updated succesfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      //
      // if(status=='Cancel'){
      //     Navigator.pop(context);
      //     Navigator.pushReplacement(context,
      //         MaterialPageRoute(builder: (BuildContext context) => super.widget));
      //   }
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      });
    } else {
      Fluttertoast.showToast(
          msg: "Delivery ${response_data['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      // SchedulerBinding.instance!.addPostFrameCallback((_) {
      //   Navigator.pop(context);
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (BuildContext context) => super.widget));
      // });

    }

    setState(() {
      select_all = false;
    });
    // updatepaymentdata();
    json_data.clear();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //
    //   Navigator.pushReplacement(context,
    //       MaterialPageRoute(builder: (BuildContext context) => super.widget));
    // });
    // Navigator.pop(context);
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  /*insert payment details*/
  Future updatepaymentdata(String status) async {
    int result = 0;
    int bal = 0;
    print("${bal_amtc.text}");

    if (bal_amtc.text == "") {
      bal = 0;
      result = amount.toInt();
    } else {
      bal = int.tryParse(bal_amtc.text)!;
      if (amount.toInt() > bal) {
        result = amount.toInt() - int.tryParse(bal_amtc.text)!;
      }
    }

    json_data.forEach((element) {
      payment_details.forEach((paymentelement) {
        if (paymentelement.trim() == "PAYTM" &&
            ref_amt == true &&
            bal_amt == false) {
          print(
              "Paytm${element.item_id}$paymentelement${amount.toInt()}${reference_id.text}");
          list_data.add(PaymentJSON(element.item_id, paymentelement,
              amount.toInt(), 10044, reference_id.text));
        } else if (paymentelement == "COD") {
          list_data.add(PaymentJSON(element.item_id, paymentelement, result,
              10044, reference_id.text));
          print("CODD${element.item_id}$paymentelement$result");
        } else {
          list_data.add(PaymentJSON(
              element.item_id, paymentelement, bal, 10044, reference_id.text));
          print("CODDCODD${element.item_id}$paymentelement$bal");
        }
      });
    });

    //json_payment.add(PaymentDatas("COD",1234,itemid));
    //json_payment.add(36199);
    var response = await http.post(
      Uri.parse('http://164.52.200.38:90/DeliveryPanel/Payment'),
      body: jsonEncode(list_data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> response_data = json.decode(response.body);
    if (response_data['message'] == "Record Save Successfully..") {
      Fluttertoast.showToast(
          msg: "Payment Record Save Successfully..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      updatestatus(status);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      });
    } else {
      Fluttertoast.showToast(
          msg: "Payment ${response_data['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      });
    }
  }

  /* show custom payment dilaog*/
  Future<void> _displayTextInputDialog(
      BuildContext context, String status) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Payment Details'),
              content: SingleChildScrollView(
                child: Container(
                  height: 600,
                  child: Column(
                    children: [
                      TextField(
                        enabled: false,
                        onChanged: (value) {
                          // setState(() {
                          //   valueText = value;
                          // });
                        },
                        //   controller: _textFieldController,
                        decoration: InputDecoration(
                            labelText: name,
                            labelStyle: TextStyle(
                              color: Colors.black,
                            )),
                      ),
                      TextField(
                        enabled: false,
                        onChanged: (value) {
                          // setState(() {
                          //   valueText = value;
                          // });
                        },
                        decoration: InputDecoration(
                            labelText: mobile,
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                      TextField(
                        enabled: false,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                            labelText: amount.toString(),
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                      Container(
                        child: Column(
                          children: values.keys.map((String key) {
                            return new CheckboxListTile(
                              title: new Text(key),
                              autofocus: true,
                              activeColor: Colors.pink,
                              checkColor: Colors.white,
                              selected: values[key]!,
                              value: values[key]!,
                              onChanged: (bool? value) {
                                setState(() {
                                  values[key] = value!;
                                  values.forEach((key, value) {
                                    if (values['PAYTM'] == true &&
                                        values['COD'] == true) {
                                      bal_amt = true;
                                      ref_amt = true;
                                    } else if (values['PAYTM'] == true) {
                                      ref_amt = true;
                                      bal_amt = false;
                                    } else if (values['COD'] == true) {
                                      bal_amt = false;
                                      ref_amt = false;
                                    } else if (values['PAYTM'] == false &&
                                        values['COD'] == false) {
                                      bal_amt = false;
                                      ref_amt = false;
                                    }
                                  });

                                  payment_details.add(key);
                                });
                              },
                            );
                          }).toList(),
                          // nList.map((data) => RadioListTile(
                          //   title: Text("${data.number}"),
                          //   groupValue: id,
                          //   value: data.index,
                          //   onChanged: (val) {
                          //     setState(() {
                          //       payment_details = data.number ;
                          //       id = data.index;
                          //     });
                          //   },
                          // )).toList(),
                        ),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Visibility(
                                visible: ref_amt,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter reference id';
                                    }
                                  },
                                  controller: reference_id,
                                  decoration:
                                  InputDecoration(hintText: "Reference Id"),
                                ),
                              ),
                              Visibility(
                                visible: bal_amt,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter paytm amount';
                                    }
                                  },
                                  controller: bal_amtc,
                                  decoration:
                                  InputDecoration(hintText: "Paytm Amount"),
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text('Submit'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        progressDialog.show();
                        setState(() {
                          checkinternetconnection(status);

                          //\  insertpayment(name,mobile,amount,reference_id.text,payment_details);
                        });
                      }
                    }),
              ],
            );
          });
        });
  }

  /* insert delivery details offline*/
  void _insert(item_id, action) async {
    // progressDialog.show();
    // json_data.forEach((element) {
    //   print(element.item_id);
    // });

    Map<String, dynamic> row = {
      DatabaseHelper.columnItem: item_id,
      DatabaseHelper.columnAction: action
    };
    Payment payment = Payment.fromMap(row);
    final id = await paymenthepler.insert(payment);
    Fluttertoast.showToast(
        msg: "Record saved Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
    progressDialog.dismiss();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  /* insert payment details offline*/
  void insertpayment(itemid, mode, amount, reference_id, delivery_boy, status) async {
    Map<String, dynamic> row = {
      PaymentDatabaseHelper.itemId: itemid.toString(),
      PaymentDatabaseHelper.PayMode: mode,
      PaymentDatabaseHelper.PayAmount: amount.toString(),
      PaymentDatabaseHelper.ReferenceNumber: reference_id,
      PaymentDatabaseHelper.deliveryBoyID: delivery_boy,
    };
    Paymentdetails payment = Paymentdetails.fromMap(row);
    final id = await paymenthepler.insert_payment(payment);
    Fluttertoast.showToast(
        msg: "Record saved Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    _insert(itemid, status);
  }

/*get delivery details*/
  void _queryAll() async {
    // json_data.forEach((element) {
    //   print(element);
    // });
    final rowcount = await paymenthepler.queryRowCountDelivery();

    if (rowcount > 0) {
      final allRows = await paymenthepler.queryAllRows();
      delivery_data.clear();
      allRows.forEach((row) => delivery_data.add(Payment.fromMap(row)));
      delivery_data.forEach((element) {
        json_data.add(Items(element.item_id));
        print("delivery data $rowcount");
      });
    } else {
      print("no delivery data");
    }
    // updatestatus(status);
  }

/*get payemnt details*/
  void _queryPaymentAll() async {
    final rowcount = await paymenthepler.queryRowCountPayment();
    if (rowcount > 0) {
      final allRows = await paymenthepler.queryAllRowspayment();
      payment_data.clear();
      allRows.forEach((row) => payment_data.add(Paymentdetails.fromMap(row)));
      print(payment_data.length);

      payment_data.forEach((element) {
        print(element.PayAmount);


        if (element.PayMode == "PAYTM") {
          print("Paytm${element.itemId}${element.PayMode}${element.PayAmount}${element.ReferenceNumber}");
          list_data.add(PaymentJSON(int.parse(element.itemId), element.PayMode.toString() ,
              int.parse(element.PayAmount), int.parse(element.deliveryBoyID), element.ReferenceNumber));
        } else if (element.PayMode == "COD") {
          list_data.add(PaymentJSON(int.parse(element.itemId),element.PayMode.toString() ,
              int.parse(element.PayAmount), int.parse(element.deliveryBoyID), element.ReferenceNumber));
          print("Paytm${element.itemId}${element.PayMode}${element.PayAmount}${ element.ReferenceNumber}");
        }
        // else {
        //   list_data.add(PaymentJSON(int.parse(element.itemId), paymentelement,
        //       int.parse(element.PayAmount), 10044, element.ReferenceNumber));
        //   // print("CODDCODD${element.item_id}$paymentelement$bal");
        // }

      });

      var response = await http.post(
        Uri.parse('http://164.52.200.38:90/DeliveryPanel/Payment'),
        body: jsonEncode(list_data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> response_data = json.decode(response.body);
      if (response_data['message'] == "Record Save Successfully..") {
        Fluttertoast.showToast(
            msg: "Payment Record Save Successfully..",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Payment ${response_data['message']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        _queryAll();
        // WidgetsBinding.instance!.addPostFrameCallback((_) {
        //   Navigator.pop(context);
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //           builder: (BuildContext context) => super.widget));
        // });
      }
    } else {
      Fluttertoast.showToast(
          msg: "No Payemnt Data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _onCategorySelected(bool selected, category_id) {
    if (selected == true) {
      setState(() {
        _selecteCategorysID.add(category_id);
      });
    } else {
      setState(() {
        _selecteCategorysID.remove(category_id);
      });
    }
  }
}
