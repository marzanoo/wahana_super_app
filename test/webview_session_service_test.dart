import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app_wahana/services/webview_session_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clear works when no WebView platform is registered', () async {
    SharedPreferences.setMockInitialValues({
      'webview_session_owner': 'EMP001',
    });

    expect(WebViewPlatform.instance, isNull);

    await WebViewSessionService.clear();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('webview_session_owner'), isNull);
  });
}
