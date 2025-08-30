import 'package:flutter/material.dart';
import '../../domain/entities/solar_system.dart';
import '../../domain/entities/planet.dart';
import '../../domain/usecases/get_solar_system.dart';
import '../../domain/usecases/get_planet_details.dart';

class SolarSystemProvider extends ChangeNotifier {
  final GetSolarSystem getSolarSystem;
  final GetPlanetDetails getPlanetDetails;

  SolarSystemProvider({
    required this.getSolarSystem,
    required this.getPlanetDetails,
  });

  // Estado
  SolarSystem? _solarSystem;
  Planet? _selectedPlanet;
  bool _isLoading = false;
  String? _error;
  List<Planet> _filteredPlanets = [];
  String _currentFilter = 'all';

  // Getters
  SolarSystem? get solarSystem => _solarSystem;
  Planet? get selectedPlanet => _selectedPlanet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Planet> get filteredPlanets => _filteredPlanets;
  String get currentFilter => _currentFilter;
  bool get hasSolarSystem => _solarSystem != null;

  // Métodos
  Future<void> loadSolarSystem() async {
    _setLoading(true);
    _clearError();
    
    try {
      _solarSystem = await getSolarSystem();
      _filteredPlanets = _solarSystem!.planets;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar sistema solar: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectPlanet(String planetId) async {
    try {
      _selectedPlanet = await getPlanetDetails(planetId);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar detalhes do planeta: $e');
    }
  }

  void filterPlanetsByType(String type) {
    _currentFilter = type;
    
    if (type == 'all') {
      _filteredPlanets = _solarSystem?.planets ?? [];
    } else {
      _filteredPlanets = _solarSystem?.planets
          .where((planet) => planet.type == type)
          .toList() ?? [];
    }
    
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlanet = null;
    notifyListeners();
  }

  List<Planet> getPlanetsByType(String type) {
    return _solarSystem?.planets
        .where((planet) => planet.type == type)
        .toList() ?? [];
  }

  Planet? getClosestPlanet() {
    return _solarSystem?.getClosestPlanet();
  }

  Planet? getFarthestPlanet() {
    return _solarSystem?.getFarthestPlanet();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
