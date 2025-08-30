import '../entities/solar_system.dart';
import '../repositories/solar_system_repository.dart';

class GetSolarSystem {
  final SolarSystemRepository repository;

  GetSolarSystem(this.repository);

  Future<SolarSystem> call() async {
    return await repository.getSolarSystem();
  }
}
