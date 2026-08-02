import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

/// Two-stage splash screen matching the Figma design:
///
/// Stage 1 — full navy screen with the NX logo + tagline only.
/// Stage 2 — after a short delay, a white "Welcome to the future" card
///           slides up from the bottom with a "Get Started" button.
///
/// Tapping "Get Started" hands off to [AuthWrapper], which already
/// listens to Firebase auth state and routes to:
///   - LoginScreen              (not logged in)
///   - AdminDashboardScreen     (role == 'admin')
///   - TeacherDashboard         (role == 'teacher')
///   - StudentDashboardScreen   (role == 'student')
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _fullTagline = "The Future Campus Platform";

  bool _showWelcomeCard = false;
  String _typedTagline = "";
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() {
    const typingSpeed = Duration(milliseconds: 85);
    int charIndex = 0;

    _typewriterTimer = Timer.periodic(typingSpeed, (timer) {
      if (charIndex < _fullTagline.length) {
        setState(() {
          _typedTagline = _fullTagline.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        // Every letter has been typed — only now reveal the welcome card.
        timer.cancel();
        setState(() => _showWelcomeCard = true);
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  void _getStarted() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Stage 1: logo + typewriter tagline, always centered behind the card.
          _LogoSection(compact: _showWelcomeCard, tagline: _typedTagline),

          // Stage 2: welcome card, animated in from off-screen.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _showWelcomeCard ? 0 : -360,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeIn,
              opacity: _showWelcomeCard ? 1 : 0,
              child: _WelcomeCard(onGetStarted: _getStarted),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  final bool compact;
  final String tagline;

  const _LogoSection({required this.compact, required this.tagline});

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      // Nudge the logo upward once the card appears, like the Figma flow.
      alignment: compact ? const Alignment(0, -0.35) : Alignment.center,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  "NX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "NexCampus",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _WelcomeCard({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Welcome to the future",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Elevate your academic experience with "
              "our premium management ecosystem.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
