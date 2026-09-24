import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SizedBox(
                width: 168,
                height: 168,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(42),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(42),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.22),
                            AppColors.surfaceElevated.withOpacity(0.85),
                            AppColors.background.withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Image.asset('assets/images/studeck_logo.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Studeck', style: AppFonts.heading(fontSize: 28)),
              const SizedBox(height: 10),
              const Text(
                'Discover how you actually study,\nnot how you think you do',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const Spacer(flex: 4),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
