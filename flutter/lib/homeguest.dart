import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'consts.dart';
import 'login.dart';
import 'main.dart';

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
        elevation: 0, // To remove the shadow below the app bar
        actions: [
          IconButton(
            icon: Icon(
              Icons.login,
              color: Colors.grey, // Color of the logout icon
            ),
            onPressed: () {

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
class UploadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _pickImageFromGallery();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Set button color to red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Set border radius
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Upload Picture of Car from Gallery',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickImageFromGallery() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    // Do something with the picked image
    File selectedImage = File(pickedImage.path);
    // ...
  }
}

class CameraWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _pickImageFromCamera();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Set button color to red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Set border radius
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Take Picture of Car',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    // Do something with the captured image
    File selectedImage = File(pickedImage.path);
    // ...
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
        seconds: 5,
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
      maxToken: 200,
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
