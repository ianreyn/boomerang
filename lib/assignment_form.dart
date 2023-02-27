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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Form(
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
                focusNode: AlwaysDisabledFocusNode(),
                onTap: () {
                  selectDate(context, dueController);
                },
              ),
              TextField(
                controller: doController,
                focusNode: AlwaysDisabledFocusNode(),
                onTap: () {
                  selectDate(context, doController);
                },
              ),
              IconButton(
                  onPressed: () {
                    //Assignment newAssignment = Assignment(title: titleController.text, dueDate: DateTime.parse(dueController.text), doTime: DateTime.parse(doController.text), account: "default");
                    Navigator.pop(context, "${titleController.text},${dueController.text},${dueController.text}");
                  },
                  icon: Icon(Icons.save))
            ],
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