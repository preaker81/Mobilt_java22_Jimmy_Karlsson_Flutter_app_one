import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage())),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String imageUrl = "";
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
    _listenForShake();
  }

  void _listenForShake() {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (event.x.abs() > 20.0 ||
          event.y.abs() > 20.0 ||
          event.z.abs() > 20.0) {
        fetchCard();
      }
    });
  }

  _loadSavedImages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        history = List<Map<String, String>>.from(
            json.decode(prefs.getString('image_history') ?? '[]'));
      });
    } catch (e) {
      print("Exception in _loadSavedImages: $e");
    }
  }

  _saveImage(String name, String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      history.insert(0, {'name': name, 'url': url});
      if (history.length > 10) {
        history = history.sublist(0, 10);
      }
      prefs.setString('image_history', json.encode(history));
    } catch (e) {
      print("Exception in _saveImage: $e");
    }
  }

  Future<void> fetchCard() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.scryfall.com/cards/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          imageUrl = data['image_uris']['normal'];
          String cardName = data['name'];
          _saveImage(cardName, imageUrl);
        });
      } else {
        print('Failed to load card');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double reservedHeight = screenHeight * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: reservedHeight + 32.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: imageUrl.isEmpty ? Container() : Image.network(imageUrl),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: reservedHeight,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: history
                      .map((card) => TextButton(
                            onPressed: () {
                              setState(() {
                                imageUrl = card['url']!;
                              });
                            },
                            child: Text(card['name']!),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: reservedHeight,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: fetchCard, child: const Text('New Card')),
            ),
          ),
        ],
      ),
    );
  }
}
