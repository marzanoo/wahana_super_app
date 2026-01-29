import 'package:flutter/material.dart';

class InnovationScreen extends StatefulWidget {
  const InnovationScreen({super.key});

  @override
  _InnovationScreenState createState() => _InnovationScreenState();
}

class _InnovationScreenState extends State<InnovationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Innovation')),
      body: const Center(child: Text('This is the Innovation Screen')),
    );
  }
}
