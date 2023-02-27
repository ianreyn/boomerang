import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Assignment {
  int? id;
  String? title;
  DateTime? dueDate;
  DateTime? doTime;
  String? account;
  //DocumentReference? refid;
  Assignment({this.title, this.dueDate, this.doTime, this.account});

  Assignment.fromMap(Map map)
  {
    id = map['id'];
    title = map['title'];
    dueDate = DateTime.parse(map['date']);
    doTime = DateTime.parse(map['plan']);
    account = map['account'];
  }

  Map<String, Object?> toMap()
  {
    return {
      'id': this.id!,
      'title': this.title!,
      'date': DateFormat('yyyy-MM-dd').format(this.dueDate!),
      'plan': DateFormat('yyyy-MM-dd').format(this.doTime!),
      'account': this.account!
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "ID: $id, Title: $title, Due date: $dueDate";
  }

}