class Module {
  final String label;
  final String illustration;

  Module({
    required this.label,
    required this.illustration,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      label: json['label'] as String,
      illustration: json['illustration'] as String,
    );
  }
}