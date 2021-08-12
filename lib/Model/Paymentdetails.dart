
class Paymentdetails{

  String itemId="";
  String PayMode="";
  String PayAmount ="" ;
  String deliveryBoyID="";
  String ReferenceNumber="0";

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'itemId': itemId,
      'PayMode': PayMode,
      'PayAmount': PayAmount,
      'ReferenceNumber': ReferenceNumber,
      'deliveryBoyID' : deliveryBoyID
    };

    if (map != null) {
      map['itemId'] = itemId;
      map['PayMode'] = PayMode;
      map['PayAmount'] = PayAmount;
      map['ReferenceNumber'] = ReferenceNumber;
      map['deliveryBoyID'] = deliveryBoyID;
    }
    return map;
  }

  Paymentdetails();

  Paymentdetails.fromMap(Map<String,dynamic> map) {
    itemId = map['itemId'];
    PayMode = map['PayMode'];
    PayAmount = map['PayAmount'];
    ReferenceNumber = map['ReferenceNumber'];
    deliveryBoyID = map['deliveryBoyID'];
  }

}