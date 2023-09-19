// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'main.dart'; // Importera denna för att använda LoginPage
import 'mock_db.dart'; // Importera denna för att använda MockDb.handleLogout

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String imageUrl = "";
  List<Map<String, String>> history = [];
  late StreamSubscription _accelSubscription;
  bool canFetch = true;

  @override
  void initState() {
    super.initState();
    _listenForShake();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await Future.wait([
      _loadSavedImages(),
      fetchCard(),
    ]);
    setState(() {});
  }

  void _listenForShake() async {
    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    _accelSubscription = stream.listen((sensorEvent) {
      final accelData = sensorEvent.data;
      if (accelData[0].abs() > 20.0 ||
          accelData[1].abs() > 20.0 ||
          accelData[2].abs() > 20.0) {
        if (canFetch) {
          fetchCard();
          canFetch = false;
          Timer(const Duration(seconds: 2), () {
            canFetch = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadSavedImages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var savedHistory = json.decode(prefs.getString('image_history') ?? '[]');
      List<Map<String, String>> tempHistory = [];

      for (var item in savedHistory) {
        tempHistory.add({
          'name': item['name'].toString(),
          'url': item['url'].toString(),
        });
      }

      setState(() {
        history = tempHistory;
      });
    } catch (e) {
      print("Exception in _loadSavedImages: $e");
    }
  }

  Future<void> _saveImage(String name, String url) async {
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

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already logged in')));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          actions: [
            TextButton(
              onPressed: () async {
                await MockDb.handleLogout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text("Log out"),
            ),
          ],
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
                  child:
                      imageUrl.isEmpty ? Container() : Image.network(imageUrl),
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
      ),
    );
  }
}
