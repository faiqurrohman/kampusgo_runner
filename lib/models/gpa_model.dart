class GpaModel {
  final String id;
  final String course;
  final int sks;
  final double gradePoint;

  GpaModel({required this.id, required this.course, required this.sks, required this.gradePoint});

  factory GpaModel.fromJson(Map<String, dynamic> json) {
    return GpaModel(
      id: json['id'],
      course: json['course'],
      sks: json['sks'],
      gradePoint: json['gradePoint'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'sks': sks,
      'gradePoint': gradePoint,
    };
  }
}
