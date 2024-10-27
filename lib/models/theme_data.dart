class ThemeData {
  final String name;
  final String color;
  final String illustration;

  ThemeData({
    required this.name,
    required this.color,
    required this.illustration,
  });

  factory ThemeData.fromJson(Map<String, dynamic> json) {
    return ThemeData(
      name: json['name'] as String,
      color: json['color'] as String,
      illustration: json['illustration'] as String,
    );
  }
}