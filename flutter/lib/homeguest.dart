import 'dart:collection';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'consts.dart';
import 'login.dart';
import 'dart:async';
import 'main.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:typed_data';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'dart:developer' as devtools;
class ThePageguest extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final token;


  const ThePageguest({
    Key? key,
    this.token,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _ThePageguestState createState() => _ThePageguestState();
}

class _ThePageguestState extends State<ThePageguest> {
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Background color of the app bar
        elevation: 0,
        automaticallyImplyLeading: false,// To remove the shadow below the app bar
        actions: [
          IconButton(
            icon: Icon(
              Icons.login,
              color: Colors.grey, // Color of the logout icon
            ),
            onPressed: () {


                Tflite.close();


              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        fixedColor: Colors.red, // Change color of the selected item
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
            icon: Icon(Icons.message), // New messages icon
            label: 'ChatCar',
          ),
        ],
      ),
      body: _buildBody(_currentIndex),
    );
  }
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return UploadWidget(); // Show UploadWidget when index is 0
      case 1:
        return CameraWidget();// Show CameraWidget when index is 1
      case 2:
        return MessagesWidget(); // Show MessagesWidget when index is 2
      default:
        return Container(); // Show an empty container by default
    }
  }
}

class UploadWidget extends StatefulWidget {
  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  late List<String> classes;
  String? imagePath;
  String? recognitionResult;
  String? make;
  String? model;
  String? year;

  @override
  void initState() {
    super.initState();
    _tfLteInit();
    _loadClasses();
  }


  Future<void> _tfLteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/Classes.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _loadClasses() async {
    String data = await rootBundle.loadString('assets/Classes.txt');
    setState(() {
      classes = LineSplitter().convert(data);
    });
  }


  Future<void> _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    File selectedImage = File(pickedImage.path);

    // Resize image to 300x300
    File resizedImage = await _resizeImage(selectedImage);

    // Run TensorFlow Lite model on the resized image
    var recognitions = await Tflite.runModelOnImage(
      path: resizedImage.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );
    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    // Split recognition result
    List<String> parts = recognitions[0]['label'].toString().split('_');
    setState(() {
      imagePath = resizedImage.path;
      recognitionResult = recognitions[0]['label'].toString();
      make = parts[0];
      model = parts[1];
      year = parts[2];
    });
    devtools.log(recognitions[0]['label'].toString());
  }

  Future<File> _resizeImage(File imageFile) async {
    // Read the image from file
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    // Resize the image to 300x300
    img.Image resizedImage = img.copyResize(image, width: 300, height: 300);

    // Write the resized image to a new file
    File resizedFile = File(imageFile.path.replaceAll(RegExp(r'\.[^\.]+$'), '_resized.jpg'));
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage));

    return resizedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Wrap your Column with Center widget
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imagePath != null
              ? Image.file(File(imagePath!))
              : Container(),
          recognitionResult != null
              ? Column(
            children: [

                SizedBox(height: 10),
                make != null ? Text("Make: $make") : Container(),
                model != null ? Text("Model: $model") : Container(),
                year != null ? Text("Year: $year") : Container(),
            ],
          )
              : Container(),
          ElevatedButton(
            onPressed: () {
              _pickImageFromGallery();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              // Change button color to red
            ),
            child: Text(
              'Upload Picture of Car',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
          ),

        ],
      ),
    );
  }
}
class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late List<String> classes;
  String? imagePath;
  String? recognitionResult;
  String? make;
  String? model;
  String? year;

  @override
  void initState() {
    super.initState();
    _tfLiteInit();
    _loadClasses();
  }


  Future<void> _tfLiteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/Classes.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _loadClasses() async {
    String data = await rootBundle.loadString('assets/Classes.txt');
    setState(() {
      classes = LineSplitter().convert(data);
    });
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    File selectedImage = File(pickedImage.path);

    // Resize image to 300x300
    File resizedImage = await _resizeImage(selectedImage);

    // Run TensorFlow Lite model on the resized image
    var recognitions = await Tflite.runModelOnImage(
      path: resizedImage.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );
    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    // Split recognition result
    List<String> parts = recognitions[0]['label'].toString().split('_');
    setState(() {
      imagePath = resizedImage.path;
      recognitionResult = recognitions[0]['label'].toString();
      make = parts[0];
      model = parts[1];
      year = parts[2];
    });
    devtools.log(recognitions[0]['label'].toString());
  }
  Future<File> _resizeImage(File imageFile) async {
    // Read the image from file
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    // Rotate the image 90 degrees to the right
    img.Image rotatedImage = img.copyRotate(image, 90);

    // Resize the rotated image to 300x300
    img.Image resizedImage = img.copyResize(rotatedImage, width: 300, height: 300);

    // Write the resized image to a new file
    File resizedFile = File(imageFile.path.replaceAll(RegExp(r'\.[^\.]+$'), '_resized.jpg'));
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage));

    return resizedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Wrap your Column with Center widget
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imagePath != null
              ? Image.file(File(imagePath!))
              : Container(),
          recognitionResult != null
              ? Column(
            children: [

                  SizedBox(height: 10),
                  make != null ? Text("Make: $make") : Container(),
                  model != null ? Text("Model: $model") : Container(),
                  year != null ? Text("Year: $year") : Container(),
            ],
          )
              : Container(),
          ElevatedButton(
            onPressed: () {
              _pickImageFromCamera(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              // Change button color to red
            ),
            child: Text(
              'Take Picture of Car',
              style: TextStyle(color: Colors.white), // Change text color to white
            ),
          ),

        ],
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

  final String prompt = "Talk about cars and assist the user with questions about cars."; // Include context

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