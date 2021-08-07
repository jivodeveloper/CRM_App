import 'package:crm_flutter/Model/Payment.dart';
import 'package:crm_flutter/Model/Paymentdetails.dart';
import 'package:crm_flutter/ui/PaymentDetails.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PaymentDatabaseHelper{
  static late PaymentDatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  Database? _database;

  static final _databaseName = "CRM.db";
  static final _databaseVersion = 2;
  static final table = 'paymentdetails';
  static final columnname = 'name';
  static final columnamount = 'amount';
  static final columnreferenceId = 'reference_id';
  static final columnpayment_details = 'payment_details';
  static final columnmobile = 'mobile';


  PaymentDatabaseHelper._privateConstructor();
  static final PaymentDatabaseHelper instance = PaymentDatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    // if (_database == null)
    _database = await _initDatabase();
    // lazily instantiate the db the first time it is accessed

    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnname TEXT NOT NULL,
            $columnamount TEXT NOT NULL,
            $columnreferenceId TEXT NOT NULL, $columnmobile TEXT NOT NULL,$columnpayment_details TEXT NOT NULL)''');
  }

  Future<int> insert(Paymentdetails payment) async {
    Database? db = await instance.database;
    return await db!.insert(table, {'name': payment.name,'mobile':payment.mobile, 'amount': payment.amount,'reference_id': payment.reference_id,'payment_details':payment.payment_details});
  }

}