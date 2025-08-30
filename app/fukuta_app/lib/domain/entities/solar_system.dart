import 'planet.dart';

class SolarSystem {
  final String id;
  final String name;
  final String description;
  final List<Planet> planets;
  final DateTime lastUpdated;

  SolarSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.planets,
    required this.lastUpdated,
  });

  Planet? getPlanetById(String planetId) {
    try {
      return planets.firstWhere((planet) => planet.id == planetId);
    } catch (e) {
      return null;
    }
  }

  List<Planet> getPlanetsByType(String type) {
    return planets.where((planet) => planet.type == type).toList();
  }

  Planet? getClosestPlanet() {
    if (planets.isEmpty) return null;
    return planets.reduce((a, b) => 
      a.distanceFromSun < b.distanceFromSun ? a : b);
  }

  Planet? getFarthestPlanet() {
    if (planets.isEmpty) return null;
    return planets.reduce((a, b) => 
      a.distanceFromSun > b.distanceFromSun ? a : b);
  }
}
