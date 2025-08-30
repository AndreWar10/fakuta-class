class Planet {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double distanceFromSun; // em milhões de km
  final double diameter; // em km
  final int moons;
  final String type; // terrestre, gasoso, anão
  final Map<String, String> facts;

  Planet({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.distanceFromSun,
    required this.diameter,
    required this.moons,
    required this.type,
    required this.facts,
  });

  bool get isTerrestrial => type == 'terrestre';
  bool get isGasGiant => type == 'gasoso';
  bool get isDwarf => type == 'anão';
}
