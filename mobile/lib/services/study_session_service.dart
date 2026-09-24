import '../models/study_session.dart';
import 'api_client.dart';
import 'demo_data_store.dart';
import 'demo_mode.dart';

class StudySessionService {
  StudySessionService(this._client);

  final ApiClient _client;

  Future<List<StudySession>> list({String? courseId}) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final all = DemoDataStore.instance.sessions;
      final filtered = courseId == null ? all : all.where((s) => s.courseId == courseId).toList();
      return List.from(filtered);
    }
    final res = await _client.dio.get('/study-sessions', queryParameters: {
      if (courseId != null) 'courseId': courseId,
    });
    final sessions = res.data['sessions'] as List;
    return sessions.map((s) => StudySession.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<StudySession> create({
    required String courseId,
    required DateTime startedAt,
    DateTime? endedAt,
    int? plannedDurationSeconds,
    String? technique,
    List<String>? methods,
    String? environment,
    bool? focusModeOn,
    int? selfRating,
    int? problemsAttempted,
    int? problemsCorrect,
    int? pagesTotal,
    int? pagesCovered,
  }) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final durationSeconds = endedAt?.difference(startedAt).inSeconds.abs();
      final session = StudySession(
        id: DemoDataStore.instance.nextId(),
        courseId: courseId,
        startedAt: startedAt,
        endedAt: endedAt,
        plannedDurationSeconds: plannedDurationSeconds,
        durationSeconds: durationSeconds,
        technique: technique,
        methods: methods ?? const [],
        environment: environment,
        focusModeOn: focusModeOn ?? false,
        selfRating: selfRating,
        problemsAttempted: problemsAttempted,
        problemsCorrect: problemsCorrect,
        pagesTotal: pagesTotal,
        pagesCovered: pagesCovered,
      );
      DemoDataStore.instance.sessions.insert(0, session);
      return session;
    }
    final res = await _client.dio.post('/study-sessions', data: {
      'courseId': courseId,
      'startedAt': startedAt.toIso8601String(),
      if (endedAt != null) 'endedAt': endedAt.toIso8601String(),
      if (plannedDurationSeconds != null) 'plannedDurationSeconds': plannedDurationSeconds,
      if (technique != null) 'technique': technique,
      if (methods != null) 'methods': methods,
      if (environment != null) 'environment': environment,
      if (focusModeOn != null) 'focusModeOn': focusModeOn,
      if (selfRating != null) 'selfRating': selfRating,
      if (problemsAttempted != null) 'problemsAttempted': problemsAttempted,
      if (problemsCorrect != null) 'problemsCorrect': problemsCorrect,
      if (pagesTotal != null) 'pagesTotal': pagesTotal,
      if (pagesCovered != null) 'pagesCovered': pagesCovered,
    });
    return StudySession.fromJson(res.data['session'] as Map<String, dynamic>);
  }
}
