import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? username;
  String? password;

  DocumentReference? refid;

  Account.fromMap(var map, {this.refid}) //don't forget to add reference id back
  {
    this.username = map['username'];
    this.password = map['password'];
  }
}
