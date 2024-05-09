import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'config.dart';
import 'main.dart';
class AdminPage extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final token;

  const AdminPage({
    Key? key,
    this.token,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        fixedColor: Colors.red, // Change color of the selected item
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
        ],
      ),
      body: _buildBody(_currentIndex),
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






  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return UsersWidget(token: widget.token); // Show UsersWidget when index is 0
      case 1:
        return CarsWidget(); // Show CarsWidget when index is 1
      default:
        return Container(); // Show an empty container by default
    }
  }
}

class UsersWidget extends StatefulWidget {
  final token;

  const UsersWidget({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _UsersWidgetState createState() => _UsersWidgetState();
}

class _UsersWidgetState extends State<UsersWidget> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;

  // Function to fetch all users from the database
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse(getusers), headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData['status'] == true) {
        final List<dynamic> usersData = responseData['users'];

        setState(() {
          users = usersData.cast<Map<String, dynamic>>();
        });
      } else {
        // Handle case where API response indicates failure
        print('API request failed: ${responseData}');
      }
    } else {
      // Handle error
      print('Failed to load users: ${response.statusCode}');
    }
  }

  // Function to delete a user
  Future<void> deleteUser(String userId) async {
    final response = await http.delete(Uri.parse('$deleteuser$userId'), headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      // If successful, refresh the user list
      fetchUsers();
      // Show a SnackBar with the deleted user's username
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted')),
      );
    } else {
      // Handle error
      print('Failed to delete user: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Method to display user details card
  void showUserDetails(Map<String, dynamic> user) {
    setState(() {
      selectedUser = user;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reset selectedUser when tapped outside the card
        setState(() {
          selectedUser = null;
        });
      },
      child: Center(
        child: selectedUser != null
            ? Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.grey,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin: EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('userId: ${selectedUser!['_id']}'),
                        Text('Username: ${selectedUser!['username']}'),
                        Text('Email: ${selectedUser!['email']}'),
                        Text('numberOfCars: ${selectedUser!['numberOfCars']}'),
                        Text('Created At: ${selectedUser!['createdAt']}'),
                        Text('Updated At: ${selectedUser!['updatedAt']}'),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Call delete function when delete button is pressed
                                deleteUser(selectedUser!['_id']);
                                setState(() {
                                  selectedUser = null; // Close details card after deletion
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Username:'+ users[index]['username']),
                  subtitle: Text('userId:'+ users[index]['_id']),
                  onTap: () {
                    // Call showUserDetails method when user is tapped
                    showUserDetails(users[index]);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class CarsWidget extends StatefulWidget {
  @override
  _CarsWidgetState createState() => _CarsWidgetState();
}

class _CarsWidgetState extends State<CarsWidget> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  Future<List<Car>> fetchCars() async {
    final response = await http.get(Uri.parse(getallcars));
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      print("Response body: $data");
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        List<dynamic> carList = data['data'];
        List<Car> cars = carList.map((carJson) {
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
  }

  Future<void> refreshCars() async {
    setState(() {}); // Trigger rebuild to fetch updated list of cars
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<List<Car>>(
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
                    child: CarCard(
                      car: cars[index],
                      refreshCars: refreshCars, // Pass refresh function to CarCard
                      scaffoldKey: _scaffoldKey,
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No cars found.'));
            }
          }
        },
      ),
    );
  }
}
class Car {
  final String? id; // Make id nullable
  final String? userId;
  final String? imageName;
  final String make;
  final String model;
  final String? year;
  final double? inputPrice;
  final double? predictedPrice;

  Car({
    this.id, // Update id to be nullable
    this.userId,
    required this.imageName,
    required this.make,
    required this.model,
    this.year,
    this.inputPrice,
    this.predictedPrice,
  });

  String get imagePath {
    if (imageName != null) {
      return '$getcarimage$imageName';
    }
    throw Exception('Image name is null');
  }

  factory Car.fromJson(Map<String, dynamic> json, String? imageName) {
    return Car(
      id: json['_id'],
      imageName: imageName ?? '',
      userId: json['userId'],
      make: json['Make'] ?? '', // Default value if make is null
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      inputPrice: json['inputPrice'] != null ? json['inputPrice'].toDouble() : 0,
      predictedPrice: json['predictedPrice'] != null ? json['predictedPrice'].toDouble() : 0,
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;
  final Future<void> Function() refreshCars; // Callback function to refresh cars
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  const CarCard({
    Key? key,
    required this.car,
    required this.refreshCars,
    required this.scaffoldKey,
  }) : super(key: key);

  Future<void> deleteCar(String? carId, BuildContext context) async {
    if (carId == null) {
      print('Car ID is null. Cannot delete car.');
      return;
    }

    final response = await http.delete(
      Uri.parse('$deletecar$carId'), // Use your delete API endpoint
    );
    if (response.statusCode == 200) {
      // Car deleted successfully
      print('Car deleted successfully');
      // Show a Snackbar to indicate successful deletion
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Car deleted successfully')),
      );
      // Refresh the list of cars
      refreshCars();
    } else {
      // Failed to delete car
      print('Failed to delete car: ${response.statusCode}');
      // Show an error Snackbar
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to delete car')),
      );
    }
  }

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
                  Text('userId: ${car.userId}'),
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
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    // Call delete function when delete button is pressed
                    deleteCar(car.id, context); // Pass the context here
                    Navigator.of(context).pop(); // Close the dialog
                  },

                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
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
          ),
        ),
      ),
    );
  }
}
