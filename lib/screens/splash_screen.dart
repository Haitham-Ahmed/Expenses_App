import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFa8e6cf), 
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مصروفي',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo', 
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'راقب مصاريفك بسهولة',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // TextButton(
              //   onPressed: () {
              //     Navigator.pushReplacementNamed(context, '/home');
              //   },
              //   child: const Text(
              //     'أو جرّب التطبيق بدون تسجيل',
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Colors.black54,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
