import '../models/grade.dart';
import 'api_client.dart';
import 'demo_data_store.dart';
import 'demo_mode.dart';

class GradeService {
  GradeService(this._client);

  final ApiClient _client;

  Future<List<Grade>> list({String? courseId}) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final all = DemoDataStore.instance.grades;
      final filtered = courseId == null ? all : all.where((g) => g.courseId == courseId).toList();
      return List.from(filtered);
    }
    final res = await _client.dio.get('/grades', queryParameters: {
      if (courseId != null) 'courseId': courseId,
    });
    return (res.data['grades'] as List).map((g) => Grade.fromJson(g as Map<String, dynamic>)).toList();
  }

  Future<Grade> create({
    required String courseId,
    required String assessmentName,
    required num score,
    required num maxScore,
  }) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final grade = Grade(
        id: DemoDataStore.instance.nextId(),
        courseId: courseId,
        assessmentName: assessmentName,
        score: score,
        maxScore: maxScore,
        takenAt: DateTime.now(),
      );
      DemoDataStore.instance.grades.add(grade);
      return grade;
    }
    final res = await _client.dio.post('/grades', data: {
      'courseId': courseId,
      'assessmentName': assessmentName,
      'score': score,
      'maxScore': maxScore,
    });
    return Grade.fromJson(res.data['grade'] as Map<String, dynamic>);
  }
}
