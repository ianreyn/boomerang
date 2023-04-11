import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Assignment {
  String? title;
  DateTime? dueDate;
  DateTime? doTime;
  double? length;
  String? classId;
  //DocumentReference? refid;
  Assignment({this.title, this.dueDate, this.doTime, this.length, this.classId});

  Assignment.fromMap(Map map)
  {
    title = map['title'];
    dueDate = map['dueTime'].toDate();
    doTime = map['doTime'].toDate();
    length = map['length'].toDouble();
    classId = map['classId'];
  }

  Map<String, Object?> toMap()
  {
    return {
      'title': this.title!,
      'dueTime': Timestamp.fromDate(dueDate!),
      'doTime': Timestamp.fromDate(doTime!),
      'length': this.length!,
      'classId': this.classId
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Title: $title, Due date: $dueDate, Class: $classId";
  }

}