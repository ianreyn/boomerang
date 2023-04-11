import 'dart:collection';
import 'dart:math';
//Sources: https://pub.dev/packages/table_calendar
//https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart

import 'package:boomerang_app/SwipeBox.dart';
import 'package:boomerang_app/assignment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AssignmentList extends StatefulWidget {
  AssignmentList({Key? key, this.title}) : super(key: key);

  String? title;

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {

  late Map<String, dynamic> routeInfo;
  late Map<DateTime, List<Assignment>> _events = {};
  List<Assignment> assignments = [];
  List<Assignment> assignmentsToday = [];
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
        TableCalendar<Assignment>(
          eventLoader: getEventsOfDay,
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
                 assignmentsToday = getEventsOfDay(_selectedDay!);
               });
              }
            }),
        Container(
          height: 200,
          child: ListView(
            children:
              assignmentsToday.map((assignment) => SwipeBox(
                    assignment: assignment,
                getAllAssignments: getAssignments, query: routeInfo['query'],
                  )
              ).toList(),
          ),
        )
      ],
    );
  }
  List<Assignment> getEventsOfDay(DateTime day)
  {
    DateTime adjustedDay = DateTime(day.year, day.month, day.day);
    if (_events[adjustedDay] == null)
      {
        //print("Events for $adjustedDay are null");
        return [];
      }
    //print(_events[adjustedDay]);
    return _events[adjustedDay]!;
  }

  //List<Assignment>getEventsForDay(day)


  Future addAssignment() async
  {
    final newAssignment = await Navigator.pushNamed(context, '/addAssn');
    String data = newAssignment.toString();
    List subData = data.split(",");
    Assignment assignment = Assignment(title: subData[0], dueDate: DateTime.parse(subData[1]), doTime: DateTime.parse(subData[2]), length: double.parse(subData[3]), classId: subData[4]);
    print(assignment);
    QuerySnapshot query = routeInfo['query'];
    DocumentSnapshot studentDoc = query.docs[0];
    Map<String, dynamic> assignmentData = assignment.toMap();
    await studentDoc.reference.collection('assignments').add(assignmentData);
    getAssignments();

  }

  Future getAssignments() async
  {
    //_events.clear(); //clear all assignments
    QuerySnapshot query = routeInfo['query'];
    DocumentSnapshot studentDoc = query.docs[0];
    CollectionReference assignmentsRef = studentDoc.reference.collection('assignments');
    QuerySnapshot assignmentsQuery = await assignmentsRef.get();
    List<Assignment> assignmentsList = assignmentsQuery.docs.map((doc) => Assignment.fromMap(doc.data() as Map<String, dynamic>)).toList();
    assignments = assignmentsList;
    Map<DateTime, List<Assignment>> newAssignments = assignments.fold({}, (Map<DateTime, List<Assignment>> map, Assignment assignment) {
      DateTime dueDate = DateTime(assignment.dueDate!.year, assignment.dueDate!.month, assignment.dueDate!.day);
      // if the map already contains a list of assignments for the due date, add the new assignment to it
      if (map.containsKey(dueDate)) {
        map[dueDate]?.add(assignment);
      }
      // otherwise, create a new list with the assignment and add it to the map
      else {
        map[dueDate] = [assignment];
      }

      return map;
    });

    setState(() {
      _events = newAssignments;
    });
    print(assignments);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // retrieve assignments from the database when the dependencies change
    routeInfo = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    getAssignments();
  }

  @override
  void initState()
  {
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
