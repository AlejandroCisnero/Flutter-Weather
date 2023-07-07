import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static Route<String> route() {
    return MaterialPageRoute(
      builder: (context) => const SearchPage(),
    );
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;

  String get text => _controller.text;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for a city'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  label: Text('City'),
                  hintText: 'Chicago',
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('search_city_button'),
            onPressed: () => Navigator.of(context).pop(text),
            icon: const Icon(
              Icons.search,
              semanticLabel: 'Submit',
            ),
          )
        ],
      ),
    );
  }
}
