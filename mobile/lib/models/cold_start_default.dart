/// A research-backed default recommendation shown before a student has
/// enough personal session data for real per-individual insights (the
/// thesis's "cold start problem"). Labelled in the UI as research-based
/// rather than personal, per the thesis's requirement.
class ColdStartDefault {
  const ColdStartDefault({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;

  factory ColdStartDefault.fromJson(Map<String, dynamic> json) => ColdStartDefault(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
      );
}
