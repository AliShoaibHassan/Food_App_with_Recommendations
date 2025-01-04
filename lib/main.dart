// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'firebase_options.dart';
// import 'package:google_fonts/google_fonts.dart';
//
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Cafe CUI',
// //       theme: ThemeData(primarySwatch: Colors.pink),
// //       home: UserDetailsScreen(),
// //     );
// //   }
// // }
//
// class UserDetailsScreen extends StatefulWidget {
//   @override
//   _UserDetailsScreenState createState() => _UserDetailsScreenState();
// }
//
// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   Map<String, dynamic>? userDetails;
//   List<dynamic> orderHistory = [];
//   int _currentIndex = 0;
//   String userId = "userId1";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails(userId);
//     _fetchOrderHistory(userId);
//
//   }
//
//   void _fetchUserDetails(String userId) async {
//     final snapshot = await _database.child('users/$userId').get();
//     if (snapshot.exists) {
//       setState(() {
//         userDetails = Map<String, dynamic>.from(snapshot.value as Map);
//       });
//     }
//   }
//
//   void _fetchOrderHistory(String userId) async {
//     final snapshot = await _database.child('orders/$userId').get();
//     if (snapshot.exists) {
//       setState(() {
//         orderHistory = List<dynamic>.from(snapshot.value as List);
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo,
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade700,
//         title: Text(
//           'Account Management',
//           style: GoogleFonts.roboto(
//             textStyle: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: userDetails == null
//             ? Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 SizedBox(height: 20),
//                 // Profile Section with Avatar and User Details
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                      Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: CircleAvatar(
//                         radius: 50.0,
//                         backgroundImage: AssetImage('assets/images/$userId.png'),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'User Details',
//                               style: GoogleFonts.roboto(
//                                 textStyle: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Name: ${userDetails?['name']}',
//                               style: TextStyle(color: Colors.white, fontSize: 18),
//                             ),
//                             Text(
//                               'Email: ${userDetails?['email']}',
//                               style: TextStyle(color: Colors.white, fontSize: 18),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//
//                 // Order History Section
//                 Text(
//                   'Order History',
//                   style: GoogleFonts.roboto(
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: orderHistory.length,
//                   itemBuilder: (context, index) {
//                     final order = orderHistory[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8.0),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             RichText(
//                               text: TextSpan(
//                                 children: [
//                                   TextSpan(text: 'Order ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                                   TextSpan(text: '${order['id']}'),
//                                 ],
//                               ),
//                             ),
//                             RichText(
//                               text: TextSpan(
//                                 children: [
//                                   TextSpan(text: 'Amount: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                                   TextSpan(text: '\Rs. ${order['amount']}'),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text('Food Items:', style: TextStyle(fontWeight: FontWeight.bold)),
//                             for (var food in order['Food'])
//                               Text('• $food'),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//
//                 SizedBox(height: 20),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: SizedBox(
//                         width: 200, // Set the desired width here
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           child: Text('Change Password'),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(200, 40), // Set the height if needed
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: SizedBox(
//                         width: 200, // Set the desired width here
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           child: Text('Log Out'),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(200, 40), // Set the height if needed
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Person',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//         ],
//       ),
//     );
//   }
// }



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
//       title: 'My Account',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Login(),
//     );
//   }
// }
//
// class Login extends StatefulWidget {
//   LoginState createState() => LoginState();
// }
//
// class LoginState extends State<Login> {
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
//     listRef = dbRef.child('/orders/userId1');
//     fetchUserData();
//   }
//
//   void fetchUserData() async {
//     final snapshot = await dbRef.get();
//     if (snapshot.exists) {
//       setState(() {
//         userName = snapshot.child('/users/userId1/name').value?.toString() ?? 'No name';
//         email = snapshot.child('/users/userId1/email').value?.toString() ?? 'No email';
//         contact = snapshot.child('/users/userId1/contact').value?.toString() ?? 'No contact';
//       });
//     } else {
//       print("Error: Data does not exist for this path.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo,
//       appBar: AppBar(
//         title: Text("Profile"),
//       ),
//       body: Column(
//         children: [
//
//           Row(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: CircleAvatar(
//                   radius: 50.0,
//                   backgroundImage: AssetImage('assets/images/userId1.png'),
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Text(
//                         userName.isEmpty ? 'Loading...' : userName,
//                         style: GoogleFonts.roboto(
//                           textStyle: TextStyle(
//                             color: Colors.indigo.shade50,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Text(
//                         email.isEmpty ? 'Loading...' : email,
//                         style: GoogleFonts.roboto(
//                           textStyle: TextStyle(
//                             color: Colors.indigo.shade50,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Text(
//                         contact.isEmpty ? 'Loading...' : contact,
//                         style: GoogleFonts.roboto(
//                           textStyle: TextStyle(
//                             color: Colors.indigo.shade50,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: FirebaseAnimatedList(
//               query: listRef,
//               itemBuilder: (context, snapshot, animation, index) {
//                 final Map<String, dynamic> order =
//                 Map<String, dynamic>.from(snapshot.value as Map);
//                 return ListTile(
//                   tileColor: Colors.white,
//                   title: Text(order['id'] ?? 'No ID'),
//                   subtitle: Text(
//                       "Amount: ${order['amount']}\nFood: ${order['Food']?.join(', ') ?? 'No Food Items'}"),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 10.0, top: 50.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 // Add Change Password logic here
//               },
//               child: Text(
//                 'Change Password',
//                 style: GoogleFonts.roboto(
//                   textStyle: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 10.0, top: 50.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 // Add Log Out logic here
//               },
//               child: Text(
//                 'Log Out',
//                 style: GoogleFonts.roboto(
//                   textStyle: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
