import 'package:firebase_database/firebase_database.dart';

class FireDataBase {
  final databaseReference = FirebaseDatabase.instance.reference();
  var listOfItems= [];
  Future<List> readData() async {

    var result = await databaseReference.once();
    Map<dynamic, dynamic> map = result.value;

    map.forEach((key, value) {
      listOfItems = value;
    });
    return listOfItems;
  }
}
