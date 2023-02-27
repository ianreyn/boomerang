import 'dart:collection';
//Sources: https://pub.dev/packages/table_calendar
//https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart

import 'package:boomerang_app/assignment.dart';
import 'package:boomerang_app/models/assignment_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AssignmentList extends StatefulWidget {
  AssignmentList({Key? key, this.title}) : super(key: key);

  String? title;

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {

  final _model = AssignmentModel();
  List<Assignment> assignments = [];
  var _lastInsertedID = 0;
  //String selectedType = "all";
  DateTime _firstDay = DateTime.utc(2010);
  DateTime _lastDay = DateTime.utc(2050);
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: _makeCalendar(context),
    );
  }

  Widget _makeCalendar(BuildContext context)
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.0,
          height: 40.0,
          child: ElevatedButton(
              onPressed: addAssignment,
              child: Row(
                children: [
                  Text("Add"),
                  Icon(Icons.add),
                ],
              )
          ),
        ),
        TableCalendar(
            focusedDay: _focusedDay,
            firstDay: _firstDay,
            lastDay: _lastDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
                return isSameDay(day, _selectedDay);
             },
            /*
            eventLoader: (day) {
              return getEventsForDay(day);
            },
            */
            onFormatChanged: ((format) {
              if (_calendarFormat != format)
                {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
            }),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
               setState(() {
                 _selectedDay = selectedDay;
                 _focusedDay = focusedDay;
               });
              }
            }),
      ],
    );
  }

  //List<Assignment>getEventsForDay(day)

  Future addAssignment() async
  {
    final newAssignment = await Navigator.pushNamed(context, '/addAssn');
    String data = newAssignment.toString();
    List subData = data.split(",");
    Assignment assignment = Assignment(title: subData[0], dueDate: DateTime.parse(subData[1]), doTime: DateTime.parse(subData[2]), account: "default");
    assignment.id = _lastInsertedID;
    _lastInsertedID = await _model.insertAssn(assignment) + 1;
    print("New ID to insert at: $_lastInsertedID");
    getAssignments();

  }

  Future getAssignments() async
  {
    List<Assignment> myAssignments = await _model.getAllAssignments();
    setState(() {
      assignments = myAssignments;
    });
    print(assignments);
  }

  void initState()
  {
    getAssignments(); //get assignments
    int? maxID = 0;
    for (int i = 0; i < assignments.length; i++)
      {
        if (assignments[i].id! > maxID!)
          {
            maxID = assignments[i].id;
          }
      }
    _lastInsertedID = maxID! + 1;
    print(_lastInsertedID);
    super.initState();
  }

  /*
  Future getAssignments() async
  {
    print("Getting all assignments");
    return await FirebaseFirestore.instance.collection('assignments').get();
  }
  */

  /*
  Widget _createAssignment(BuildContext context, DocumentSnapshot assignmentData) //not an async snapshot, here we have the data already
  {
    final assignment = Assignment.fromMap(assignmentData.data(), refid: assignmentData.reference);
    return ListTile(
      title: Text(assignment.title!),
      subtitle: Text(assignment.dueDate.toString()!),
      trailing: Text(assignment.doTime.toString()!),

      //assignment.refid.delete() wrap this in a setstate to delete something
    );
  }
  */

}
