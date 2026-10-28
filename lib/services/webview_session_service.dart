import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSessionService {
  static const String _sessionOwnerKey = 'webview_session_owner';

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionOwnerKey);
    await _clearBrowserData();
  }

  static Future<void> prepareForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('nik');
    final sessionOwner = prefs.getString(_sessionOwnerKey);

    if (currentUser == null || currentUser.isEmpty) {
      await clear();
      throw StateError('User belum login');
    }

    if (sessionOwner == currentUser) {
      return;
    }

    await _clearBrowserData();
    await prefs.setString(_sessionOwnerKey, currentUser);
  }

  static Future<void> _clearBrowserData() async {
    // webview_flutter only registers a platform implementation on supported
    // targets. Login/logout must still work on Windows, web, and unit tests,
    // where no WebView implementation is available.
    if (WebViewPlatform.instance == null) {
      return;
    }

    await WebViewCookieManager().clearCookies();

    final controller = WebViewController();
    await controller.clearCache();
    await controller.clearLocalStorage();
  }
}
