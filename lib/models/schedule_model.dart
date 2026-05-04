class ScheduleModel {
  final String id;
  final String title;
  final String course;
  final DateTime deadline;
  final String priority;
  final bool done;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    this.done = false,
  });

  ScheduleModel copyWith({String? id, String? title, String? course, DateTime? deadline, String? priority, bool? done}) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }
}
