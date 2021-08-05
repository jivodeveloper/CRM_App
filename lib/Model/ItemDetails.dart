
class ItemDetails {

  late int id;
  late int itemId;
  late String itemName;
  late int itemQty;
  late int uomValue;
  late double itemRate;
  late double itemTotalAmount;
  late Null coupon;
  late Null deliveryRemark;
  late Null uom;
  late Null rawItemName;
  late int inQty;
  late int outQty;
  late String active;
  late Null payCharge;
  late double reciableAmt;

  ItemDetails(
      { required this.id,
        required this.itemId,
        required this.itemName,
        required this.itemQty,
        required this.uomValue,
        required this.itemRate,
        required this.itemTotalAmount,
        required this.coupon,
        required this.deliveryRemark,
        required this.uom,
        required this.rawItemName,
        required this.inQty,
        required this.outQty,
        required this.active,
        required this.payCharge,
        required this.reciableAmt});

  ItemDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    itemName = json['item_name'];
    itemQty = json['item_qty'];
    uomValue = json['Uom_value'];
    itemRate = json['item_rate'];
    itemTotalAmount = json['item_total_amount'];
    coupon = json['coupon'];
    deliveryRemark = json['deliveryRemark'];
    uom = json['Uom'];
    rawItemName = json['RawItemName'];
    inQty = json['InQty'];
    outQty = json['OutQty'];
    active = json['Active'];
    payCharge = json['PayCharge'];
    reciableAmt = json['ReciableAmt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['item_id'] = this.itemId;
    data['item_name'] = this.itemName;
    data['item_qty'] = this.itemQty;
    data['Uom_value'] = this.uomValue;
    data['item_rate'] = this.itemRate;
    data['item_total_amount'] = this.itemTotalAmount;
    data['coupon'] = this.coupon;
    data['deliveryRemark'] = this.deliveryRemark;
    data['Uom'] = this.uom;
    data['RawItemName'] = this.rawItemName;
    data['InQty'] = this.inQty;
    data['OutQty'] = this.outQty;
    data['Active'] = this.active;
    data['PayCharge'] = this.payCharge;
    data['ReciableAmt'] = this.reciableAmt;
    return data;
  }
}