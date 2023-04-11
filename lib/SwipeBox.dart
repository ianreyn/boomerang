import 'package:boomerang_app/assignment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SwipeBox extends StatefulWidget {
  const SwipeBox({Key? key, this.assignment, this.getAllAssignments, this.query}) : super(key: key);

  final Assignment? assignment;
  final AssignmentCallback? getAllAssignments;
  final QuerySnapshot? query;

  @override
  State<SwipeBox> createState() => _SwipeBoxState();
}

class _SwipeBoxState extends State<SwipeBox> {
  bool showButtons = false;
  late double dragStart;
  late double dragEnd;

  @override
  build(BuildContext context) {
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.all(showButtons ? 16: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.pinkAccent,
                  width: 3
                ),
              ),
              onEnd: toggleButtons,
              child: GestureDetector(
                onHorizontalDragUpdate: (drag) {
                  dragEnd = drag.localPosition.dx;
                  if (dragEnd < dragStart -20)
                    {
                      toggleButtons();
                    }
                },
                onHorizontalDragStart: (drag) {
                  dragStart = drag.localPosition.dx;
                },
                onHorizontalDragEnd: (drag) {
                  dragStart = 0.0;
                  dragEnd = 0.0;
                  if (!showButtons)
                    {
                      toggleButtons();
                    }
                },
                child: Row(
                  children: [
                    Expanded(
                        child: ListTile(
                          title: Text(widget.assignment!.title!),
                          subtitle: Text("Do at this time: ${DateFormat.yMMMEd().format(widget.assignment!.doTime!)}"),
                        )
                    ),
                    if (showButtons)
                        SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  onPressed: deleteItem,
                                  icon: const Icon(Icons.check_box_outlined)
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await updateItem(context);
                                  },
                                  icon: const Icon(Icons.more_vert))
                            ],
                          ),
                        )
                  ],
                ),
              ),
            ),
    );
  }

  void toggleButtons()
  {
    setState(() {
      //switch whether or not we can see the buttons
      showButtons = !showButtons;
    });
  }

   deleteItem() async
   {
    bool delete = await showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text("Have you finished this assignment?"),
            content: Row(
              children: [
                TextButton(
                    onPressed: () {Navigator.pop(context, true);},
                    child: const Text("All done!", style: TextStyle(color: Colors.green),)
                ),
                TextButton(
                    onPressed: () {Navigator.pop(context, false);},
                    child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)))
              ],
            ),
          );
        },
    );
    if (delete)
      {
        DocumentSnapshot studentDoc = widget.query!.docs[0];
        QuerySnapshot assignmentSnapshot = await studentDoc.reference.collection('assignments')
            .where('title', isEqualTo: widget.assignment!.title).where('classId', isEqualTo: widget.assignment!.classId).get();
        String assignmentToBeDeleted = assignmentSnapshot.docs[0].id;
        DocumentReference assignmentReference = studentDoc.reference.collection('assignments').doc(assignmentToBeDeleted);
        await assignmentReference.delete();
        setState(() {
          widget.getAllAssignments!();
        });
      }
  }


  Future updateItem(BuildContext context) async
  {
    final newAssignment = await Navigator.pushNamed(context, '/addAssn');
    String data = newAssignment.toString();
    List subData = data.split(",");
    Assignment assignment = Assignment(title: subData[0], dueDate: DateTime.parse(subData[1]), doTime: DateTime.parse(subData[2]), length: double.parse(subData[3]), classId: subData[4]);
    Map<String, dynamic> assignmentData = assignment.toMap();

    DocumentSnapshot studentDoc = widget.query!.docs[0];
    QuerySnapshot assignmentSnapshot = await studentDoc.reference.collection('assignments')
        .where('title', isEqualTo: widget.assignment!.title).where('classId', isEqualTo: widget.assignment!.classId).get();
    String assignmentToBeUpdated = assignmentSnapshot.docs[0].id;
    CollectionReference assignmentCollection = studentDoc.reference.collection('assignments');
    DocumentReference assignmentDoc = assignmentCollection.doc(assignmentToBeUpdated);

    setState(() {
      //int updatedID = await model.updateAssn(assignment);
      assignmentDoc.update(assignmentData);
      widget.getAllAssignments!();
    });
  }
}

typedef AssignmentCallback = void Function();
