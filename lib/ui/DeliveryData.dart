import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crm_flutter/Helper/DatabaseHelper.dart';
import 'package:crm_flutter/Model/ItemDetails.dart';
import 'package:crm_flutter/Model/PaymentJSON.dart';
import 'package:crm_flutter/ui/Dashboard.dart';
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

class DeliveryData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DeliveryDataState();
  }
}

class DeliveryDataState extends State<DeliveryData> {

  List<OrderList> order_list = [];
  List<ItemDetails> item_list = [];
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    getuserdata(context);
    _queryAll();
    _queryPaymentAll();
  }

  //
  // @override
  // void dispose() {
  //  // _connectivitySubscription.cancel();
  //   super.dispose();
  // }

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
  getuserdata(BuildContext context) async {
    progressDialog.dismiss();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empid = prefs.getString('empid')!;
      // empid = "10040";
      // print("empid$empid");
    });

    progressDialog.show();
    getdeliverydata(empid,context);
  }

  /*check interet for delivery data*/
  checkinternetconnection(String status,BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (status == 'Cancel') {
          updatestatus(status);
        } else {
          updatepaymentdata(status);
        }

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
          if (paymentelement.trim() == "PAYTM") {
            print(
                "Paytm${element.item_id}$paymentelement${amount.toInt()}${reference_id.text}");


            insertpayment(element.item_id, paymentelement, bal_amtc.text, reference_id.text,
                int.parse(empid), status);
          } else if (paymentelement == "COD") {
            print("CODD${element.item_id}$paymentelement$result");
            insertpayment(element.item_id, paymentelement, result,
                 reference_id.text,empid, status);
          }
          else {
            print("CODDCODD${element.item_id}$paymentelement$bal");
            insertpayment(element.item_id, paymentelement, bal,
                empid, reference_id.text, status);
          }
        });
      });

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

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    var isSelected = false;
    return Scaffold(
        key: _scaffoldKey,
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
                        onPressed: () => checkinternetconnection('Cancel',context)),
                  ],
                ))
          ],
        ),
        body: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(children: [
                ListView.builder(
                  key: Key('builder ${selected.toString()}'),
                  padding:EdgeInsets.only(left: 5.0,top:5.0, right: 5.0, bottom: 5.0),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: order_list.length,
                  itemBuilder: (context, indexx) {
                    return Card(
                        color: Color(0xFFCFD8DC),
                        clipBehavior: Clip.antiAlias,
                        child: Column(children: <Widget>[
                          ExpansionTile(
                              key: Key(indexx.toString()), //attention
                              initiallyExpanded: indexx == selected, //attention
                              title:  Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                     padding: EdgeInsets.all(2),
                                      child:  Text(
                                          order_list[indexx].custName,
                                          style: GoogleFonts.lato(
                                            textStyle:
                                            TextStyle(fontWeight: FontWeight.normal,color: Color(0xff18325e)),
                                          )
                                      ),
                                      )

                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child:Padding(
                                      padding: EdgeInsets.all(2),
                                    child:Text(
                                        order_list[indexx].custMobile,
                                        style: GoogleFonts.lato(
                                          textStyle:
                                          TextStyle(fontWeight: FontWeight.normal),
                                        )
                                    )),
                                  )

                                ],
                                   ),
                              subtitle: Padding(
                              padding: EdgeInsets.all(2),
                              child:Text(order_list[indexx].address,
                                  style: GoogleFonts.lato(
                                    textStyle:
                                        TextStyle(color: Colors.black),
                                  ))),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          child: ListView.builder(itemCount: order_list[indexx].itemDetails.length,
                                              //itemCount:item_list.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                    onLongPress: () {

                                                    },
                                                    child: MultiSelectItem(
                                                        isSelecting: controller
                                                            .isSelecting,
                                                        onSelected: () {
                                                          setState(() {
                                                            //  expansionTile.currentState!.collapse();
                                                            order_list[indexx]
                                                                .itemDetails[
                                                                    index]
                                                                .IsSelect = true;
                                                            controller
                                                                .toggle(index);
                                                           select_all = true;
                                                            controller.isSelected(index)
                                                                ? addlist(indexx,index): removedata(indexx,index,order_list[indexx].itemDetails[index].itemId);
                                                            name = order_list[
                                                                    indexx]
                                                                .custName;
                                                            mobile = order_list[
                                                                    indexx]
                                                                .custMobile;

                                                            amount =
                                                                amnt_total
                                                                    .fold(
                                                                    0, (p,
                                                                    c) =>
                                                                p + c);
                                                            json_payment.add(
                                                                order_list[
                                                                        indexx]
                                                                    .itemDetails[
                                                                        index]
                                                                    .itemId);
                                                          });
                                                        },
                                                        child: Container(
                                                          child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          10),
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
                                                                        child:
                                                                            Text(
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
                                                                        child:
                                                                            Text(
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
                                                                        child:
                                                                            Text(
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
                                                                        child:
                                                                            Text(
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
                                                                        child:
                                                                            Text(
                                                                      order_list[
                                                                              indexx]
                                                                          .itemDetails[
                                                                              index]
                                                                          .itemTotalAmount
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      )
                                                                    ),
                                                                  if (order_list[
                                                                              indexx]
                                                                          .itemDetails[
                                                                              index]
                                                                          .active ==
                                                                      "Pending")
                                                                    Expanded(
                                                                        child:
                                                                            Text(
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
                                                                          .grey[
                                                                      500])
                                                              : new BoxDecoration()
                                                        ))
                                                );
                                              }
                                          )
                                      ),
                                    ],
                                  ),
                                )
                              ],
                              onExpansionChanged: ((newState) {
                                if (newState)
                                  setState(() {
                                    Duration(seconds: 20000);
                                    selected = indexx;
                                    // controller.toggle(indexx);
                                  }
                                 );
                                else
                                  setState(() {
                                    // order_list[indexx].itemDetails[0].IsSelect = false;
                                    controller.toggle(indexx);
                                    select_all =false;
                                    selected = -1;
                                  });
                              })),
                        ]
                      )
                    );
                  },
                )
              ]),
            )));
  }

  showlist() {
    setState(() {
      select_all = false;
      }
    );
    return new BoxDecoration();
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
    int selected = 0;
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(children: [
            ListView.builder(
              key: Key('builder ${selected.toString()}'), //attention
              padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: order_list.length,
              itemBuilder: (context, indexx) {
                return Column(children: <Widget>[
                  Divider(
                    height: 17.0,
                    color: Colors.white,
                  ),
                  ExpansionTile(
                      key: Key(indexx.toString()), //attention
                      initiallyExpanded: indexx == selected, //attention
                      title: Text('Faruk AYDIN ${indexx}',
                          style: TextStyle(
                              color: Color(0xFF09216B),
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Software Engineer',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold),
                      ),
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Text(
                              'DETAİL ${indexx} \n' +
                                  'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using "Content here, content here", making it look like readable English.',
                            ))
                      ],

                      onExpansionChanged: ((newState) {
                        if (newState)
                          setState(() {
                            Duration(seconds: 20000);
                            selected = indexx;
                          });
                        else
                          setState(() {
                            select_all=false;
                            selected = -1;
                          });
                      })),
                ]);
              },
            )
          ]),
        ));
  }

  addlist(int i, int index) {

    // json_data.clear();
    json_data.add(Items(order_list[i].itemDetails[index].itemId));
    amnt_total.add(order_list[i].itemDetails[index].itemTotalAmount.toInt());
    json_data.forEach((element) {
      print("add item${element.item_id}");
    });
  }

  removedata(int i, int index, int val) {
    json_data.forEach((element) {
      print(element);
    });

    reference_id.clear();
    bal_amtc.clear();
    order_list[i].itemDetails[index].IsSelect = false;

    json_data.removeAt(index);
    // print("length${json_data.length}");
    if (json_data.length == 0 && select_all == true) {
      setState(() {
        select_all = false;
      });
    }
  }

  /*get delivery details online*/
  Future getdeliverydata(String empid,context) async {

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.get(
        Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/$empid'),
        headers: headers);

    var order_data = Order_List.fromJson(json.decode(response.body));


    for (int i = 0; i < order_data.orderList.length; i++) {
      for (int j = 0;j < order_data.orderList[i].itemDetails.length;j++) {
       if (order_data.orderList[i].itemDetails[j].active == "Pending"){
          var contain = order_list.where((element) => element.custName == order_data.orderList[i].custName);
          if(contain.isEmpty){
            if(mounted){
              setState(() {
                order_list.add(OrderList(id: order_data.orderList[i].id,
                    custMobile: order_data.orderList[i].custMobile,
                    custName: order_data.orderList[i].custName,
                    zoneId: order_data.orderList[i].zoneId,
                    zoneName: order_data.orderList[i].zoneName,
                    areaId: order_data.orderList[i].areaId,
                    areaName: order_data.orderList[i].areaName,
                    stateId: order_data.orderList[i].stateId,
                    stateName: order_data.orderList[i].stateName,
                    landmark: order_data.orderList[i].landmark,
                    address: order_data.orderList[i].address,
                    pincode: order_data.orderList[i].pincode,
                    totalPrice: order_data.orderList[i].totalPrice,
                    totalQty: order_data.orderList[i].totalQty,
                    paymentMode: order_data.orderList[i].paymentMode,
                    paymentRemark: order_data.orderList[i].paymentRemark,
                    paymentNumber: order_data.orderList[i].paymentNumber,
                    remark: order_data.orderList[i].remark,
                    callerId: order_data.orderList[i].callerId,
                    deliveryAssignId: order_data.orderList[i].deliveryAssignId,
                    deliveryAssignName: order_data.orderList[i].deliveryAssignName,
                    deliveryAssignDate: order_data.orderList[i].deliveryAssignDate,
                    callerName: order_data.orderList[i].callerName,
                    source: order_data.orderList[i].source,
                    insertedDate: order_data.orderList[i].insertedDate,
                    itemCoupon: order_data.orderList[i].itemCoupon,
                    itemDetails: order_data.orderList[i].itemDetails));
              });
            }

          }else{

          }
          }

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
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) =>Dashboard()));
      progressDialog.dismiss();

    }


    for (int i = 0; i < order_list.length; i++) {
      for (int j = 0; j < order_list[i].itemDetails.length; j++) {
        // if ( order_list[i].itemDetails[j].active == "Pending") {
        print("$i $j");
        print( order_list[i].custName +
            "" +
            order_list[i].itemDetails[j].itemName +
            "" +
            order_list[i].itemDetails[j].active);
         }
      // }
    }
    progressDialog.dismiss();

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
      progressDialog.dismiss();
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

      progressDialog.dismiss();
    }

    setState(() {
      select_all = false;
    });

    json_data.clear();

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
        if (paymentelement.trim() == "PAYTM" && ref_amt == true && bal_amt == false) {
           print("Paytm${element.item_id}$paymentelement${amount.toInt()}${reference_id.text}");
          list_data.add(PaymentJSON(element.item_id, paymentelement,
              amount.toInt(),int.parse(empid), reference_id.text));
        } else if (paymentelement == "COD") {
          list_data.add(PaymentJSON(element.item_id, paymentelement, result,
              int.parse(empid), reference_id.text));
            print("CODD${element.item_id}$paymentelement$result");
        } else {
          list_data.add(PaymentJSON(element.item_id, paymentelement, bal,int.parse(empid), reference_id.text));
            print("CODDCODD${element.item_id}$paymentelement$bal");
        }
       }
      );
     }
    );

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
          msg: "Record Saved Successfully..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      updatestatus(status);
      progressDialog.dismiss();
      // WidgetsBinding.instance!.addPostFrameCallback((_) {
      //   Navigator.of(context).pop();
      //   Navigator.pushReplacement(context,MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
      // });
      json_data.clear();

    } else {
      Fluttertoast.showToast(
          msg: "${response_data['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      progressDialog.dismiss();
   }

  }

  /* show custom payment dilaog*/
  Future<void> _displayTextInputDialog(BuildContext context, String status) async {
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
                                      payment_details.remove('COD');
                                      ref_amt = true;
                                      bal_amt = false;
                                    } else if (values['COD'] == true) {
                                      payment_details.remove('PAYTM');
                                      bal_amt = false;
                                      ref_amt = false;
                                    } else if (values['PAYTM'] == false &&
                                        values['COD'] == false) {
                                      bal_amtc.text ="";
                                      reference_id.text = "";
                                      payment_details.remove('PAYTM');
                                      payment_details.remove('COD');
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
                                  keyboardType: TextInputType.number,
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
                      json_data.clear();
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
                          checkinternetconnection(status,context);

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
    // Fluttertoast.showToast(
    //     msg: "Record saved Successfully",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    progressDialog.dismiss();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  /* insert payment details offline*/
  void insertpayment(itemid, mode, amount, reference_id, delivery_boy, status) async {
    print("$itemid$mode$amount$reference_id$delivery_boy$status");
    Map<String, dynamic> row = {
      PaymentDatabaseHelper.itemId: itemid.toString(),
      PaymentDatabaseHelper.PayMode: mode,
      PaymentDatabaseHelper.PayAmount: amount.toString(),
      PaymentDatabaseHelper.ReferenceNumber: reference_id,
      PaymentDatabaseHelper.deliveryBoyID: delivery_boy,
    };

    Paymentdetails payment = Paymentdetails.fromMap(row);
    final id = await paymenthepler.insert_payment(payment);
    // Fluttertoast.showToast(
    //     msg: "Record saved Successfully",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 16.0);

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
          // print(
          //     "Paytm${element.itemId}${element.PayMode}${element.PayAmount}${element.ReferenceNumber}");
          list_data.add(PaymentJSON(
              int.parse(element.itemId),
              element.PayMode.toString(),
              int.parse(element.PayAmount),
              int.parse(element.deliveryBoyID),
              element.RefrenceNumber));
        } else if (element.PayMode == "COD") {
          list_data.add(PaymentJSON(
              int.parse(element.itemId),
              element.PayMode.toString(),
              int.parse(element.PayAmount),
              int.parse(element.deliveryBoyID),
              element.RefrenceNumber));
          print(
              "Paytm${element.itemId}${element.PayMode}${element.PayAmount}${element.RefrenceNumber}");
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
      // Fluttertoast.showToast(
      //     msg: "No Payment Data",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.black,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
  }

}

