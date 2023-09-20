import 'package:flutter/material.dart';
import 'home_page.dart';
import 'mock_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entry point of the app
void main() async {
  // Ensure the widget tree is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if the user is already logged in
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Start the app
  runApp(MyApp(
    initialRoute: isLoggedIn ? '/home' : '/',
  ));
}

// Main App widget
class MyApp extends StatelessWidget {
  final String initialRoute;

  // Constructor to set the initial route
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  // Build function to create widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hide debug banner
      debugShowCheckedModeBanner: false,
      // Set initial route based on login status
      initialRoute: initialRoute,
      // Define available routes
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

// LoginPage widget
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  // Build function to create the login page widget tree
  @override
  Widget build(BuildContext context) {
    // Variables to store entered credentials
    String enteredUsername = '';
    String enteredPassword = '';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          // Text field for entering username
          TextFormField(
            decoration: const InputDecoration(labelText: 'Username'),
            onChanged: (value) => enteredUsername = value,
          ),
          // Text field for entering password
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) => enteredPassword = value,
          ),
          // Login button
          ElevatedButton(
            onPressed: () {
              // Check credentials using the MockDb
              MockDb.checkLogIn(enteredUsername, enteredPassword)
                  .then((success) {
                if (success) {
                  // Navigate to HomePage if login is successful
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                } else {
                  // Show snackbar if login fails
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid credentials')));
                }
              });
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
