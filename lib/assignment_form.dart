import 'package:boomerang_app/assignment.dart';
import 'package:boomerang_app/settingsclass.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Source: https://stackoverflow.com/questions/62528177/how-to-get-flutter-datepicker-value-to-the-textfield

class AssignmentForm extends StatefulWidget {
  final String? title;
  const AssignmentForm({Key? key, this.title}) : super(key: key);

  @override
  State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  late SettingsObj settings;
  late Map<DateTime, List<Assignment>> assignments;
  var formKey = GlobalKey();
  DateTime _selectedDay = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController dueController = TextEditingController();
  TextEditingController doController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController numSessionsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Assignment Title"
                  ),
                ),
                TextField(
                  controller: dueController,
                  decoration: InputDecoration(
                    labelText: "Due Date"
                  ),
                  focusNode: AlwaysDisabledFocusNode(),
                  onTap: () {
                    selectDate(context, dueController);
                  },
                ),
                TextField(
                  controller: doController,
                  decoration: InputDecoration(
                    labelText: "Start on this date"
                  ),
                  focusNode: AlwaysDisabledFocusNode(),
                  onTap: () {
                    selectDate(context, doController);
                  },
                ),
                TextField(
                  controller: lengthController,
                  decoration: InputDecoration(
                      labelText: "How many hours do you think you'll take?"
                  ),
                ),
                TextField(
                  controller: classController,
                  decoration: InputDecoration(
                      labelText: "Enter the class code for this assignment"
                  ),
                ),
                TextField(
                  controller: numSessionsController,
                  decoration: InputDecoration(
                      labelText: "Split the work on how many sessions?"
                  ),
                ),
                IconButton(
                    onPressed: () {
                      //Assignment newAssignment = Assignment(title: titleController.text, dueDate: DateTime.parse(dueController.text), doTime: DateTime.parse(doController.text), account: "default");
                      //Navigator.pop(context, "${titleController.text},${dueController.text},${doController.text},${lengthController.text},${classController.text}");
                      bestFit(titleController.text, dueController.text, doController.text, lengthController.text, classController.text, numSessionsController.text);
                    },
                    icon: Icon(Icons.save))
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectDate(BuildContext context, TextEditingController controller) async
  {
    DateTime? newDate = await showDatePicker(
        context: context, 
        initialDate: _selectedDay ?? DateTime.now(),
        firstDate: DateTime.utc(2020), 
        lastDate: DateTime.utc(2040)
    );

    if (newDate != null)
      {
        _selectedDay = newDate;
        controller.text = DateFormat('yyyy-MM-dd').format(_selectedDay);
      }
  }

  bestFit(String title, String dueDate, String doTime, String length, String classID, String numSessions) async
  {
    List<double> avail = [settings.maxMon!, settings.maxTues!, settings.maxWed!, settings.maxThurs!, settings.maxFri!, settings.maxSat!, settings.maxSun!];
    double totalLength = double.parse(length);
    int numberSessions = int.parse(numSessions);
    //If they don't want more than one session
    if (numberSessions <= 1)
      {
        DateTime attemptDate = DateTime.parse(doTime);
        double lengthOfDay = 0.0;
        if (assignments[attemptDate] != null) {
          for (int i = 0; i < assignments[attemptDate]!.length; i++) {
            lengthOfDay += assignments[attemptDate]![i].length!;
          }
        }
        if (totalLength + lengthOfDay > avail[attemptDate.weekday-1])
          {
            //Warning box
            bool confirm = await showDialog(
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: Text("This will overload your day! Are you sure?"),
                    content: Row(
                      children: [
                        TextButton(
                            onPressed: () {Navigator.pop(context, true);},
                            child: const Text("Yes", style: TextStyle(color: Colors.green),)
                        ),
                        TextButton(
                            onPressed: () {Navigator.pop(context, false);},
                            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)))
                      ],
                    ),
                  );
                });
            if (confirm)
              {
                Navigator.pop(context, "$title,$dueDate,$doTime,$length,$classID");
              }
          }
        else //Not overtime
          {
            Navigator.pop(context, "$title,$dueDate,$doTime,$length,$classID");
          }

      }
    else //Number of sessions is 2 or more
      {
        List<DateTime> availableDays = [];
        DateTime due = DateTime.parse(dueDate);
        double sessionLength = totalLength / numberSessions;
        DateTime startDate = DateTime.parse(doTime);
        int dayRange = due.difference(startDate).inDays;
        int skipBy = (dayRange/numberSessions).floor(); //skip rate when adding assignments
        for (int i = 0; i < numberSessions; i++)
          {
            double lengthOfDay = 0.0;
            DateTime attemptDate = startDate.add(Duration(days: i*skipBy));
            if (assignments[attemptDate] != null)
              {
                for (int j = 0; j < assignments[attemptDate]!.length; j++)
                  {
                    lengthOfDay += assignments[attemptDate]![j].length!;
                  }
              }
            if (lengthOfDay + sessionLength > avail[attemptDate.weekday-1]) //Look for next day
              {
                bool foundDay = false;
                DateTime newDateCrawl = attemptDate;
                double lengthOfDateCrawl;
                while (!foundDay) //keep looking for the next day open
                  {
                    newDateCrawl = newDateCrawl.add(const Duration(days: 1)); //check the next day
                    lengthOfDateCrawl = 0.0;
                    if (assignments[newDateCrawl] != null)
                    { //add the length of all existing assignments
                      for (int k = 0; k < assignments[newDateCrawl]!.length; k++)
                      {
                        lengthOfDateCrawl += assignments[newDateCrawl]![k].length!;
                      }
                    }
                    if (lengthOfDateCrawl + sessionLength < avail[newDateCrawl.weekday-1])
                      {//found one
                        foundDay = true;
                      }
                  }
                  availableDays.add(newDateCrawl);
              }
            else //There's room on the current date being looked at
              {
                availableDays.add(attemptDate);
              }
          }
        //Return numberSessions amount of assignments
        String returnString = "";
      for (int i = 0; i < availableDays.length; i++)
        {
          returnString += "$title work period ${i+1},$dueDate,${availableDays[i]},$sessionLength,$classID,";
        }
      Navigator.pop(context, returnString);
      }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // retrieve assignments from the database when the dependencies change
    Map<String, dynamic> routeInfo = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    settings = routeInfo['settings'];
    assignments = routeInfo['assignments'];
  }

  @override
  void initState()
  {
    super.initState();
  }

}
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}