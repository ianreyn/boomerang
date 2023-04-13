import 'package:boomerang_app/settingsclass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key, this.title}) : super(key: key);

  final String? title;
  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late Map<String, dynamic> routeInfo;
  var formKey = GlobalKey();
  TextEditingController monController = TextEditingController();
  TextEditingController tuesController = TextEditingController();
  TextEditingController wedController = TextEditingController();
  TextEditingController thursController = TextEditingController();
  TextEditingController friController = TextEditingController();
  TextEditingController satController = TextEditingController();
  TextEditingController sunController = TextEditingController();
  late String allowFinished = "YesFinished";
  late String allowPlanned = "NoPlanned";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!),
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
                      controller: monController,
                      decoration: InputDecoration(
                          labelText: "Hours available on Monday"
                      ),
                    ),
                    TextField(
                      controller: tuesController,
                      decoration: InputDecoration(
                          labelText: "Hours available on Tuesday"
                      ),
                    ),
                    TextField(
                      controller: wedController,
                      decoration: InputDecoration(
                          labelText: "Hours available on Wednesday"
                      ),
                    ),
                TextField(
                  controller: thursController,
                  decoration: InputDecoration(
                      labelText: "Hours available on Thursday"
                  ),
                ),
                TextField(
                  controller: friController,
                  decoration: InputDecoration(
                      labelText: "Hours available on Friday"
                  ),
                ),
                TextField(
                  controller: satController,
                  decoration: InputDecoration(
                      labelText: "Hours available on Saturday"
                  ),
                ),
                TextField(
                  controller: sunController,
                  decoration: InputDecoration(
                      labelText: "Hours available on Sunday"
                  ),
                ),
                ListTile(
                  title: Text("Do you want your teacher to see planned assignments?"),
                  subtitle: DropdownButtonFormField(
                    //value: allowPlanned,
                    onChanged: (newValue) {
                      setState(() {
                        allowPlanned = newValue!;
                      });
                    },
                    onSaved: (newValue) {
                      allowPlanned = newValue!;
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'YesPlanned',
                        child: Text('Yes, show plans'),
                      ),
                      DropdownMenuItem(
                        value: 'NoPlanned',
                        child: Text('No, do not show plans'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Do you want your teacher to see finished assignments?"),
                  subtitle: DropdownButtonFormField(
                    //value: allowFinished,
                    onChanged: (newValue) {
                      setState(() {
                        allowFinished = newValue!;
                      });
                    },
                    onSaved: (newValue) {
                      allowFinished = newValue!;
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'YesFinished',
                        child: Text('Yes, show finished'),
                      ),
                      DropdownMenuItem(
                        value: 'NoFinished',
                        child: Text('No, do not show finished'),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      print(allowPlanned);
                      print(allowFinished);
                      //Assignment newAssignment = Assignment(title: titleController.text, dueDate: DateTime.parse(dueController.text), doTime: DateTime.parse(doController.text), account: "default");
                      Navigator.pop(context, "${monController.text},${tuesController.text},${wedController.text},${thursController.text},${friController.text},${satController.text},${sunController.text},$allowPlanned,$allowFinished");
                    },
                    child: Text("Apply"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getSettings(DocumentSnapshot studentDoc) async
  {
    CollectionReference settingsRef = studentDoc.reference.collection('settings');
    QuerySnapshot settingsSnapQuery = await settingsRef.get();
    DocumentSnapshot settingsSnap = settingsSnapQuery.docs.first;
    Map<String, dynamic> settingsData = settingsSnap.data() as Map<String, dynamic>;
    SettingsObj settings = SettingsObj.fromMap(settingsData);
    monController.text = settings.maxMon.toString();
    tuesController.text = settings.maxTues.toString();
    wedController.text = settings.maxWed.toString();
    thursController.text = settings.maxThurs.toString();
    friController.text = settings.maxFri.toString();
    satController.text = settings.maxSat.toString();
    sunController.text = settings.maxSun.toString();
    allowFinished = settings.showFinished! ? "Yes" : "No";
    allowPlanned = settings.showPlanned! ? "Yes" : "No";

  }
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic> routeInfo = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    dynamic queryValue = routeInfo['query'];
    QuerySnapshot<Object> query = queryValue as QuerySnapshot<Object>; // Cast queryValue to QuerySnapshot
    DocumentSnapshot studentDoc = query.docs[0];
    getSettings(studentDoc);
  }

  @override
  void initState()
  {
    super.initState();

  }
}
