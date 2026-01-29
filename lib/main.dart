import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app_wahana/screens/home_screen.dart';
import 'package:super_app_wahana/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //cek user login atau tidak / token valid atau tidak
  final isLoggedIn = await _isUserLoggedIn();
  runApp(MyApp(initalRoute: isLoggedIn ? const HomeScreen() : const LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initalRoute;

  const MyApp({super.key, required this.initalRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wahana Super App',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: initalRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<bool> _isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final expiresAtStr = prefs.getString('token_expires_at');

  if (token == null || expiresAtStr == null) return false;

  final expiresAt = DateTime.parse(expiresAtStr);
  if (DateTime.now().isAfter(expiresAt)) {
    await prefs.clear();
    return false;
  }
  return true;
}
