import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage();

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>(); // Declare form key

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isNotValidate = false;

  void registerUser() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      // If form is valid, proceed with registration
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          usernameController.text.isNotEmpty) {
        var regBody = {
          "username": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text
        };

        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          } else {
            // Check server response for specific error messages
            if (jsonResponse['error'] != null) {
              // Handle specific error
              print(jsonResponse['error']);
            } else {
              // Handle generic error
              print("Something Went Wrong");
            }
          }
        } else {
          // Handle HTTP error
          print("HTTP Error: ${response.statusCode}");
        }
      } else {
        setState(() {
          _isNotValidate = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Assign form key
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Column(
                  children: <Widget>[
                    Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    inputFile(
                      label: "Username",
                      controller: usernameController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    inputFile(
                      label: "Email",
                      controller: emailController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!isValidEmail(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    inputFile(
                      label: "Password",
                      obscureText: true,
                      controller: passwordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        // You can add more password validation logic here
                        return null;
                      },
                    ),
                    inputFile(
                      label: "Confirm Password",
                      obscureText: true,
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: registerUser, // Call the registerUser function here
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the signup page here
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// We will be creating a widget for text field
Widget inputFile({label, obscureText = false, required TextEditingController controller, String? Function(String?)? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black), // Set text color to black
        validator: validator, // Add validator function
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(50), // Set border radius
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white), // Set border color to white
            borderRadius: BorderRadius.circular(50), // Set border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(50), // Set border radius
          ),
          errorStyle: TextStyle(color: Colors.red), // Set validation message color to red
        ),
      ),

      const SizedBox(height: 10),
    ],
  );
}

// Function to validate email format
bool isValidEmail(String email) {
  // Email regex pattern
  String emailPattern =
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  RegExp regExp = RegExp(emailPattern);
  return regExp.hasMatch(email);
}
