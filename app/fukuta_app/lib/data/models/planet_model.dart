import '../../domain/entities/planet.dart';

class PlanetModel extends Planet {
  PlanetModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imagePath,
    required super.distanceFromSun,
    required super.diameter,
    required super.moons,
    required super.type,
    required super.facts,
  });

  factory PlanetModel.fromJson(Map<String, dynamic> json) {
    return PlanetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      distanceFromSun: (json['distanceFromSun'] as num).toDouble(),
      diameter: (json['diameter'] as num).toDouble(),
      moons: json['moons'] as int,
      type: json['type'] as String,
      facts: Map<String, String>.from(json['facts'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'distanceFromSun': distanceFromSun,
      'diameter': diameter,
      'moons': moons,
      'type': type,
      'facts': facts,
    };
  }

  factory PlanetModel.fromEntity(Planet planet) {
    return PlanetModel(
      id: planet.id,
      name: planet.name,
      description: planet.description,
      imagePath: planet.imagePath,
      distanceFromSun: planet.distanceFromSun,
      diameter: planet.diameter,
      moons: planet.moons,
      type: planet.type,
      facts: planet.facts,
    );
  }
}
