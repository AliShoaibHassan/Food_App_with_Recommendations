// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:google_fonts/google_fonts.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Recommendations',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: recommendation(),
//     );
//   }
// }
//
// class recommendation extends StatefulWidget {
//   recommendationState createState() => recommendationState();
// }
//
// class recommendationState extends State<recommendation> {
//   final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
//   String userName = "";
//   String email = "";
//   String contact = "";
//   late Query listRef; // Query for FirebaseAnimatedList
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the listRef query and fetch user data
//     listRef = dbRef.child('/recommendations');
//
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.indigo,
//         appBar: AppBar(
//         title: Text("Profile"),
//     ),
//     body: Column(
//     children: [
//
//
//       ])
//     }
//
// }