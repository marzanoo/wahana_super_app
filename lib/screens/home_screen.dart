import 'package:flutter/material.dart';
import 'package:super_app_wahana/screens/audit_6s_screen.dart';
import 'package:super_app_wahana/screens/kpi_screen.dart';
import 'package:super_app_wahana/screens/call_me_ga_screen.dart';
import 'package:super_app_wahana/services/auth_service.dart';

import '../widgets/custom_header.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _name;
  // int? _role;
  String? _dept;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    if (!await AuthService.isTokenValid()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi Telah Berakhir. Silahkan Login Kembali'),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getName();
    // final role = await AuthService.getRole();
    final dept = await AuthService().getKaryawan();
    if (!mounted) return;
    setState(() {
      _name = name ?? 'Wahanian';
      // _role = role;
      _dept = dept?.dept;
    });
  }

  bool _hasAccess(String appName) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(showProfileIcon: true),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Welcome (merah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFB3282D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome ${_name ?? 'Wahanian'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dept: ${_dept ?? '-'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Mau ngapain hari ini?',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Grid Apps
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    if (_hasAccess('Audit 6S'))
                      _buildAppCard(
                        icon: Icons.checklist,
                        label: 'AuditApp 6S',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Audit6SScreen(),
                          ),
                        ),
                      ),
                    if (_hasAccess('KPI'))
                      _buildAppCard(
                        icon: Icons.bar_chart,
                        label: 'KPI',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KpiScreen()),
                        ),
                      ),
                    if (_hasAccess('Meeting Room'))
                      _buildAppCard(
                        icon: Icons.meeting_room,
                        label: 'Meeting Room',
                        enabled: false,
                      ),
                    if (_hasAccess('Car Booking'))
                      _buildAppCard(
                        icon: Icons.directions_car,
                        label: 'Car Booking',
                        enabled: false,
                      ),
                    if (_hasAccess('Zoom Booking'))
                      _buildAppCard(
                        icon: Icons.videocam,
                        label: 'ZOOM Meeting',
                        enabled: false,
                      ),
                    if (_hasAccess('Innovation'))
                      _buildAppCard(
                        icon: Icons.lightbulb_outline,
                        label: 'Innovation',
                        enabled: false,
                      ),
                    if (_hasAccess('Call Me GA'))
                      _buildAppCard(
                        icon: Icons.phone,
                        label: 'Call Me GA',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CallMeGaScreen(),
                          ),
                        ),
                      ),
                    if (_hasAccess('Other'))
                      _buildAppCard(
                        icon: Icons.more_horiz,
                        label: 'Other',
                        enabled: false,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFB71C1C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: 0, // Beranda aktif
        onTap: (index) {
          // TODO: Handle navigasi jika ada tab lain
        },
      ),
    );
  }

  Widget _buildAppCard({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      enabled: enabled,
      button: enabled,
      label: enabled ? label : '$label, segera hadir',
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container dengan efek modern
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: enabled
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD32F2F), Color(0xFFB3282D)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFB3282D,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 32),
                      if (!enabled)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Segera hadir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Label outside the card
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFF333333)
                      : const Color(0xFF757575),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
