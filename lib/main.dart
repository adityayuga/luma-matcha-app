import 'package:flutter/material.dart';

void main() {
  runApp(LumaMatchaApp());
}

class LumaMatchaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma Matcha Jogja',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MenuViewerScreen(),
    );
  }
}

class MenuViewerScreen extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/menu.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: ListView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(imagePaths[index]),
          );
        },
      ),
    );
  }
}