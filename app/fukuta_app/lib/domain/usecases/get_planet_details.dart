import '../entities/planet.dart';
import '../repositories/solar_system_repository.dart';

class GetPlanetDetails {
  final SolarSystemRepository repository;

  GetPlanetDetails(this.repository);

  Future<Planet> call(String planetId) async {
    return await repository.getPlanetById(planetId);
  }
}
