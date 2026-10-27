import 'package:flutter/material.dart';

class ZoomBookingScreen extends StatefulWidget {
  const ZoomBookingScreen({super.key});

  @override
  State<ZoomBookingScreen> createState() => _ZoomBookingScreenState();
}

class _ZoomBookingScreenState extends State<ZoomBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoom Booking')),
      body: const Center(child: Text('This is the Zoom Booking Screen')),
    );
  }
}
