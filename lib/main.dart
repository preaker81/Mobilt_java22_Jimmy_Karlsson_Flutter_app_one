import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String imageUrl = "";
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  _loadSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history = List<Map<String, String>>.from(
          json.decode(prefs.getString('image_history') ?? '[]'));
    });
  }

  _saveImage(String name, String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    history.insert(0, {'name': name, 'url': url});
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }
    prefs.setString('image_history', json.encode(history));
  }

  Future<void> fetchCard() async {
    final response =
        await http.get(Uri.parse('https://api.scryfall.com/cards/random'));
    final data = json.decode(response.body);

    setState(() {
      imageUrl = data['image_uris']['normal'];
      String cardName = data['name'];
      _saveImage(cardName, imageUrl);
    });
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
