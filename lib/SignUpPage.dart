import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart';
import 'LoginPage.dart';

class SignUp extends StatefulWidget {
  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final IDController = TextEditingController();
  final contactController = TextEditingController();
  String? selectedValue;
  final confirmController = TextEditingController();

  final databaseRef = FirebaseDatabase.instance.ref('Users');
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    IDController.dispose();
    contactController.dispose();
    confirmController.dispose();
    super.dispose();
  }


  String? validateFields() {

    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        IDController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        selectedValue == null) {
      return "Please fill in all fields";
    }

    if (passwordController.text != confirmController.text) {
      return "Passwords do not match";
    }

    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters long";
    }

    if (!emailController.text.contains('@')) {
      return "Please enter a valid email address";
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)) {
      return "Please enter a valid email format";
    }

    if (!RegExp(r'^0[0-9]{10}$').hasMatch(contactController.text)) {
      return "Please enter a valid 11-digit contact number starting with 0";
    }


    // Checking if first name only contains alphabetic characters
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(firstNameController.text.trim())) {
      return "First name should only contain alphabetic characters";
    }

    // Checking if last name only contains alphabetic characters
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(lastNameController.text.trim())) {
      return "Last name should only contain alphabetic characters";
    }


    return null;
  }


  // Register
  Future<void> register() async {
    if (isLoading) return;

    String? validationError = validateFields();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userID = userCredential.user!.uid;

      // Create user data
      Map<String, dynamic> userData = {
        'userID': userID,
        'email': emailController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'category': selectedValue,
        'Id': IDController.text.trim(),
        'contactNumber': contactController.text.trim(),
        'createdAt': ServerValue.timestamp,
      };

      // Save user data
      await databaseRef.child(userID).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully!")),
      );

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: Text(
          "Cafe\nCUI",
          textAlign: TextAlign.center,
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        toolbarHeight: 100.0,
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "CREATE AN ACCOUNT",
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: const TextStyle(color: Colors.black),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: const TextStyle(color: Colors.black),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Category",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Student', 'Employee']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: IDController,
                  decoration: InputDecoration(
                    labelText: "ID",
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    )
                        : Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
