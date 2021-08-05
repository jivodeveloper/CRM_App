import 'dart:convert';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:crm_flutter/Model/OrderList.dart';
import 'package:crm_flutter/Model/Order_List.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  List<Person> persons= [];
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
            deliverydata(orderlist,persons),

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

}

class Person{ //modal class for Person object
  late String id, name, phone, address;
  Person({required this.id, required this.name, required this.phone,required this.address});
}

Widget deliverydata(List<OrderList> orderlist,List<Person> persons){

  return new Column(
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
                            color: Color(0xFFCFD8DC),
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
                                        Divider(height: 5,
                                          thickness: 5,
                                          indent: 20,
                                          endIndent: 20,),
                                        SingleChildScrollView(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                for(int j=0;j<orderlist[i].itemDetails.length;j++)
                                                // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
                                                  Slidable(child: Padding(
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
                                                    secondaryActions: [
                                                      new GestureDetector(
                                                        onTap: (){

                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          child:  Icon(Icons.delivery_dining),
                                                        ),
                                                      ),//action button to show on tail
                                                      new GestureDetector(
                                                        onTap: (){

                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          child:  Icon(Icons.cancel),
                                                        ),
                                                      )//
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )

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
  );

}

// Widget deliverydata(List<OrderList> orderlist){
//   MultiSelectController controller = new MultiSelectController();
//   return new MultiSelectItem(
//       isSelecting: controller.isSelecting,
//       onSelected:(){
//         setState(() {
//
//         },
//       child:new Column(
//         children: [
//           for(int i=0;i<orderlist.length;i++)
//
//             Container(
//                 child: Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.topCenter,
//                         child: ExpandableNotifier(
//                             child: Padding(
//                               padding: const EdgeInsets.all(1),
//                               child: Card(
//                                 // color==null?color:Color(0xFFCFD8DC),
//
//                                 color:controller.isSelected(i)
//                                     ? Colors.grey[300] :Color(0xFFCFD8DC),
//
//                                 clipBehavior: Clip.antiAlias,
//                                 child: Column(
//                                   children: <Widget>[
//                                     ScrollOnExpand(
//                                       scrollOnExpand: true,
//                                       scrollOnCollapse: false,
//                                       child: ExpandablePanel(
//                                         theme: const ExpandableThemeData(
//                                           headerAlignment: ExpandablePanelHeaderAlignment.center,
//                                           tapBodyToCollapse: false,
//                                         ),
//                                         header:Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.only(
//                                                   topLeft: Radius.circular(10.0),
//                                                   topRight: Radius.circular(10.0),
//                                                   bottomLeft: Radius.circular(10.0),
//                                                   bottomRight: Radius.circular(10.0)
//                                               )
//                                           ),
//
//                                           child: Align(
//                                             alignment: Alignment.topCenter,
//                                             child:Padding(
//                                               padding: EdgeInsets.only(left:10,top: 10,right: 10,bottom: 10),
//                                               child:Container(
//                                                 child: Column(
//                                                     children:[
//                                                       Align(
//                                                           alignment: Alignment.centerLeft,
//                                                           child:Padding(
//                                                             padding: EdgeInsets.all(5),
//                                                             child: Text(orderlist[i].custName,style: TextStyle(
//                                                                 fontWeight: FontWeight.bold
//                                                             ),
//                                                             ),
//                                                           )
//                                                       ),
//                                                       Align(
//                                                           alignment: Alignment.centerLeft,
//                                                           child:Padding(
//                                                             padding: EdgeInsets.all(5),
//                                                             child: Text(orderlist[i].custMobile),)
//                                                       ),
//                                                       Align(
//                                                           alignment: Alignment.centerLeft,
//                                                           child:Padding(
//                                                             padding: EdgeInsets.all(5),
//                                                             child: Text(orderlist[i].address),)
//                                                       ),
//                                                     ]
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//
//                                         collapsed: Container(
//                                           child: Column(
//                                               children:[
//
//                                               ]
//                                           ),
//                                         ),
//
//                                         expanded: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Align(
//                                               alignment: Alignment.center,
//                                               child :Row(
//                                                 children: [
//                                                   Expanded(child:  Text("Id",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
//                                                   Expanded(child:  Text("Items",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
//                                                   Expanded(child:  Text("Rate",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
//                                                   Expanded(child:  Text("Quantity",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
//                                                   Expanded(child:  Text("Total",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold ),textAlign: TextAlign.center,)),
//                                                   Expanded(child:  Text("Status",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
//                                                 ],
//                                               ),
//                                             ),
//                                             Divider(height: 5,
//                                               thickness: 5,
//                                               indent: 20,
//                                               endIndent: 20,),
//                                             SingleChildScrollView(
//                                               child: Container(
//                                                 padding: EdgeInsets.all(10),
//                                                 child: Column(
//                                                   children: [
//                                                     for(int j=0;j<orderlist[i].itemDetails.length;j++)
//                                                     // for (var _ in Iterable.generate(orderlist[i].itemDetails.length))
//                                                       Slidable(child: Padding(
//                                                           padding: EdgeInsets.only(bottom: 10),
//                                                           child:Row(
//                                                             children: [
//                                                               //          Expanded(child: GestureDetector(
//                                                               //             onLongPress:  Text(orderlist[i].itemDetails[0].id.toString(),
//                                                               //       ),
//                                                               // ),
//                                                               // Text(orderlist[i].itemDetails[0].id.toString()
//
//                                                               if(orderlist[i].itemDetails[j].active=="Pending")
//                                                                 Expanded(child:  Text(orderlist[i].itemDetails[j].id.toString())),
//                                                               Expanded(child:  Text(orderlist[i].itemDetails[j].itemName)),
//                                                               Expanded(child:  Text(orderlist[i].itemDetails[j].itemRate.toString())),
//                                                               Expanded(child:  Text(orderlist[i].itemDetails[j].itemQty.toString())),
//                                                               Expanded(child:  Text(orderlist[i].itemDetails[j].itemTotalAmount.toString())),
//                                                               Expanded(child:  Text(orderlist[i].itemDetails[j].active.toString())
//                                                               ),
//                                                             ],
//                                                           )),
//                                                         actionPane: SlidableDrawerActionPane(),
//                                                         actionExtentRatio: 0.15,
//                                                         secondaryActions: [
//                                                           new GestureDetector(
//                                                             onTap: (){
//
//                                                             },
//                                                             child: Container(
//                                                               width: 40,
//                                                               child:  Icon(Icons.delivery_dining),
//                                                             ),
//                                                           ),//action button to show on tail
//                                                           new GestureDetector(
//                                                             onTap: (){
//
//                                                             },
//                                                             child: Container(
//                                                               width: 40,
//                                                               child:  Icon(Icons.cancel),
//                                                             ),
//                                                           )//
//                                                         ],
//                                                       ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             )
//
//                                           ],
//                                         ),
//
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )),
//                       ),
//                       // ExpandableNotifier(
//                       //     child: Padding(
//                       //       padding: const EdgeInsets.all(1),
//                       //       child: Card(
//                       //         color: Color(0xFFCFD8DC),
//                       //         clipBehavior: Clip.antiAlias,
//                       //         child: Column(
//                       //           children: <Widget>[
//                       //             ScrollOnExpand(
//                       //               scrollOnExpand: true,
//                       //               scrollOnCollapse: false,
//                       //               child: ExpandablePanel(
//                       //                 theme: const ExpandableThemeData(
//                       //                   headerAlignment: ExpandablePanelHeaderAlignment.center,
//                       //                   // tapBodyToCollapse: true,
//                       //                 ),
//                       //                 header: Container(
//                       //                   decoration: BoxDecoration(
//                       //
//                       //                       borderRadius: BorderRadius.only(
//                       //                           topLeft: Radius.circular(10.0),
//                       //                           topRight: Radius.circular(10.0),
//                       //                           bottomLeft: Radius.circular(10.0),
//                       //                           bottomRight: Radius.circular(10.0)
//                       //                       )
//                       //                   ),
//                       //                   child: Align(
//                       //                     alignment: Alignment.centerLeft,
//                       //                     child: Padding(
//                       //                       padding: EdgeInsets.only(
//                       //                           left: 10, top: 10, right: 10, bottom: 10),
//                       //                       child: Container(
//                       //                         child: Column(children: [
//                       //                           Align(
//                       //                             alignment: Alignment.centerLeft,
//                       //                             child: Text("Arun"),
//                       //                           ),
//                       //                           Align(
//                       //                             alignment: Alignment.centerLeft,
//                       //                             child: Text("9999999998"),
//                       //                           ),
//                       //                           Align(
//                       //                               alignment: Alignment.centerLeft,
//                       //                               child: Text("Subhash Nagar")),
//                       //                         ]
//                       //                         ),
//                       //                       ),
//                       //                     ),
//                       //                   ),
//                       //                 ),
//                       //                 collapsed: Container(
//                       //                   child: Column(children: [
//                       //                     // Text("Name"),
//                       //                     // Text("Mobile"),
//                       //                     // Text("Address")
//                       //                   ]),
//                       //                 ),
//                       //                 expanded: Column(
//                       //                   crossAxisAlignment: CrossAxisAlignment.start,
//                       //                   children: <Widget>[
//                       //                     for (var _ in Iterable.generate(3))
//                       //                       Padding(
//                       //                           padding: EdgeInsets.only(bottom: 10),
//                       //                           child: Row(
//                       //                             children: [
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                             ],
//                       //                           )),
//                       //                   ],
//                       //                 ),
//                       //                 builder: (_, collapsed, expanded) {
//                       //                   return Padding(
//                       //                     padding:
//                       //                     EdgeInsets.only(left: 10, right: 10, bottom: 10),
//                       //                     child: Expandable(
//                       //                       collapsed: collapsed,
//                       //                       expanded: expanded,
//                       //                       theme: const ExpandableThemeData(crossFadePoint: 0),
//                       //                     ),
//                       //                   );
//                       //                 },
//                       //               ),
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     )),
//                       // ExpandableNotifier(
//                       //     child: Padding(
//                       //       padding: const EdgeInsets.all(1),
//                       //       child: Card(
//                       //         color: Color(0xFFCFD8DC),
//                       //         clipBehavior: Clip.antiAlias,
//                       //         child: Column(
//                       //           children: <Widget>[
//                       //             ScrollOnExpand(
//                       //               scrollOnExpand: true,
//                       //               scrollOnCollapse: false,
//                       //               child: ExpandablePanel(
//                       //                 theme: const ExpandableThemeData(
//                       //                   headerAlignment: ExpandablePanelHeaderAlignment.center,
//                       //                   tapBodyToCollapse: true,
//                       //                 ),
//                       //                 header: Container(
//                       //                   decoration: BoxDecoration(
//                       //
//                       //                       borderRadius: BorderRadius.only(
//                       //                           topLeft: Radius.circular(10.0),
//                       //                           topRight: Radius.circular(10.0),
//                       //                           bottomLeft: Radius.circular(10.0),
//                       //                           bottomRight: Radius.circular(10.0))),
//                       //                   child: Align(
//                       //                     alignment: Alignment.centerLeft,
//                       //                     child: Padding(
//                       //                       padding: EdgeInsets.only(
//                       //                           left: 10, top: 10, right: 10, bottom: 10),
//                       //                       child: Container(
//                       //                         child: Column(children: [
//                       //                           Align(
//                       //                             alignment: Alignment.centerLeft,
//                       //                             child: Text("Arun"),
//                       //                           ),
//                       //                           Align(
//                       //                             alignment: Alignment.centerLeft,
//                       //                             child: Text("9999999998"),
//                       //                           ),
//                       //                           Align(
//                       //                               alignment: Alignment.centerLeft,
//                       //                               child: Text("Subhash Nagar")),
//                       //                         ]),
//                       //                       ),
//                       //                     ),
//                       //                   ),
//                       //                 ),
//                       //                 collapsed: Container(
//                       //                   child: Column(children: [
//                       //                     // Text("Name"),
//                       //                     // Text("Mobile"),
//                       //                     // Text("Address")
//                       //                   ]),
//                       //                 ),
//                       //                 expanded: Column(
//                       //                   crossAxisAlignment: CrossAxisAlignment.start,
//                       //                   children: <Widget>[
//                       //                     for (var _ in Iterable.generate(3))
//                       //                       Padding(
//                       //                           padding: EdgeInsets.only(bottom: 10),
//                       //                           child: Row(
//                       //                             children: [
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                               Expanded(child: Text("Data")),
//                       //                             ],
//                       //                           )),
//                       //                   ],
//                       //                 ),
//                       //                 builder: (_, collapsed, expanded) {
//                       //                   return Padding(
//                       //                     padding:
//                       //                     EdgeInsets.only(left: 10, right: 10, bottom: 10),
//                       //                     child: Expandable(
//                       //                       collapsed: collapsed,
//                       //                       expanded: expanded,
//                       //                       theme: const ExpandableThemeData(crossFadePoint: 0),
//                       //                     ),
//                       //                   );
//                       //                 },
//                       //               ),
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     ))
//
//                     ]
//                 )
//             )
//
//         ],
//       ));
//
//    }
//   );
//
// }




