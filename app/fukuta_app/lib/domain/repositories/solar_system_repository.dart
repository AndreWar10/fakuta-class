import '../entities/solar_system.dart';
import '../entities/planet.dart';

abstract class SolarSystemRepository {
  Future<SolarSystem> getSolarSystem();
  Future<Planet> getPlanetById(String planetId);
  Future<List<Planet>> getAllPlanets();
  Future<List<Planet>> getPlanetsByType(String type);
  Future<void> updatePlanetInfo(String planetId, Map<String, dynamic> updates);
}
