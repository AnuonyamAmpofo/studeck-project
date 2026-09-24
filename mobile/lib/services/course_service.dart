import '../models/course.dart';
import 'api_client.dart';
import 'demo_data_store.dart';
import 'demo_mode.dart';

class CourseService {
  CourseService(this._client);

  final ApiClient _client;

  Future<List<Course>> list() async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(DemoDataStore.instance.courses);
    }
    final res = await _client.dio.get('/courses');
    final courses = res.data['courses'] as List;
    return courses.map((c) => Course.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<Course> create(Course course) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final created = Course(
        id: DemoDataStore.instance.nextId(),
        name: course.name,
        code: course.code,
        colorHex: course.colorHex,
        emoji: course.emoji,
        courseType: course.courseType,
      );
      DemoDataStore.instance.courses.add(created);
      return created;
    }
    final res = await _client.dio.post('/courses', data: course.toCreateJson());
    return Course.fromJson(res.data['course'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    if (kDemoMode) {
      DemoDataStore.instance.courses.removeWhere((c) => c.id == id);
      return;
    }
    await _client.dio.delete('/courses/$id');
  }
}
