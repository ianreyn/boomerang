import 'package:boomerang_app/assignment.dart';
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
                    labelText: "Do on this date"
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
                      Navigator.pop(context, "${titleController.text},${dueController.text},${doController.text},${lengthController.text},${classController.text}");
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

}
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}