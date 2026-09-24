import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_state.dart';
import '../onboarding/landing_screen.dart';
import 'app_shell.dart';

/// Shown at app launch while we try to silently restore a session from the
/// persisted refresh-token cookie, then routes to the shell or landing page.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthState>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthState>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const AppShell();
      case AuthStatus.unauthenticated:
        return const LandingScreen();
    }
  }
}
