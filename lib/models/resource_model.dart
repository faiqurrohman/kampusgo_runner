class ResourceModel {
  final String id;
  final String course;
  final String title;
  final String link;
  final String tag;

  ResourceModel({
    required this.id,
    required this.course,
    required this.title,
    required this.link,
    this.tag = 'Kuliah',
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'],
      course: json['course'],
      title: json['title'],
      link: json['link'],
      tag: json['tag'] ?? 'Kuliah',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'title': title,
      'link': link,
      'tag': tag,
    };
  }
}
