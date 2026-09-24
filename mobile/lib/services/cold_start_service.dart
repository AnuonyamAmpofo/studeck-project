import '../models/cold_start_default.dart';
import 'api_client.dart';
import 'demo_mode.dart';

class ColdStartService {
  ColdStartService(this._client);

  final ApiClient _client;

  Future<List<ColdStartDefault>> listForCourseType(String courseType) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        ColdStartDefault(
          id: 'demo-$courseType',
          title: 'Keep logging sessions',
          body: "We'll surface personal insights once you've logged a few more sessions for this course.",
        ),
      ];
    }
    final res = await _client.dio.get('/cold-start-defaults/$courseType');
    return (res.data['defaults'] as List)
        .map((d) => ColdStartDefault.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
