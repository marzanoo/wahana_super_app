import 'package:flutter/material.dart';

class MeetingRoomScreen extends StatefulWidget {
  const MeetingRoomScreen({super.key});

  @override
  _MeetingRoomScreenState createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Room')),
      body: const Center(child: Text('This is the Meeting Room Screen')),
    );
  }
}
