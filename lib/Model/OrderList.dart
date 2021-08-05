import 'ItemDetails.dart';

class OrderList {
  late int id;
  late String custMobile;
  late String custName;
  late int zoneId;
  late Null zoneName;
  late int areaId;
  late Null areaName;
  late int stateId;
  late Null stateName;
  late Null landmark;
  late String address;
  late int pincode;
  late double totalPrice;
  late int totalQty;
  late Null paymentMode;
  late Null paymentRemark;
  late Null paymentNumber;
  late Null remark;
  late int callerId;
  late int deliveryAssignId;
  late Null deliveryAssignName;
  late Null deliveryAssignDate;
  late Null callerName;
  late Null source;
  late Null insertedDate;
  late Null itemCoupon;
  List<ItemDetails> itemDetails= [];

  OrderList(
      {required this.id,
        required this.custMobile,
        required this.custName,
        required this.zoneId,
        required this.zoneName,
        required this.areaId,
        required this.areaName,
        required this.stateId,
        required this.stateName,
        required this.landmark,
        required this.address,
        required this.pincode,
        required this.totalPrice,
        required this.totalQty,
        required this.paymentMode,
        required this.paymentRemark,
        required this.paymentNumber,
        required this.remark,
        required this.callerId,
        required this.deliveryAssignId,
        required this.deliveryAssignName,
        required this.deliveryAssignDate,
        required this.callerName,
        required this.source,
        required this.insertedDate,
        required this.itemCoupon,
        required this.itemDetails});

  OrderList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    custMobile = json['cust_mobile'];
    custName = json['cust_name'];
    zoneId = json['Zone_id'];
    zoneName = json['zoneName'];
    areaId = json['Area_id'];
    areaName = json['AreaName'];
    stateId = json['State_id'];
    stateName = json['stateName'];
    landmark = json['landmark'];
    address = json['Address'];
    pincode = json['pincode'];
    totalPrice = json['Total_Price'];
    totalQty = json['total_qty'];
    paymentMode = json['Payment_mode'];
    paymentRemark = json['payment_remark'];
    paymentNumber = json['paymentNumber'];
    remark = json['Remark'];
    callerId = json['CallerId'];
    deliveryAssignId = json['DeliveryAssignId'];
    deliveryAssignName = json['DeliveryAssignName'];
    deliveryAssignDate = json['DeliveryAssignDate'];
    callerName = json['callerName'];
    source = json['Source'];
    insertedDate = json['insertedDate'];
    itemCoupon = json['ItemCoupon'];
    if (json['ItemDetails'] != null) {
      itemDetails = <ItemDetails> [];
      json['ItemDetails'].forEach((v) {
        itemDetails.add(new ItemDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cust_mobile'] = this.custMobile;
    data['cust_name'] = this.custName;
    data['Zone_id'] = this.zoneId;
    data['zoneName'] = this.zoneName;
    data['Area_id'] = this.areaId;
    data['AreaName'] = this.areaName;
    data['State_id'] = this.stateId;
    data['stateName'] = this.stateName;
    data['landmark'] = this.landmark;
    data['Address'] = this.address;
    data['pincode'] = this.pincode;
    data['Total_Price'] = this.totalPrice;
    data['total_qty'] = this.totalQty;
    data['Payment_mode'] = this.paymentMode;
    data['payment_remark'] = this.paymentRemark;
    data['paymentNumber'] = this.paymentNumber;
    data['Remark'] = this.remark;
    data['CallerId'] = this.callerId;
    data['DeliveryAssignId'] = this.deliveryAssignId;
    data['DeliveryAssignName'] = this.deliveryAssignName;
    data['DeliveryAssignDate'] = this.deliveryAssignDate;
    data['callerName'] = this.callerName;
    data['Source'] = this.source;
    data['insertedDate'] = this.insertedDate;
    data['ItemCoupon'] = this.itemCoupon;
    if (this.itemDetails != null) {
      data['ItemDetails'] = this.itemDetails.map((v) => v.toJson()).toList();
    }
    return data;
  }
}