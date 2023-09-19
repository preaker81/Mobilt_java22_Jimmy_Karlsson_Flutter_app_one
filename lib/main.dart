import 'package:flutter/material.dart';
import 'home_page.dart';
import 'mock_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    initialRoute: isLoggedIn ? '/home' : '/',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String enteredUsername = '';
    String enteredPassword = '';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Username'),
            onChanged: (value) => enteredUsername = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) => enteredPassword = value,
          ),
          ElevatedButton(
            onPressed: () {
              MockDb.checkLogIn(enteredUsername, enteredPassword)
                  .then((success) {
                if (success) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                } else {
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
