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
}
