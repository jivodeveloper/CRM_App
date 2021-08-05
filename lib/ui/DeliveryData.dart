import 'dart:convert';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:crm_flutter/Model/Items.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
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
  String empid = "";
  MultiSelectController controller = new MultiSelectController();
  List<Items> json_data = [];

  @override
  void initState() {
    super.initState();

    progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    getuserdata();
  }

  getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //   empid = prefs.getString('empid')!;
      // print("empid$empid");
    });
    getdeliverydata(empid);
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
                InkWell(
                  onTap: (){
                      updatestatus("Delivered");
                  },
                  child:Text("Save"),
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
                            // color: controller.isSelected(i)
                            //     ? Colors.grey[300]
                            //     : Color(0xFFCFD8DC),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: <Widget>[
                                ScrollOnExpand(
                                  scrollOnExpand: true,
                                  scrollOnCollapse: false,
                                  child: ExpandablePanel(
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
                                            child: Column(children: [
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
                                      child: Column(children: []),
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
                                                      print(orderlist[i]
                                                          .itemDetails[j]
                                                          .itemId);
                                                      select_all = true;

                                                      json_data.add(Items(orderlist[i].itemDetails[j].itemId));
                                                    }
                                                   );
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          if (orderlist[i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .active ==
                                                              "Pending")
                                                          Expanded(
                                                                child: Text(orderlist[
                                                                        i]
                                                                    .itemDetails[
                                                                        j]
                                                                    .id
                                                                    .toString())),
                                                          Expanded(
                                                              child: Text(orderlist[
                                                                      i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .itemName)),
                                                          Expanded(
                                                              child: Text(orderlist[
                                                                      i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .itemRate
                                                                  .toString())),
                                                          Expanded(
                                                              child: Text(orderlist[
                                                                      i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .itemQty
                                                                  .toString())),
                                                          Expanded(
                                                              child: Text(orderlist[
                                                                      i]
                                                                  .itemDetails[
                                                                      j]
                                                                  .itemTotalAmount
                                                                  .toString())),
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
        Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/10042'),
        headers: headers);

    Order_List order_data = Order_List.fromJson(json.decode(response.body));

    for (int i = 0; i < order_data.orderList.length; i++) {
      if (order_data.orderList[i].itemDetails[0].active == "Pending") {
        setState(() {
          orderlist.add(order_data.orderList[i]);
        });
      } else {
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

  Future updatestatus(String status) async {
    // progressDialog.show();
    // Map<String, String> headers = {
    //   'Content-Type': 'application/json',
    // };

    // Map<String, dynamic> response_data;

    // final body = [
    //   {
    //     "item_id":23860
    //   },
    // ];


    // json_data.add(Items(243343));

    var response = await http.post(
      Uri.parse(
          'http://164.52.200.38:90/DeliveryPanel/PostDelivery?ActionName=$status'),
      body: json.encode(json_data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> response_data = json.decode(response.body);
    // Fluttertoast.showToast(msg: "${response_data['message']}",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    if (response_data['message'] == "Record Updated Successfully..") {
      Fluttertoast.showToast(
          msg: "Record updated succesfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Record not Updated Something wrong please Try Again..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }

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
}
