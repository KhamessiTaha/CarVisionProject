import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'admin.dart';
import 'signup.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  String? _errorMessage;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    // Clear previous error messages
    setState(() {
      _isNotValidate = false;
      _errorMessage = null;
    });

    // Check if email and password are not empty
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _isNotValidate = true;
      });
      return;
    }

    // Proceed with login
    if (prefs == null) {
      await initializeSharedPreferences();
    }

    if (prefs != null) {
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text
      };
      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("jsonResponse");
        if (jsonResponse['status']) {
          var myToken = jsonResponse['token'];
          prefs!.setString('token', myToken);

          // Decode token payload
          List<String> tokenParts = myToken.split('.');
          String decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1])));
          Map<String, dynamic> decodedToken = jsonDecode(decodedPayload);

          if (decodedToken['isAdmin']) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage(token: myToken, currentIndex: 0, onTap: (index) {})),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ThePage(token: myToken, currentIndex: 0, onTap: (index) {})),
            );
          }
        } else {
          setState(() {
            _errorMessage = "Login error, check your inputs"; // Display generic login error message
          });
        }
      } else {
        setState(() {
          _errorMessage = "Login error, check your inputs"; // Display generic login error message
        });
      }
    } else {
      print('SharedPreferences initialization failed.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(30, 30, 30, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color.fromRGBO(30, 30, 30, 1)),
        ),
      ),
      body: Center( // Center widget added
        child: Padding( // Padding added
          padding: const EdgeInsets.only(top: 100), // Adjust padding as needed
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Column(
                        children: <Widget>[
                          Text("Login", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 20),
                          Text("Login to your account", style: TextStyle(fontSize: 15, color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: inputFile(label: "Email", controller: emailController, errorMessage: _isNotValidate && emailController.text.isEmpty ? "Email cannot be empty" : null),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: inputFile(label: "Password", obscureText: true, controller: passwordController, errorMessage: _isNotValidate && passwordController.text.isEmpty ? "Password cannot be empty" : null)
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          padding: const EdgeInsets.only(top: 3, left: 3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: const Border(
                                bottom: BorderSide(color: Color.fromRGBO(30, 30, 30, 1)),
                                top: BorderSide(color: Color.fromRGBO(30, 30, 30, 1)),
                                left: BorderSide(color: Color.fromRGBO(30, 30, 30, 1)),
                                right: BorderSide(color: Color.fromRGBO(30, 30, 30, 1)),
                              )),
                          child: MaterialButton(
                            minWidth: double.infinity,
                            height: 60,
                            onPressed: loginUser,
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color.fromRGBO(30, 30, 30, 1)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _errorMessage ?? '', // Display error message if available, otherwise display an empty string
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the signup page here
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => const SignupPage()));
                            },
                            child: const Text(
                              " Sign up",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 200,
                        decoration: const BoxDecoration(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for text field
Widget inputFile({label, obscureText = false, required TextEditingController controller, String? errorMessage}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color.fromRGBO(30, 30, 30, 1)), // Set text color to white
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(50), // Adjust border radius here
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Set border color to white
            borderRadius: BorderRadius.all(
              Radius.circular(50), // Adjust border radius here
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(50), // Adjust border radius here
            ),
          ),
          errorText: errorMessage,
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
