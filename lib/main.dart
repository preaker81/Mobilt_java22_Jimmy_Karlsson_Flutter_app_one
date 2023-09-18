import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
        print("Received Data: $data");

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: imageUrl.isEmpty ? Container() : Image.network(imageUrl),
              ),
            ),
          ),
          ElevatedButton(onPressed: fetchCard, child: const Text('New Card')),
          SingleChildScrollView(
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
        ],
      ),
    );
  }
}
