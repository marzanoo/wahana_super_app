import 'package:flutter/material.dart';
import 'package:super_app_wahana/services/auth_service.dart';
import 'package:super_app_wahana/services/webview_download_service.dart';
import 'package:super_app_wahana/services/webview_session_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await WebViewSessionService.prepareForCurrentUser();
      final token = await AuthService.getToken() ?? '';
      if (!mounted) return;

      final controller = WebViewController();
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (url) async {
              await WebViewDownloadService.injectInterceptor(controller);
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        );

      await WebViewDownloadService.register(controller, context);
      _controller = controller;
      await controller.loadRequest(
        Uri.parse('http://124.243.134.244/kpi'), // Ganti sesuai sub-app
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading after init
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading page: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI Management'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFFB3282D),
        iconTheme: const IconThemeData(
          color: Colors.white, // White back arrow
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo_wag_white.png',
              width: 36,
              height: 36,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
