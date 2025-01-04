import 'package:final_project/changePassword.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'LoginPage.dart';
import 'MenuPage.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cafe CUI',
//       theme: ThemeData(primarySwatch: Colors.pink),
//       home: UserDetailsScreen(),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userDetails;
  List<dynamic> orderHistory = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Fetch user details
      final userSnapshot = await _database.child('Users/$userId').get();
      if (userSnapshot.exists) {
        setState(() {
          userDetails = Map<String, dynamic>.from(userSnapshot.value as Map);
        });
      }

      // Fetch order history
      final ordersSnapshot = await _database.child('orders/$userId').get();
      if (ordersSnapshot.exists) {
        final ordersData = Map<String, dynamic>.from(ordersSnapshot.value as Map);
        List<dynamic> orders = [];

        ordersData.forEach((orderId, orderDetails) {
          final orderInfo = Map<String, dynamic>.from(orderDetails);
          orders.add(orderInfo);
        });

        setState(() {
          orderHistory = orders;
        });
      }
    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Account Management',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: userDetails == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                        AssetImage('assets/images/userId1.png'),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Details',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Name: ${userDetails?['firstName']} ${userDetails?['lastName']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'Email: ${userDetails?['email']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'University ID: ${userDetails?['Id']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'Category: ${userDetails?['category']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'Contact Number: ${userDetails?['contactNumber']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Order History Section
                Text(
                  'Order History',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderHistory.length,
                  itemBuilder: (context, index) {
                    final order = orderHistory[index];
                    final items = order['items'] as List<dynamic>?;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: ${order['orderId']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Amount: Rs. ${order['totalAmount']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Food Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (items != null)
                              ...items.map((item) {
                                final itemName = item['name'];
                                final itemQuantity = item['quantity'];
                                final itemPrice = item['price'];
                                return Text(
                                  '• $itemName (x$itemQuantity) - Rs. $itemPrice',
                                  style: TextStyle(fontSize: 14),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 200, // Set the desired width here
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PasswordResetPage()),
                            );
                          },
                          child: Text('Change Password'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 40), // Set height
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 200, // Set the desired width here
                        child: ElevatedButton(
                          onPressed: () async {
                            await _auth.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login()),
                            );
                          },
                          child: Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 40), // Set height
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserDetailsScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }
          else if(index==2){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Person',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
