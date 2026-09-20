import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/screens/app_entry_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Dùng `Timer` (thay vì `Future.delayed`) để huỷ được trong `dispose` —
  /// nếu không, timer vẫn treo sau khi widget bị huỷ.
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      // `mounted`: widget có thể đã bị huỷ trước khi hết 2 giây (ví dụ
      // `AppEntryGate` đã chuyển trang) — dùng `context` lúc đó sẽ ném
      // "This widget has been unmounted".
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppEntryGate()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/icons/app_icon.png'),
              width: 160,
              height: 160,
            ),
            SizedBox(height: 32),
            LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
