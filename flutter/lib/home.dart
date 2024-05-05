import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'consts.dart';
import 'login.dart';
import 'main.dart';

class ThePage extends StatefulWidget {
  final token;
  final int currentIndex;
  final Function(int) onTap;

  const ThePage({
    Key? key,
    required this.token,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _ThePageState createState() => _ThePageState();
}
class _ThePageState extends State<ThePage> {
  int _currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Background color of the app bar
        elevation: 0, // To remove the shadow below the app bar
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.grey, // Color of the logout icon
            ),
            onPressed: () {
              // Add logout functionality here
              _logout(context); // Call the logout function
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= 0 && _currentIndex < 5 ? _currentIndex : 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        fixedColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message), // New messages icon
            label: 'ChatCar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  void _logout(BuildContext context) async {
    // Clear authentication token from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),);
  }









  Widget _buildBody() {
    if (_currentIndex == -1) {
      return _buildChooseWidgetPage();
    }
    switch (_currentIndex) {
      case 0:
        return UploadWidget(token: widget.token);
      case 1:
        return CameraWidget(token: widget.token);
      case 2:
        return UserWidget(token: widget.token);
      case 3:
        return UserhistWidget(token: widget.token);
      case 4:
        return MessagesWidget();
      default:
        return Container();
    }
  }

  Widget _buildChooseWidgetPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose a Widget',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.upload, size: 48),
                    SizedBox(height: 10),
                    Text('Upload', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.camera, size: 48),
                    SizedBox(height: 10),
                    Text('Camera', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.person, size: 48),
                    SizedBox(height: 10),
                    Text('User', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48),
                    SizedBox(height: 10),
                    Text('History', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 4;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.message, size: 48),
                    SizedBox(height: 10),
                    Text('ChatCar', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Icon(Icons.arrow_downward, size: 48),
        ],
      ),
    );
  }
}



class UploadWidget extends StatelessWidget {
  final String token;

  const UploadWidget({Key? key, required this.token}) : super(key: key);
  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      String userId = await _getUserIdFromToken();
      var response = await http.get(
        Uri.parse('$getuser$userId'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print("User info response: $jsonResponse");
      return jsonResponse;
    } catch (error) {
      print("Error getting user info: $error");
      throw error;
    }
  }

  Future<String> _getUserIdFromToken() async {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    return jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Change the color to red
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        else {
          String userId = snapshot.data?['user']['_id'] ?? ''; // Provide a default value if _id is null
          if (userId.isEmpty) {
            return Text('User ID not available'); // Handle the case where user ID is empty or null
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => _pickImageFromGallery(userId),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
              ),
              child: Text('Upload Picture of Car from Gallery'),
            ),
          );
        }
      },
    );
  }


  Future<void> _pickImageFromGallery(String userId) async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    File selectedImage = File(pickedImage.path);

    // Perform image upload with user ID
    await _uploadImage(selectedImage, userId);
  }

  Future<void> _uploadImage(File image, String userId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(carsave));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['userId'] = userId; // Pass user ID as a field
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

class CameraWidget extends StatelessWidget {
  final String token;

  const CameraWidget({Key? key, required this.token}) : super(key: key);
  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      String userId = await _getUserIdFromToken();
      var response = await http.get(
        Uri.parse('$getuser$userId'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print("User info response: $jsonResponse");
      return jsonResponse;
    } catch (error) {
      print("Error getting user info: $error");
      throw error;
    }
  }

  Future<String> _getUserIdFromToken() async {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    return jwtDecodedToken['_id'];
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Change the color to red
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        else {
          print('Snapshot data: ${snapshot.data}');
          String userId = snapshot.data?['user']['_id'] ?? '';

          print('User ID: $userId');
          if (userId.isEmpty) {
            return Text('User ID not available'); // Handle the case where user ID is empty or null
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  _pickImageFromCamera(userId);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
              ),
              child: Text('Take Picture of Car'),
            ),
          );
        }
      },
    );
  }



  Future<void> _pickImageFromCamera(String userId) async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    File selectedImage = File(pickedImage.path);

    // Perform image upload with user ID
    await _uploadImage(selectedImage, userId);
  }

  Future<void> _uploadImage(File image, String userId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(carsave));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['userId'] = userId; // Pass user ID as a field
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}



class UserWidget extends StatelessWidget {
  final String token;

  const UserWidget({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();


    Future<void> updateUser(BuildContext context, String userId) async {
      Map<String, String> requestBody = {};
      if (usernameController.text.isNotEmpty) {
        requestBody['username'] = usernameController.text;
      }
      if (emailController.text.isNotEmpty) {
        requestBody['email'] = emailController.text;
      }
      if (passwordController.text.isNotEmpty) {
        requestBody['password'] = passwordController.text;
      }

      try {
        var response = await http.put(
          Uri.parse(update + userId),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
        var jsonResponse = jsonDecode(response.body);
        print("Update user response: $jsonResponse");
        if (jsonResponse['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong')),
          );
        }
      } catch (error) {
        print("Error updating user: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user')),
        );
      }
    }

    return Center(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white, // Set the background color to white
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Set the color of the circle to red
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          else {
            print("User info snapshot: ${snapshot.data}");
            // Access the 'user' object within the snapshot data
            Map<String, dynamic>? userData = snapshot.data?['user'];
            // Extract user information from the 'user' object
            String userId = userData?['_id'] ?? '';
            String username = userData?['username'] ?? '';
            String email = userData?['email'] ?? '';
            print("User ID: $userId, Username: $username, Email: $email");

            // Now you can use userId, username, and email as needed



            return Center(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.8,
                margin: EdgeInsets.only(top: 90),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Username: "$username"',
                        style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter new username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Change Email: "$email"',
                        style: TextStyle(color: Colors.black, fontSize: 18.0 ,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter new email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Change Password: ',
                        style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter new password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => updateUser(context, userId),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            textStyle: TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Submit Changes'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );



          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      String userId = await _getUserIdFromToken();
      var response = await http.get(
        Uri.parse('$getuser$userId'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      var jsonResponse = jsonDecode(response.body);
      print("User info response: $jsonResponse");
      return jsonResponse;
    } catch (error) {
      print("Error getting user info: $error");
      throw error;
    }
  }

  Future<String> _getUserIdFromToken() async {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    return jwtDecodedToken['_id'];
  }
}

class UserhistWidget extends StatelessWidget {
  final String token;

  const UserhistWidget({Key? key, required this.token}) : super(key: key);

  Future<List<Car>> fetchCars() async {
    try {
      print("Fetching user ID...");
      String? userId = await _getUserIdFromToken();
      print("User ID obtained: $userId");
      if (userId == null) {
        throw Exception('User ID is null');
      }
      print('User ID: $userId');
      var response = await http.get(
        Uri.parse('$getcar$userId'), // Replace 'http://your-api-url/' with your actual API URL
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        print("Response body: $data");
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          List<dynamic> carList = data['data'];
          // Map each item in the carList to a Car object
          List<Car> cars = carList.map((carJson) {
            // Access the image URL from the carJson
            String? imageName = carJson['image'];
            return Car.fromJson(carJson, imageName);
          }).toList();
          return cars;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (error) {
      print("Error fetching cars: $error");
      throw error;
    }
  }

  Future<String?> _getUserIdFromToken() async {
    if (token == null) {
      throw Exception('Token is null');
    }
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    return jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Car>>(
      future: fetchCars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Change the color to red
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        else {
          List<Car>? cars = snapshot.data;
          if (cars != null && cars.isNotEmpty) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CarCard(car: cars[index]),
                );
              },
            );
          } else {
            return Center(child: Text('No cars found.'));
          }
        }
      },
    );
  }
}

class Car {
  final String? userId;
  final String? imageName; // Name of the image file
  final String make;
  final String model;
  final String? year;
  final double? inputPrice;
  final double? predictedPrice;


  Car({this.userId, required this.imageName,
    required this.make,
    required this.model,
    this.year,
    this.inputPrice,
    this.predictedPrice,});

  // Method to get the absolute file path of the image
  String get imagePath {
    if (imageName != null) {
      // Assuming your API endpoint is `getImageUrl`
      return '$getcarimage$imageName';
    }
    throw Exception('Image name is null');
  }

  factory Car.fromJson(Map<String, dynamic> json, String? imageName) {
    return Car(
      imageName: imageName ?? '',
      userId: json['userId'],
      make: json['make'] ?? '', // Default value if make is null
      model: json['model'] ?? '',
      year:json['year'] ?? '',
      inputPrice: json['inputPrice'] != null ? json['inputPrice'].toDouble() : 0,
      predictedPrice: json['predictedPrice'] != null ? json['predictedPrice'].toDouble() : 0,// Default value if model is null
    );
  }
}
class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Car Information'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Make: ${car.make}'),
                  Text('Model: ${car.model}'),
                  Text('Year: ${car.year ?? ''}'),
                  Text('Input Price: ${car.inputPrice ?? 0}'),
                  Text('Predicted Price: ${car.predictedPrice ?? 0}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Image.network(
            car.imagePath,
            // You may need to adjust this depending on where your images are stored
          ),
        ),
      ),
    );
  }
}





class MessagesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ChatPage(), // Assuming ChatPage is your chat interface
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 30,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
  ChatUser(id: '1', firstName: 'user', lastName: 'user');

  final ChatUser _gptChatUser =
  ChatUser(id: '2', firstName: 'Chat', lastName: 'Car');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  final String prompt = "Assist the user with questions and information about cars. Be specific and concise in your responses, focusing solely on topics related to cars such as car models, features, maintenance, buying advice, and troubleshooting."; // Include context

  @override
  Widget build(BuildContext context) {
    return DashChat(
      currentUser: _currentUser,
      typingUsers: _typingUsers,
      messageOptions: const MessageOptions(
        currentUserContainerColor: Colors.red,
        containerColor: Color.fromRGBO(
          128,
          128,
          128,
          1, // Grey color
        ),
        textColor: Colors.white,
      ),
      onSend: (ChatMessage m) {
        getChatResponse(m);
      },
      messages: _messages,
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    // Add the prompt to the message history
    _messagesHistory.insert(0, Messages(role: Role.assistant, content: prompt));
    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: _messagesHistory,
      maxToken: 400,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
