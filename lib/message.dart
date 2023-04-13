import 'package:flutter/material.dart';

class Message
{
  String? classID;
  String? student;
  String? message;

  Message({this.classID, this.student, this.message});

  Message.fromMap(Map map)
  {
    classID = map['classID'];
    student = map['student'];
    message = map['message'];
  }

  Map<String, Object?> toMap()
  {
    return {
      'classID': classID,
      'student': student,
      'message': message
    };
  }
}