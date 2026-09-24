import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/cold_start_service.dart';
import 'services/course_service.dart';
import 'services/dashboard_service.dart';
import 'services/google_auth_config.dart';
import 'services/grade_service.dart';
import 'services/quiz_service.dart';
import 'services/study_session_service.dart';
import 'screens/shell/session_gate.dart';
import 'state/auth_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();
  // Must be awaited exactly once before any other GoogleSignIn call.
  await GoogleSignIn.instance.initialize(serverClientId: kGoogleServerClientId);
  runApp(const StudeckApp());
}

class StudeckApp extends StatelessWidget {
  const StudeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient.instance;

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService(apiClient)),
        Provider(create: (_) => CourseService(apiClient)),
        Provider(create: (_) => GradeService(apiClient)),
        Provider(create: (_) => StudySessionService(apiClient)),
        Provider(create: (_) => QuizService(apiClient)),
        Provider(create: (_) => ColdStartService(apiClient)),
        ProxyProvider2<StudySessionService, QuizService, DashboardService>(
          update: (_, sessions, quizzes, __) => DashboardService(sessions, quizzes),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthState(context.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Studeck',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SessionGate(),
      ),
    );
  }
}
