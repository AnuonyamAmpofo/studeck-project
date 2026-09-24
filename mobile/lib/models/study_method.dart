import 'package:flutter/material.dart';

class StudyMethod {
  const StudyMethod(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

// Matches the exact method list named in the thesis's dataset description.
const kStudyMethods = [
  StudyMethod('reading', 'Reading', Icons.menu_book_rounded),
  StudyMethod('practice', 'Practice', Icons.edit_rounded),
  StudyMethod('flashcards', 'Flashcards', Icons.style_rounded),
  StudyMethod('videos', 'Videos', Icons.play_circle_rounded),
  StudyMethod('active_recall', 'Active Recall', Icons.psychology_rounded),
  StudyMethod('group', 'Group', Icons.groups_rounded),
];

String studyMethodLabel(String value) =>
    kStudyMethods.firstWhere((m) => m.value == value, orElse: () => StudyMethod(value, value, Icons.circle)).label;
