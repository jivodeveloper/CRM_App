import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:crm_flutter/Helper/DatabaseHelper.dart';
import 'package:crm_flutter/Helper/PaymentDatabaseHelper.dart';
import 'package:crm_flutter/Model/Items.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
import 'package:crm_flutter/Model/Payment.dart';
import 'package:crm_flutter/Model/Paymentdetails.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crm_flutter/ui/PaymentDetails.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeliveryData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DeliveryDataState();
  }
}

class DeliveryDataState extends State<DeliveryData> {

  List<OrderList> orderlist = [];
  late ArsProgressDialog progressDialog;
  bool select_all = false;
  String empid = "", name = "", mobile = "";
  double amount = 0.0;
  String payment_details = "";
  Map<String, bool> values = {
    'COD': false,
    'PAYTM': false,
    'Online Payment': false,
  };

  MultiSelectController controller = new MultiSelectController();
  TextEditingController reference_id = new TextEditingController();
  bool valuefirst = false;
  bool valuesecond = false;
  List<Items> json_data = [];
  List<Paymentdetails> payment_data = [];
  List<Payment> delivery_data = [];

  late ExpandableController categoryController;
  final paymenthepler = PaymentDatabaseHelper.instance;
  // final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    categoryController = ExpandableController(initialExpanded: false);
    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));
    json_data.forEach((element) {
      print(element);
    });
    getuserdata();
    _queryAll();
    _queryPaymentAll();
  }

  /* to receive empid*/
  getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //   empid = prefs.getString('empid')!;
      // print("empid$empid");
    });
    progressDialog.show();
    getdeliverydata(empid);
  }

  /*check interet for delivery data*/
  checkinternetconnection(String status) async {

    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        progressDialog.show();
        updatestatus(status);

        _displayTextInputDialog(context);
      }
    } on SocketException catch (_) {
      // progressDialog.show();
      json_data.forEach((element) {
        _insert(element.item_id,status);
      }
      );
      _displayTextInputDialog(context);
    }
  }

  /*check internet for payment data*/
  checkinternetpayment(String name, String mobile, double amount,
      String reference, String payment_details) async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        insertpayment(name, mobile, amount, reference_id.text, payment_details);
      }
    } on SocketException catch (_) {
      insertpayment(name,mobile,amount,reference_id.text,payment_details);

    }
  }

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
                      onPressed: () => checkinternetconnection("Delivered")),
                  IconButton(
                    icon: new Icon(Icons.close),
                    onPressed: () => checkinternetconnection("Cancel"),
                  ),
                ],
              ))
        ],
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            for (int i = 0; i < orderlist.length; i++)

              Container(
                  child: Column(
                      children: [
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
                                                    bottomRight:
                                                    Radius.circular(10.0))),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 10,
                                                    right: 10,
                                                    bottom: 10),
                                                child: Container(
                                                  child: Column(children: [
                                                    Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Padding(
                                                          padding: EdgeInsets.all(5),
                                                          child: Text(
                                                            orderlist[i].custName,
                                                            style: GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  fontWeight:
                                                                  FontWeight.bold),
                                                            ),
                                                          ),
                                                        )),
                                                    Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Padding(
                                                            padding: EdgeInsets.all(5),
                                                            child: Text(orderlist[i]
                                                                .custMobile,
                                                                style: GoogleFonts.lato(
                                                                  textStyle:  TextStyle(),

                                                                )))
                                                    ),
                                                    Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Padding(
                                                            padding: EdgeInsets.all(5),
                                                            child: Text(
                                                                orderlist[i].address,
                                                                style: GoogleFonts.lato(
                                                                  textStyle:  TextStyle(
                                                                  ),

                                                                )
                                                            ))),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                          collapsed: Container(
                                            child: Column(children: [
                                            ]),
                                          ),
                                          expanded: Column(
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
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                          "Items",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                          "Rate",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                          "Quantity",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                          "Total",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    Expanded(
                                                        child: Text(
                                                          "Status",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight:
                                                              FontWeight.bold),
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
                                                      itemCount: orderlist[i].itemDetails.length,
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                            onTap: (){},
                                                            child: MultiSelectItem(
                                                                isSelecting:
                                                                controller.isSelecting,
                                                                onSelected: () {
                                                                  setState(() {
                                                                    controller.toggle(index);
                                                                    //   print(orderlist[i].itemDetails[j].itemId);
                                                                    select_all = true;
                                                                    // controller.isSelected(index)?
                                                                    //     select_all = true:select_all = false;
                                                                    controller.isSelected(index)?
                                                                    null:removedata(i,index);
                                                                    name = orderlist[i]
                                                                        .custName;
                                                                    mobile = orderlist[i]
                                                                        .custMobile;
                                                                    amount = orderlist[i]
                                                                        .itemDetails[index]
                                                                        .itemTotalAmount;
                                                                    json_data.add(Items(
                                                                        orderlist[i]
                                                                            .itemDetails[index]
                                                                            .itemId));
                                                                  });
                                                                },
                                                                child: Container(
                                                                  child: Padding(
                                                                      padding:
                                                                      EdgeInsets.only(
                                                                          bottom: 10),
                                                                      child: Row(
                                                                        children: [
                                                                          if (orderlist[i]
                                                                              .itemDetails[
                                                                          index]
                                                                              .active ==
                                                                              "Pending")
                                                                          //  progressDialog.dismiss(),
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[index]
                                                                                    .id
                                                                                    .toString())),
                                                                          if (orderlist[i]
                                                                              .itemDetails[
                                                                          index]
                                                                              .active ==
                                                                              "Pending")
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[
                                                                                index]
                                                                                    .itemName)),
                                                                          if (orderlist[i]
                                                                              .itemDetails[
                                                                          index]
                                                                              .active ==
                                                                              "Pending")
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[
                                                                                index]
                                                                                    .itemRate
                                                                                    .toString())),
                                                                          if (orderlist[i]
                                                                              .itemDetails[
                                                                          index]
                                                                              .active ==
                                                                              "Pending")
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[
                                                                                index]
                                                                                    .itemQty
                                                                                    .toString())),
                                                                          if (orderlist[i]
                                                                              .itemDetails[
                                                                          index]
                                                                              .active ==
                                                                              "Pending")
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[
                                                                                index]
                                                                                    .itemTotalAmount
                                                                                    .toString())),
                                                                          if (orderlist[i]
                                                                              .itemDetails[index]
                                                                              .active ==
                                                                              "Pending")
                                                                            Expanded(
                                                                                child: Text(orderlist[
                                                                                i]
                                                                                    .itemDetails[
                                                                                index]
                                                                                    .active
                                                                                    .toString())),
                                                                        ],
                                                                      )),
                                                                  decoration: controller.isSelected(index)
                                                                      ? new BoxDecoration(color: Colors.grey[500])
                                                                      : new BoxDecoration(),
                                                                )
                                                            )

                                                        );
                                                      }
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ]
                  )
              )
          ],

        ),
      ),
    );
  }

  removedata(int i,int index){
    _queryAll();
    // json_data.removeAt(index-1);
    //   print("$select_all");
    //   if(json_data.length==0 && select_all==true){
    //
    //     setState(() {
    //       select_all = false;
    //     });
    //   }

  }
  /*get delivery details online*/
  Future getdeliverydata(String empid) async {
    // progressDialog.show();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.get(
        Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/10045'),
        headers: headers);

    Order_List order_data = Order_List.fromJson(json.decode(response.body));

    for (int i = 0; i < order_data.orderList.length; i++) {
      for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++) {
        if (order_data.orderList[i].itemDetails[j].active == "Pending") {
          setState(() {
            orderlist.add(order_data.orderList[i]);
          });

          // for (int i = 0; i < order_data.orderList.length; i++) {
          //   for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++) {
          //     if (order_data.orderList[i].itemDetails[j].active == "Pending") {
          //       print(order_data.orderList[i].custName + "" + order_data.orderList[i].itemDetails[j].itemName + "" + order_data.orderList[i].itemDetails[j].active);
          //     }
          //   }
          // }

          // Fluttertoast.showToast(
          //     msg: "${order_data.orderList[i].itemDetails[j].itemId}",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.black,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          progressDialog.dismiss();
        } else {
          progressDialog.dismiss();
          // Fluttertoast.showToast(
          //     msg: "Sorry No Data",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.black,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
        }
      }
    }

    // for (int i = 0; i < order_data.orderList.length; i++) {
    //  for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++){
    //     if (order_data.orderList[i].itemDetails[j].active == "Pending") {
    //       print(orderlist[i].itemDetails[j].itemName);
    //       setState(() {
    //         orderlist.add(order_data.orderList[i]);
    //         }
    //       );
    //       //
    //       // for (int i = 0; i < orderlist.length; i++) {
    //       //   print(orderlist[i].itemDetails[0].itemName);
    //       // }
    //
    //       // Fluttertoast.showToast(
    //       //     msg: "${order_data.orderList[i].itemDetails[j].itemId}",
    //       //     toastLength: Toast.LENGTH_SHORT,
    //       //     gravity: ToastGravity.BOTTOM,
    //       //     timeInSecForIosWeb: 1,
    //       //     backgroundColor: Colors.black,
    //       //     textColor: Colors.white,
    //       //     fontSize: 16.0);
    //     } else {
    //       // Fluttertoast.showToast(
    //       //     msg: "Sorry No Data",
    //       //     toastLength: Toast.LENGTH_SHORT,
    //       //     gravity: ToastGravity.BOTTOM,
    //       //     timeInSecForIosWeb: 1,
    //       //     backgroundColor: Colors.black,
    //       //     textColor: Colors.white,
    //       //     fontSize: 16.0);
    //     }
    //
    //  }
    // }
  }

  /*status update online*/
  Future updatestatus(String status) async {

    json_data.forEach((element) {
      print(element.item_id);
    });
    print("online");


    // var response = await http.post(
    //   Uri.parse(
    //       'http://164.52.200.38:90/DeliveryPanel/PostDelivery?ActionName=$status'),
    //   body: jsonEncode(json_data),
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    // );
    //
    // Map<String, dynamic> response_data = json.decode(response.body);
    //
    // if (response_data['message'] == "Record Updated Successfully..") {
    //   Fluttertoast.showToast(
    //       msg: "Record updated succesfully",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   if(status=="Delivered"){
    //
    //    // Navigator.push(context,MaterialPageRoute(builder: (context) => PaymentDetails()));
    //   }
    //
    //   setState(() {
    //     select_all =false;
    //   });
    // } else {
    //   Fluttertoast.showToast(
    //       msg: "Record not Updated Something wrong please Try Again..",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // }

    progressDialog.dismiss();
  }

  /* show custom payment dilaog*/
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Payment Details'),
            content: Container(
              height: 400,
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
                    onChanged: (value) {
                      // setState(() {
                      //   valueText = value;
                      // });
                    },
                    controller: reference_id,
                    decoration: InputDecoration(
                        labelText: amount.toString(),
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                  TextField(
                    onChanged: (value) {
                      // setState(() {
                      //   valueText = value;
                      // });
                    },
                    controller: reference_id,
                    decoration: InputDecoration(hintText: "Reference Id"),
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
                          value: values[key],
                          onChanged: (bool? value) {
                            setState(() {
                              values[key] = value!;
                              payment_details = key;
                            });
                            print(key);
                          },
                        );
                      }
                      ).toList(),
                    ),
                  )
                ],
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
                  setState(() {
                    checkinternetpayment(name, mobile, amount,
                        reference_id.text, payment_details);
                    //\  insertpayment(name,mobile,amount,reference_id.text,payment_details);
                  });
                },
              ),
            ],
          );
        });
  }

  /* insert delivery details offline*/
  void _insert(item_id, action) async {

    json_data.forEach((element) {
      print(element.item_id);
    });

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

    // _showMessageInScaffold('inserted row id: $id');
  }

  /* insert payment details offline*/
  void insertpayment(name, mobile, amount, reference_id, payment_details) async {
    json_data.forEach((element) {
      print(element.item_id);
    });
    //   Map<String, dynamic> row = {
    //   PaymentDatabaseHelper.columnname: name,
    //   PaymentDatabaseHelper.columnmobile: mobile,
    //   PaymentDatabaseHelper.columnamount: amount,
    //   PaymentDatabaseHelper.columnreferenceId: reference_id,
    //   PaymentDatabaseHelper.columnpayment_details: payment_details,
    // };
    // Paymentdetails payment = Paymentdetails.fromMap(row);
    // final id = await paymenthepler.insert_payment(payment);
  }

  /*get delivery details*/
  void _queryAll() async {

    final rowcount = await paymenthepler.queryRowCountDelivery();
    print("$rowcount");
    if(rowcount>0){
      final allRows = await paymenthepler.queryAllRows();
      delivery_data.clear();
      allRows.forEach((row) => delivery_data.add(Payment.fromMap(row)));
      delivery_data.forEach((element) {
        json_data.add(Items(element.item_id));
      });
      print("delivery data$rowcount");
      setState(() {});
    }else{
      print("no delivery data");
    }
  }

  /*get payemnt details*/
  void _queryPaymentAll() async {
    final rowcount = await paymenthepler.queryRowCountPayment();

    if(rowcount>0){
      final allRows = await paymenthepler.queryAllRowspayment();
      payment_data.clear();
      allRows.forEach((row) => payment_data.add(Paymentdetails.fromMap(row)));

      payment_data.forEach((element) {
        setState(() {
          name = element.name;
          mobile = element.mobile;
          amount = element.amount;
          payment_details = element.payment_details;
          reference_id = element.reference_id as TextEditingController;
        });
      });
    }else{
      print("No Payment Data");
    }

  }
}
