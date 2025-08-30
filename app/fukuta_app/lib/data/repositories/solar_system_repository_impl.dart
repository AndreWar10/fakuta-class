import '../../domain/entities/solar_system.dart';
import '../../domain/entities/planet.dart';
import '../../domain/repositories/solar_system_repository.dart';
import '../datasources/local/solar_system_local_data_source.dart';
import '../models/planet_model.dart';

class SolarSystemRepositoryImpl implements SolarSystemRepository {
  final SolarSystemLocalDataSource localDataSource;

  SolarSystemRepositoryImpl(this.localDataSource);

  @override
  Future<SolarSystem> getSolarSystem() async {
    try {
      final planets = await localDataSource.getCachedPlanets();
      
      return SolarSystem(
        id: 'solar_system_001',
        name: 'Sistema Solar',
        description: 'Nosso sistema planetário localizado na Via Láctea, composto pelo Sol e todos os objetos que orbitam ao seu redor.',
        planets: planets,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao carregar sistema solar: $e');
    }
  }

  @override
  Future<Planet> getPlanetById(String planetId) async {
    try {
      final planet = await localDataSource.getCachedPlanet(planetId);
      if (planet == null) {
        throw Exception('Planeta não encontrado: $planetId');
      }
      return planet;
    } catch (e) {
      throw Exception('Erro ao buscar planeta: $e');
    }
  }

  @override
  Future<List<Planet>> getAllPlanets() async {
    try {
      return await localDataSource.getCachedPlanets();
    } catch (e) {
      throw Exception('Erro ao carregar planetas: $e');
    }
  }

  @override
  Future<List<Planet>> getPlanetsByType(String type) async {
    try {
      final planets = await localDataSource.getCachedPlanets();
      return planets.where((planet) => planet.type == type).toList();
    } catch (e) {
      throw Exception('Erro ao filtrar planetas por tipo: $e');
    }
  }

  @override
  Future<void> updatePlanetInfo(String planetId, Map<String, dynamic> updates) async {
    try {
      final planets = await localDataSource.getCachedPlanets();
      final planetIndex = planets.indexWhere((planet) => planet.id == planetId);
      
      if (planetIndex == -1) {
        throw Exception('Planeta não encontrado: $planetId');
      }
      
      // Criar novo planeta com as atualizações
      final currentPlanet = planets[planetIndex];
      final updatedPlanet = PlanetModel(
        id: currentPlanet.id,
        name: updates['name'] ?? currentPlanet.name,
        description: updates['description'] ?? currentPlanet.description,
        imagePath: updates['imagePath'] ?? currentPlanet.imagePath,
        distanceFromSun: updates['distanceFromSun'] ?? currentPlanet.distanceFromSun,
        diameter: updates['diameter'] ?? currentPlanet.diameter,
        moons: updates['moons'] ?? currentPlanet.moons,
        type: updates['type'] ?? currentPlanet.type,
        facts: updates['facts'] ?? currentPlanet.facts,
      );
      
      planets[planetIndex] = updatedPlanet;
      await localDataSource.cachePlanets(planets);
    } catch (e) {
      throw Exception('Erro ao atualizar planeta: $e');
    }
  }
}
