import 'package:boomerang_app/assignment_form.dart';
import 'package:boomerang_app/assignment_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            {
              print("Error connecting to Firebase");
              }
          if (snapshot.connectionState == ConnectionState.done) { //success!
            print("Firebase connection complete");
            return MaterialApp(
              title: "Boomerang",
              theme: ThemeData(
                primarySwatch: Colors.pink,
              ),
              home: LoginPage(),
              routes: {
                '/calendar': (context) => AssignmentList(title: 'Calendar'),
                '/addAssn': (context) => AssignmentForm(title: "Add an Assignment")
              },
            );
         }
          else
          {
            return const CircularProgressIndicator();
          }
        }
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);

  String? title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fireBaseInstance = FirebaseFirestore.instance.collection('accounts');
  final formKey = GlobalKey<FormState>();
  String? username = "";
  String? password = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Boomerang",
            style: TextStyle(
              fontSize: 25,
              color: Colors.pink
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Username",
              label: Text("Username"),
            ),
            onChanged: (value)
            {
              username = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Password",
              label: Text("Password"),
            ),
            obscureText: true,
            onChanged: (value)
            {
              password = value;
            },
          ),
          ElevatedButton(
              onPressed: () {
                goToCalendar(username, password);
              },
              child: const Text(
                "Log In",
                style: TextStyle(
                  fontSize: 15,
                ),
              )
          ),
        ],
      ),
    );
  }
  Future<void> goToCalendar(username, password) async
  { //TODO: Check if username and password are correct
    var loginStatus = await Navigator.pushNamed(context, r'/calendar',
        arguments: {'userName': username});
  }
}

