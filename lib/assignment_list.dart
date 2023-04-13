import 'dart:collection';
import 'dart:math';
//Sources: https://pub.dev/packages/table_calendar
//https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart

import 'package:boomerang_app/SwipeBox.dart';
import 'package:boomerang_app/assignment.dart';
import 'package:boomerang_app/settingsclass.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'event_marker.dart';

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
  //This map is extremely important for the mapping of the colours of the dots
  static Map<String, Color> colourMap =
  {
    'PHY4910U': Color(0xFF498fde),
    'CSCI3310U': Color(0xFFcf539b),
    'CSCI4201U': Color(0xFF8749de),
    'Thesis': Color(0xFFed3e4c)
  };
  //refer back to https://pub.dev/documentation/table_calendar/latest/table_calendar/MarkerBuilder.html
  MarkerBuilder<Assignment> markerBuilder = (context, day, assignments) { //Assignments for the day, put em in a list
    List<Widget> markers = [];

    List classIDs = assignments.map((assignment) => assignment.classId).toList();

    //Map the colours
    for (String classID in classIDs) {
      markers.add(
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colourMap[classID] ?? Colors.grey, //if it's null just put grey I guess
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: markers,
    );
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: sendToSettings, icon: Icon(Icons.settings))
        ],
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: markerBuilder
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFFe3b6d4),
                shape: BoxShape.circle
              )
            ),
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

  Future sendToSettings() async
  {
    //print(routeInfo['query'].runtimeType);
    final settings = await Navigator.pushNamed(context, '/settings',
        arguments: {'query': routeInfo['query']});
    String data = settings.toString();
    List subData = data.split(",");
    bool allowPlanned = false;
    bool allowFinished = false;
    if (subData[7] == "YesPlanned")
      {
        allowPlanned = true;
      }
    if (subData[8] == "YesFinished")
      {
        allowFinished = true;
      }
    SettingsObj newSettings = SettingsObj(double.parse(subData[0]), double.parse(subData[1]), double.parse(subData[2]), double.parse(subData[3]), double.parse(subData[4]), double.parse(subData[5]), double.parse(subData[6]), allowFinished, allowPlanned);
    Map<String, dynamic> settingsData = newSettings.toMap();
    print(newSettings);
    QuerySnapshot query = routeInfo['query'];
    DocumentSnapshot studentDoc = query.docs[0];
    CollectionReference settingsRef = studentDoc.reference.collection('settings');
    QuerySnapshot settingsSnapQuery = await settingsRef.get();
    DocumentSnapshot settingsSnap = settingsSnapQuery.docs.first;
    String id = settingsSnap.id;
    DocumentReference settingsDoc = settingsRef.doc(id);

    setState(() {
      settingsDoc.update(settingsData);
    });
  }

  Future addAssignment() async
  {
    //Obtain settings
    QuerySnapshot query = routeInfo['query'];
    DocumentSnapshot studentDoc = query.docs[0];
    CollectionReference settingsRef = studentDoc.reference.collection('settings');
    QuerySnapshot settingsSnapQuery = await settingsRef.get();
    DocumentSnapshot settingsSnap = settingsSnapQuery.docs.first;
    Map<String, dynamic> settingsData = settingsSnap.data() as Map<String, dynamic>;
    SettingsObj settings = SettingsObj.fromMap(settingsData);

    final newAssignment = await Navigator.pushNamed(context, '/addAssn',
        arguments: {'settings': settings, 'assignments': _events});
    String data = newAssignment.toString();
    List subData = data.split(",");
    for (int i = 0; i < subData.length-4; i+= 5)
      {
        Assignment assignment = Assignment(title: subData[i], dueDate: DateTime.parse(subData[i+1]), doTime: DateTime.parse(subData[i+2]), length: double.parse(subData[i+3]), classId: subData[i+4]);
        print(assignment);
        Map<String, dynamic> assignmentData = assignment.toMap();
        await studentDoc.reference.collection('assignments').add(assignmentData);
      }
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
      DateTime doTime = DateTime(assignment.doTime!.year, assignment.doTime!.month, assignment.doTime!.day);
      // if the map already contains a list of assignments for the due date, add the new assignment to it
      if (map.containsKey(doTime)) {
        map[doTime]?.add(assignment);
      }
      // otherwise, create a new list with the assignment and add it to the map
      else {
        map[doTime] = [assignment];
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
