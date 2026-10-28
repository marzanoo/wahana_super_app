import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_wahana/main.dart';
import 'package:super_app_wahana/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders its form', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(initalRoute: const LoginScreen()));

    expect(find.text('Login'), findsNWidgets(2));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('SignUp'), findsNothing);
  });
}
