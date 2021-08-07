import 'dart:convert';
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
  bool select_all =false;
  String empid = "",name="",mobile="";
  double amount=0.0;
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
  String payment_details="";
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
    checkinternetconnection();
    getuserdata();
  }

  getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //   empid = prefs.getString('empid')!;
      // print("empid$empid");
    });
    progressDialog.show();
    getdeliverydata(empid);

  }
  checkinternetconnection() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {

    } else if (connectivityResult == ConnectivityResult.wifi) {

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
            visible: select_all==true?select_all = true: select_all =false,
            child: Row(
              children: [
                IconButton(
                  icon: new Icon(Icons.save),
                  onPressed: () =>  updatestatus("Delivered")
                ),

                IconButton(
                  icon: new Icon(Icons.close),
                  onPressed: () => updatestatus("Cancel"),
                ),
              ],
            )
          )
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
              Column(
                children: [
                  for (int i = 0; i < orderlist.length; i++)
                    Container(
                        child: Column(children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ExpandableNotifier(
                            child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Card(
                            color:Color(0xFFCFD8DC),
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
                                              topLeft: Radius.circular(10.0),
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
                                            child: Column(
                                                children: [

                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(
                                                      orderlist[i].custName,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(orderlist[i]
                                                        .custMobile),
                                                  )),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(
                                                        orderlist[i].address),
                                                  )),
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
                                      CrossAxisAlignment.start,
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
                                          child: Column(
                                            children: [
                                              for (int j = 0;j < orderlist[i].itemDetails.length;j++)
                                                //for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
                                            Container(
                                            color: controller.isSelected(i)
                                            ? Colors.grey[600]
                                            : Color(0xFFCFD8DC),
                                               child: MultiSelectItem(
                                                  isSelecting:
                                                  controller.isSelecting,
                                                  onSelected: () {
                                                    setState(() {
                                                      controller.toggle(i);
                                                   //   print(orderlist[i].itemDetails[j].itemId);
                                                      select_all = true;
                                                      name =  orderlist[i].custName;
                                                      mobile = orderlist[i].custMobile;
                                                      amount = orderlist[i].itemDetails[j].itemTotalAmount;
                                                      json_data.add(Items(orderlist[i].itemDetails[j].itemId));
                                                    }
                                                   );
                                                  },

                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                         //  progressDialog.dismiss(),
                                                          Expanded(child: Text(orderlist[i].itemDetails[j].id.toString())),
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                          Expanded(child: Text(orderlist[i].itemDetails[j].itemName)),
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                          Expanded(child: Text(orderlist[i].itemDetails[j].itemRate.toString())),
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                          Expanded(child: Text(orderlist[i].itemDetails[j].itemQty.toString())),
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                          Expanded(child: Text(orderlist[i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .itemTotalAmount
                                                                  .toString())),
                                                          if (orderlist[i].itemDetails[j].active =="Pending")
                                                          Expanded(
                                                              child: Text(orderlist[
                                                                      i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .active
                                                                  .toString())),

                                                        ],
                                                      )
                                                  ),
                                                ),
                                            )
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                         )
                        ),
                      ),
                    ]
                   )
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

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

     for (int j = 0; j < order_data.orderList[i].itemDetails.length; j++){

        if (order_data.orderList[i].itemDetails[j].active == "Pending") {

          setState(() {
            orderlist.add(order_data.orderList[i]);
           }

          );

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

  Future updatestatus(String status) async {
     // json_data.forEach((element) {
     //   _insert(element.item_id,status);
     // }) ;


   _displayTextInputDialog(context);
 //    json_data.forEach((element) {
 //        print(element.item_id);
 //    });
    // print(json_data);

    //
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

    // Map<String, dynamic> response_data= json.decode(response.body);
    //
    // if(response_data['message']=="Record Updated Successfully.."){
    //
    //   Fluttertoast.showToast(
    //       msg: "Record updated successfully",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //
    // }else{
    //
    //   Fluttertoast.showToast(
    //       msg: "Error",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.black,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //
    // }
  }

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
                    decoration: InputDecoration(labelText: name,labelStyle: TextStyle(
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

                    decoration: InputDecoration(labelText: mobile,labelStyle: TextStyle(
                      color: Colors.black)),
                  ),
                  TextField(
                    enabled: false,
                    onChanged: (value) {
                      // setState(() {
                      //   valueText = value;
                      // });
                    },
                      controller: reference_id,
                       decoration: InputDecoration(labelText: amount.toString(),labelStyle: TextStyle(
                        color: Colors.black)),
                  ),
                  TextField(
                    onChanged: (value) {
                      // setState(() {
                      //   valueText = value;
                      // });
                    },
                    controller: reference_id,
                    decoration: InputDecoration(hintText:"Reference Id"),
                  ),
                  Container(
                    child: Column(
                      children:values.keys.map((String key) {
                        return new CheckboxListTile(
                          title: new Text(key),
                          activeColor: Colors.pink,
                          checkColor: Colors.white,
                          value: values[key],
                          onChanged: (bool? value) {
                            setState(() {
                              values[key] = value!;
                              payment_details = key;
                            });
                            print(key);
                          },
                        );
                      }).toList(),
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
                    insertpayment(name,mobile,amount,reference_id.text,payment_details);
                   }
                  );
                },
              ),

            ],
          );
        });
  }
  // void _insert(item_id, action) async {
  //   // row to insert
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnItem: item_id,
  //     DatabaseHelper.columnAction: action
  //   };
  //   Payment payment = Payment.fromMap(row);
  //   final id = await dbHelper.insert(payment);
  //   print('inserted row id: $id');
  //   // _showMessageInScaffold('inserted row id: $id');
  //
  // }

  void insertpayment(name,mobile,amount,reference_id,payment_details) async {
   // print("$name$mobile$amount$reference_id$payment_details");
    // row to insert
    Map<String, dynamic> row = {
      PaymentDatabaseHelper.columnname : name,
      PaymentDatabaseHelper.columnmobile : mobile,
      PaymentDatabaseHelper.columnamount : amount,
      PaymentDatabaseHelper.columnreferenceId : reference_id,
      PaymentDatabaseHelper.columnpayment_details : payment_details,
    };
    Paymentdetails payment = Paymentdetails.fromMap(row);
    final id = await paymenthepler.insert(payment);
    print('inserted row id: $id');

  }

}
