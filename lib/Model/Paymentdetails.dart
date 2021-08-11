
class Paymentdetails{
  String name="";
  String mobile="";
  double amount=0.0;
  String reference_id="";
  String payment_details="";

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'name': name,
      'mobile': mobile,
      'amount': amount,
      'reference_id': reference_id,
      'payment_details' : payment_details
    };
    if (mobile != null) {
      map['name'] = name;
      map['mobile'] = mobile;
      map['amount'] = amount;
      map['reference_id'] = reference_id;
      map['payment_details'] = payment_details;
    }
    return map;
  }

  Paymentdetails();

  Paymentdetails.fromMap(Map<String,dynamic> map) {
    name = map['name'];
    mobile = map['mobile'];
    amount = map['amount'];
    reference_id = map['reference_id'];
    payment_details = map['payment_details'];
  }
}