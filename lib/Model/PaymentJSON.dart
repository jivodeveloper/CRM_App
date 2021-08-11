import 'Items.dart';

class PaymentJSON{
  int item_id;
  String paymode;
  int payamount;
  int deliveryboy;

  PaymentJSON(this.item_id,this.paymode,this.payamount,this.deliveryboy);

  Map toJson() =>{
    'itemId' : item_id,
    'PayMode' : paymode,
    'PayAmount' : payamount,
    'deliveryBoyID' : deliveryboy
  };

}