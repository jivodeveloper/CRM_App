import 'dart:convert';
import 'dart:js';

import 'package:crm_flutter/ui/Dashboard.dart';
import 'package:crm_flutter/Model/User.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api{

  bool trustSelfSigned = true;
  Future fetchPost(String username,String password) async{
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.get(Uri.parse('http://164.52.200.38:90/Login?Username=$username&Password=$password'),headers: headers
    );
    User user = User.fromJson(json.decode(response.body));


    if (user.empid > 0) {

      Fluttertoast.showToast(
          msg: "Logged In Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      /*SharePreference*/

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Role','admin');
      prefs.setString('Name',username);
      prefs.setString('Menu',user.menuList.toString());

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => Dashboard(text: "admin")),
      // );

    }else {

      //    Fluttertoast.showToast(
      //        msg: "Please check your credentials",
      //        toastLength: Toast.LENGTH_SHORT,
      //        gravity: ToastGravity.BOTTOM,
      //        timeInSecForIosWeb: 1,
      //        backgroundColor: Colors.black,
      //        textColor: Colors.white,
      //        fontSize: 16.0);
      //
    }
  }
}

import 'dart:convert';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:crm_flutter/Model/Items.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
import 'package:crm_flutter/Model/Response.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      body: getlayout()
  );
}
Widget getlayout(){
  return Consumer<ConnectivityProvider>(
    builder: (context,model,child) {
      if(model.isOnline) {
        return model.isOnline ? Center(): null;
      }
    },
  );
}
class DeliveryDataState extends State<DeliveryData> {
  List<OrderList> orderlist = [];
  late ArsProgressDialog progressDialog;
  // List<Person> persons= [];
  String empid="";
  MultiSelectController controller = new MultiSelectController();

  @override
  void initState() {
    super.initState();

    progressDialog = ArsProgressDialog(
        context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    getuserdata();

  }

  getuserdata() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empid = prefs.getString('empid')!;
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
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            for(int i=0;i<orderlist.length;i++)
              MultiSelectItem(
                  isSelecting: controller.isSelecting,
                  onSelected:(){

                    //  updatestatus();
                    setState(() {
                      controller.toggle(i);
                    });
                  },

                  child:new Column(
                    children: [
                      for(int i=0;i<orderlist.length;i++)
                        Container(
                            child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: ExpandableNotifier(
                                        child: Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Card(
                                            // color==null?color:Color(0xFFCFD8DC),

                                            color:controller.isSelected(i)
                                                ? Colors.grey[300] :Color(0xFFCFD8DC),

                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              children: <Widget>[
                                                ScrollOnExpand(
                                                  scrollOnExpand: true,
                                                  scrollOnCollapse: false,
                                                  child: ExpandablePanel(
                                                    theme: const ExpandableThemeData(
                                                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                      tapBodyToCollapse: false,
                                                    ),
                                                    header:Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(10.0),
                                                              topRight: Radius.circular(10.0),
                                                              bottomLeft: Radius.circular(10.0),
                                                              bottomRight: Radius.circular(10.0)
                                                          )
                                                      ),

                                                      child: Align(
                                                        alignment: Alignment.topCenter,
                                                        child:Padding(
                                                          padding: EdgeInsets.only(left:10,top: 10,right: 10,bottom: 10),
                                                          child:Container(
                                                            child: Column(
                                                                children:[
                                                                  Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child:Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Text(orderlist[i].custName,style: TextStyle(
                                                                            fontWeight: FontWeight.bold
                                                                        ),
                                                                        ),
                                                                      )
                                                                  ),
                                                                  Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child:Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Text(orderlist[i].custMobile),)
                                                                  ),
                                                                  Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child:Padding(
                                                                        padding: EdgeInsets.all(5),
                                                                        child: Text(orderlist[i].address),)
                                                                  ),
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    collapsed: Container(
                                                      child: Column(
                                                          children:[

                                                          ]
                                                      ),
                                                    ),

                                                    expanded: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child :Row(
                                                            children: [
                                                              Expanded(child:  Text("Id",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                              Expanded(child:  Text("Items",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                              Expanded(child:  Text("Rate",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
                                                              Expanded(child:  Text("Quantity",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                              Expanded(child:  Text("Total",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
                                                              Expanded(child:  Text("Status",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(height: 5,thickness: 5,indent: 20,endIndent: 20,),
                                                        Container(
                                                          padding: EdgeInsets.all(10),
                                                          child: Column(
                                                            children: [
                                                              for(int j=0;j<orderlist[i].itemDetails.length;j++)
                                                              // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
                                                                Slidable(
                                                                  child: Padding(
                                                                      padding: EdgeInsets.only(bottom: 10),
                                                                      child:Row(
                                                                        children: [
                                                                          //          Expanded(child: GestureDetector(
                                                                          //             onLongPress:  Text(orderlist[i].itemDetails[0].id.toString(),
                                                                          //       ),
                                                                          // ),
                                                                          // Text(orderlist[i].itemDetails[0].id.toString()

                                                                          if(orderlist[i].itemDetails[j].active=="Pending")
                                                                            Expanded(child:  Text(orderlist[i].itemDetails[j].id.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemName)),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemRate.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemQty.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemTotalAmount.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].active.toString())
                                                                          ),
                                                                        ],
                                                                      )),
                                                                  actionPane: SlidableDrawerActionPane(),
                                                                  actionExtentRatio: 0.15,
                                                                  // secondaryActions: [
                                                                  //   new GestureDetector(
                                                                  //     onTap: (){
                                                                  //
                                                                  //     },
                                                                  //     child: Container(
                                                                  //       width: 40,
                                                                  //       child:  Icon(Icons.delivery_dining),
                                                                  //     ),
                                                                  //   ),//action button to show on tail
                                                                  //   new GestureDetector(
                                                                  //     onTap: (){
                                                                  //
                                                                  //     },
                                                                  //     child: Container(
                                                                  //       width: 40,
                                                                  //       child:  Icon(Icons.cancel),
                                                                  //     ),
                                                                  //   )//
                                                                  // ],
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        // SingleChildScrollView(
                                                        //   child: Container(
                                                        //     padding: EdgeInsets.all(10),
                                                        //     child: Column(
                                                        //       children: [
                                                        //         for(int j=0;j<orderlist[i].itemDetails.length;j++)
                                                        //         // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
                                                        //           Slidable(child: Padding(
                                                        //               padding: EdgeInsets.only(bottom: 10),
                                                        //               child:Row(
                                                        //                 children: [
                                                        //                   //          Expanded(child: GestureDetector(
                                                        //                   //             onLongPress:  Text(orderlist[i].itemDetails[0].id.toString(),
                                                        //                   //       ),
                                                        //                   // ),
                                                        //                   // Text(orderlist[i].itemDetails[0].id.toString()
                                                        //
                                                        //                   if(orderlist[i].itemDetails[j].active=="Pending")
                                                        //                     Expanded(child:  Text(orderlist[i].itemDetails[j].id.toString())),
                                                        //                   Expanded(child:  Text(orderlist[i].itemDetails[j].itemName)),
                                                        //                   Expanded(child:  Text(orderlist[i].itemDetails[j].itemRate.toString())),
                                                        //                   Expanded(child:  Text(orderlist[i].itemDetails[j].itemQty.toString())),
                                                        //                   Expanded(child:  Text(orderlist[i].itemDetails[j].itemTotalAmount.toString())),
                                                        //                   Expanded(child:  Text(orderlist[i].itemDetails[j].active.toString())
                                                        //                   ),
                                                        //                 ],
                                                        //               )),
                                                        //             actionPane: SlidableDrawerActionPane(),
                                                        //             actionExtentRatio: 0.15,
                                                        //             // secondaryActions: [
                                                        //             //   new GestureDetector(
                                                        //             //     onTap: (){
                                                        //             //
                                                        //             //     },
                                                        //             //     child: Container(
                                                        //             //       width: 40,
                                                        //             //       child:  Icon(Icons.delivery_dining),
                                                        //             //     ),
                                                        //             //   ),//action button to show on tail
                                                        //             //   new GestureDetector(
                                                        //             //     onTap: (){
                                                        //             //
                                                        //             //     },
                                                        //             //     child: Container(
                                                        //             //       width: 40,
                                                        //             //       child:  Icon(Icons.cancel),
                                                        //             //     ),
                                                        //             //   )//
                                                        //             // ],
                                                        //           ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // )

                                                      ],
                                                    ),

                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                  // ExpandableNotifier(
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(1),
                                  //       child: Card(
                                  //         color: Color(0xFFCFD8DC),
                                  //         clipBehavior: Clip.antiAlias,
                                  //         child: Column(
                                  //           children: <Widget>[
                                  //             ScrollOnExpand(
                                  //               scrollOnExpand: true,
                                  //               scrollOnCollapse: false,
                                  //               child: ExpandablePanel(
                                  //                 theme: const ExpandableThemeData(
                                  //                   headerAlignment: ExpandablePanelHeaderAlignment.center,
                                  //                   // tapBodyToCollapse: true,
                                  //                 ),
                                  //                 header: Container(
                                  //                   decoration: BoxDecoration(
                                  //
                                  //                       borderRadius: BorderRadius.only(
                                  //                           topLeft: Radius.circular(10.0),
                                  //                           topRight: Radius.circular(10.0),
                                  //                           bottomLeft: Radius.circular(10.0),
                                  //                           bottomRight: Radius.circular(10.0)
                                  //                       )
                                  //                   ),
                                  //                   child: Align(
                                  //                     alignment: Alignment.centerLeft,
                                  //                     child: Padding(
                                  //                       padding: EdgeInsets.only(
                                  //                           left: 10, top: 10, right: 10, bottom: 10),
                                  //                       child: Container(
                                  //                         child: Column(children: [
                                  //                           Align(
                                  //                             alignment: Alignment.centerLeft,
                                  //                             child: Text("Arun"),
                                  //                           ),
                                  //                           Align(
                                  //                             alignment: Alignment.centerLeft,
                                  //                             child: Text("9999999998"),
                                  //                           ),
                                  //                           Align(
                                  //                               alignment: Alignment.centerLeft,
                                  //                               child: Text("Subhash Nagar")),
                                  //                         ]
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 collapsed: Container(
                                  //                   child: Column(children: [
                                  //                     // Text("Name"),
                                  //                     // Text("Mobile"),
                                  //                     // Text("Address")
                                  //                   ]),
                                  //                 ),
                                  //                 expanded: Column(
                                  //                   crossAxisAlignment: CrossAxisAlignment.start,
                                  //                   children: <Widget>[
                                  //                     for (var _ in Iterable.generate(3))
                                  //                       Padding(
                                  //                           padding: EdgeInsets.only(bottom: 10),
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                             ],
                                  //                           )),
                                  //                   ],
                                  //                 ),
                                  //                 builder: (_, collapsed, expanded) {
                                  //                   return Padding(
                                  //                     padding:
                                  //                     EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  //                     child: Expandable(
                                  //                       collapsed: collapsed,
                                  //                       expanded: expanded,
                                  //                       theme: const ExpandableThemeData(crossFadePoint: 0),
                                  //                     ),
                                  //                   );
                                  //                 },
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     )),
                                  // ExpandableNotifier(
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(1),
                                  //       child: Card(
                                  //         color: Color(0xFFCFD8DC),
                                  //         clipBehavior: Clip.antiAlias,
                                  //         child: Column(
                                  //           children: <Widget>[
                                  //             ScrollOnExpand(
                                  //               scrollOnExpand: true,
                                  //               scrollOnCollapse: false,
                                  //               child: ExpandablePanel(
                                  //                 theme: const ExpandableThemeData(
                                  //                   headerAlignment: ExpandablePanelHeaderAlignment.center,
                                  //                   tapBodyToCollapse: true,
                                  //                 ),
                                  //                 header: Container(
                                  //                   decoration: BoxDecoration(
                                  //
                                  //                       borderRadius: BorderRadius.only(
                                  //                           topLeft: Radius.circular(10.0),
                                  //                           topRight: Radius.circular(10.0),
                                  //                           bottomLeft: Radius.circular(10.0),
                                  //                           bottomRight: Radius.circular(10.0))),
                                  //                   child: Align(
                                  //                     alignment: Alignment.centerLeft,
                                  //                     child: Padding(
                                  //                       padding: EdgeInsets.only(
                                  //                           left: 10, top: 10, right: 10, bottom: 10),
                                  //                       child: Container(
                                  //                         child: Column(children: [
                                  //                           Align(
                                  //                             alignment: Alignment.centerLeft,
                                  //                             child: Text("Arun"),
                                  //                           ),
                                  //                           Align(
                                  //                             alignment: Alignment.centerLeft,
                                  //                             child: Text("9999999998"),
                                  //                           ),
                                  //                           Align(
                                  //                               alignment: Alignment.centerLeft,
                                  //                               child: Text("Subhash Nagar")),
                                  //                         ]),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 collapsed: Container(
                                  //                   child: Column(children: [
                                  //                     // Text("Name"),
                                  //                     // Text("Mobile"),
                                  //                     // Text("Address")
                                  //                   ]),
                                  //                 ),
                                  //                 expanded: Column(
                                  //                   crossAxisAlignment: CrossAxisAlignment.start,
                                  //                   children: <Widget>[
                                  //                     for (var _ in Iterable.generate(3))
                                  //                       Padding(
                                  //                           padding: EdgeInsets.only(bottom: 10),
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                               Expanded(child: Text("Data")),
                                  //                             ],
                                  //                           )),
                                  //                   ],
                                  //                 ),
                                  //                 builder: (_, collapsed, expanded) {
                                  //                   return Padding(
                                  //                     padding:
                                  //                     EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  //                     child: Expandable(
                                  //                       collapsed: collapsed,
                                  //                       expanded: expanded,
                                  //                       theme: const ExpandableThemeData(crossFadePoint: 0),
                                  //                     ),
                                  //                   );
                                  //                 },
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ))

                                ]
                            )
                        )

                    ],
                  ))

            //  deliverydata(orderlist),
            // MultiSelectItem(
            //     isSelecting: controller.isSelecting,
            //     onSelected:(){
            //       print("Dta");
            //       setState(() {
            //        deliverydata(orderlist);
            //        // controller.toggle(index);
            //        // controller.toggle(index);
            //       }
            //      );
            //     },
            //   child: deliverydata(orderlist),
            // )

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
    var response = await http.get(Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/10042'),headers: headers
    );

    Order_List order_data= Order_List.fromJson(json.decode(response.body));

    for(int i=0;i<order_data.orderList.length;i++){

      if(order_data.orderList[i].itemDetails[0].active=="Pending"){
        setState(() {
          orderlist.add(order_data.orderList[i]);
        }
        );
      }else{
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
  Future updatestatus() async {

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

    List<Items> json_data =[];
    // json_data.add(Items(243343));

    var response = await http.post(Uri.parse('http://164.52.200.38:90/DeliveryPanel/PostDelivery?ActionName=Cancel'), body: json.encode(json_data),headers:  {'Content-Type': 'application/json',},);

    Map<String, dynamic> response_data= json.decode(response.body);
    // Fluttertoast.showToast(msg: "${response_data['message']}",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    if(response_data['message']=="Record Updated Successfully.."){
      Fluttertoast.showToast(msg: "Record updated succesfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }else{
      Fluttertoast.showToast(msg: "Record not Updated Something wrong please Try Again..",
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

import 'dart:convert';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:crm_flutter/Model/Items.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
import 'package:crm_flutter/Model/Response.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  // List<Person> persons= [];
  String empid="";
  MultiSelectController controller = new MultiSelectController();

  @override
  void initState() {
    super.initState();

    progressDialog = ArsProgressDialog(
        context,
        blur: 2,
        backgroundColor: Color(0x33000000),
        animationDuration: Duration(milliseconds: 500));

    getuserdata();

  }

  getuserdata() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // empid = prefs.getString('empid')!;
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
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[

            Column(
              children: [
                for(int i=0;i<orderlist.length;i++)
                  Container(
                      child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: ExpandableNotifier(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Card(
                                      // color==null?color:Color(0xFFCFD8DC),

                                      color:controller.isSelected(i)
                                          ? Colors.grey[300] :Color(0xFFCFD8DC),

                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        children: <Widget>[
                                          ScrollOnExpand(
                                            scrollOnExpand: true,
                                            scrollOnCollapse: false,
                                            child: ExpandablePanel(
                                              theme: const ExpandableThemeData(
                                                headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                tapBodyToCollapse: false,
                                              ),
                                              header:Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(10.0),
                                                        topRight: Radius.circular(10.0),
                                                        bottomLeft: Radius.circular(10.0),
                                                        bottomRight: Radius.circular(10.0)
                                                    )
                                                ),

                                                child: Align(
                                                  alignment: Alignment.topCenter,
                                                  child:Padding(
                                                    padding: EdgeInsets.only(left:10,top: 10,right: 10,bottom: 10),
                                                    child:Container(
                                                      child: Column(
                                                          children:[
                                                            Align(
                                                                alignment: Alignment.centerLeft,
                                                                child:Padding(
                                                                  padding: EdgeInsets.all(5),
                                                                  child: Text(orderlist[i].custName,style: TextStyle(
                                                                      fontWeight: FontWeight.bold
                                                                  ),
                                                                  ),
                                                                )
                                                            ),
                                                            Align(
                                                                alignment: Alignment.centerLeft,
                                                                child:Padding(
                                                                  padding: EdgeInsets.all(5),
                                                                  child: Text(orderlist[i].custMobile),)
                                                            ),
                                                            Align(
                                                                alignment: Alignment.centerLeft,
                                                                child:Padding(
                                                                  padding: EdgeInsets.all(5),
                                                                  child: Text(orderlist[i].address),)
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              collapsed: Container(
                                                child: Column(
                                                    children:[

                                                    ]
                                                ),
                                              ),

                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child :Row(
                                                      children: [
                                                        Expanded(child:  Text("Id",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                        Expanded(child:  Text("Items",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                        Expanded(child:  Text("Rate",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
                                                        Expanded(child:  Text("Quantity",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                        Expanded(child:  Text("Total",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
                                                        Expanded(child:  Text("Status",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 5,thickness: 5,indent: 20,endIndent: 20,),
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        for(int j=0;j<orderlist[i].itemDetails.length;j++)
                                                        // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
                                                          MultiSelectItem(
                                                            isSelecting: controller.isSelecting,
                                                            onSelected: (){

                                                            },
                                                            child: Padding(
                                                                padding: EdgeInsets.only(bottom: 10),
                                                                child:Row(
                                                                  children: [
                                                                    Container(
                                                                      child: Column(
                                                                        children: [
                                                                          if(orderlist[i].itemDetails[j].active=="Pending")
                                                                            Expanded(child:  Text(orderlist[i].itemDetails[j].id.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemName)),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemRate.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemQty.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].itemTotalAmount.toString())),
                                                                          Expanded(child:  Text(orderlist[i].itemDetails[j].active.toString())
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                            ),
                                                          ),
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
                                  )),
                            ),
                          ]
                      )
                  )

              ],
            )
            // MultiSelectItem(
            // isSelecting: controller.isSelecting,
            //     onSelected:(){
            //
            //     //  updatestatus();
            //       setState(() {
            //         controller.toggle(i);
            //       });
            //     },
            //
            //     child:new Column(
            //       children: [
            //         for(int i=0;i<orderlist.length;i++)
            //           Container(
            //               child: Column(
            //                   children: [
            //                     Align(
            //                       alignment: Alignment.topCenter,
            //                       child: ExpandableNotifier(
            //                           child: Padding(
            //                             padding: const EdgeInsets.all(1),
            //                             child: Card(
            //                               // color==null?color:Color(0xFFCFD8DC),
            //
            //                               color:controller.isSelected(i)
            //                                   ? Colors.grey[300] :Color(0xFFCFD8DC),
            //
            //                               clipBehavior: Clip.antiAlias,
            //                               child: Column(
            //                                 children: <Widget>[
            //                                   ScrollOnExpand(
            //                                     scrollOnExpand: true,
            //                                     scrollOnCollapse: false,
            //                                     child: ExpandablePanel(
            //                                       theme: const ExpandableThemeData(
            //                                         headerAlignment: ExpandablePanelHeaderAlignment.center,
            //                                         tapBodyToCollapse: false,
            //                                       ),
            //                                       header:Container(
            //                                         decoration: BoxDecoration(
            //                                             borderRadius: BorderRadius.only(
            //                                                 topLeft: Radius.circular(10.0),
            //                                                 topRight: Radius.circular(10.0),
            //                                                 bottomLeft: Radius.circular(10.0),
            //                                                 bottomRight: Radius.circular(10.0)
            //                                             )
            //                                         ),
            //
            //                                         child: Align(
            //                                           alignment: Alignment.topCenter,
            //                                           child:Padding(
            //                                             padding: EdgeInsets.only(left:10,top: 10,right: 10,bottom: 10),
            //                                             child:Container(
            //                                               child: Column(
            //                                                   children:[
            //                                                     Align(
            //                                                         alignment: Alignment.centerLeft,
            //                                                         child:Padding(
            //                                                           padding: EdgeInsets.all(5),
            //                                                           child: Text(orderlist[i].custName,style: TextStyle(
            //                                                               fontWeight: FontWeight.bold
            //                                                           ),
            //                                                         ),
            //                                                       )
            //                                                     ),
            //                                                     Align(
            //                                                         alignment: Alignment.centerLeft,
            //                                                         child:Padding(
            //                                                           padding: EdgeInsets.all(5),
            //                                                           child: Text(orderlist[i].custMobile),)
            //                                                     ),
            //                                                     Align(
            //                                                         alignment: Alignment.centerLeft,
            //                                                         child:Padding(
            //                                                           padding: EdgeInsets.all(5),
            //                                                           child: Text(orderlist[i].address),)
            //                                                     ),
            //                                                   ]
            //                                               ),
            //                                             ),
            //                                           ),
            //                                         ),
            //                                       ),
            //
            //                                       collapsed: Container(
            //                                         child: Column(
            //                                             children:[
            //
            //                                             ]
            //                                         ),
            //                                       ),
            //
            //                                       expanded: Column(
            //                                         crossAxisAlignment: CrossAxisAlignment.start,
            //                                         children: <Widget>[
            //                                           Align(
            //                                             alignment: Alignment.center,
            //                                             child :Row(
            //                                               children: [
            //                                                 Expanded(child:  Text("Id",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
            //                                                 Expanded(child:  Text("Items",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
            //                                                 Expanded(child:  Text("Rate",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
            //                                                 Expanded(child:  Text("Quantity",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
            //                                                 Expanded(child:  Text("Total",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
            //                                                 Expanded(child:  Text("Status",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
            //                                               ],
            //                                             ),
            //                                           ),
            //                                           Divider(height: 5,thickness: 5,indent: 20,endIndent: 20,),
            //                                           Container(
            //                                             padding: EdgeInsets.all(10),
            //                                             child: Column(
            //                                               children: [
            //                                                 for(int j=0;j<orderlist[i].itemDetails.length;j++)
            //                                                 // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
            //                                                   Slidable(
            //                                                     child: Padding(
            //                                                       padding: EdgeInsets.only(bottom: 10),
            //                                                       child:Row(
            //                                                         children: [
            //
            //                                                           if(orderlist[i].itemDetails[j].active=="Pending")
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].id.toString())),
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].itemName)),
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].itemRate.toString())),
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].itemQty.toString())),
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].itemTotalAmount.toString())),
            //                                                           Expanded(child:  Text(orderlist[i].itemDetails[j].active.toString())
            //                                                           ),
            //                                                         ],
            //                                                       )),
            //                                                     actionPane: SlidableDrawerActionPane(),
            //                                                     actionExtentRatio: 0.15,
            //
            //                                                  ),
            //                                               ],
            //                                             ),
            //                                           ),
            //
            //
            //                                         ],
            //                                       ),
            //
            //                                     ),
            //                                   ),
            //                                 ],
            //                               ),
            //                             ),
            //                           )),
            //                     ),
            //                   ]
            //               )
            //           )
            //
            //       ],
            //     )
            // )

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
    var response = await http.get(Uri.parse('http://164.52.200.38:90/DeliveryPanel/Delivery/10042'),headers: headers
    );

    Order_List order_data= Order_List.fromJson(json.decode(response.body));

    for(int i=0;i<order_data.orderList.length;i++){

      if(order_data.orderList[i].itemDetails[0].active=="Pending"){
        setState(() {
          orderlist.add(order_data.orderList[i]);
        }
        );
      }else{
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
  Future updatestatus() async {

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

    List<Items> json_data =[];
    // json_data.add(Items(243343));

    var response = await http.post(Uri.parse('http://164.52.200.38:90/DeliveryPanel/PostDelivery?ActionName=Cancel'), body: json.encode(json_data),headers:  {'Content-Type': 'application/json',},);

    Map<String, dynamic> response_data= json.decode(response.body);
    // Fluttertoast.showToast(msg: "${response_data['message']}",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.black,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    if(response_data['message']=="Record Updated Successfully.."){
      Fluttertoast.showToast(msg: "Record updated succesfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }else{
      Fluttertoast.showToast(msg: "Record not Updated Something wrong please Try Again..",
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

















