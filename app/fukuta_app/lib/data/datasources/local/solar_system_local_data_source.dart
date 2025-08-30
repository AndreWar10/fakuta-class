import '../../models/planet_model.dart';

abstract class SolarSystemLocalDataSource {
  Future<List<PlanetModel>> getCachedPlanets();
  Future<void> cachePlanets(List<PlanetModel> planets);
  Future<PlanetModel?> getCachedPlanet(String planetId);
  Future<void> clearCache();
}

class SolarSystemLocalDataSourceImpl implements SolarSystemLocalDataSource {
  // Cache em memória para simplicidade
  static List<PlanetModel>? _cachedPlanets;

  @override
  Future<List<PlanetModel>> getCachedPlanets() async {
    if (_cachedPlanets != null) {
      return _cachedPlanets!;
    }
    
    // Dados padrão do sistema solar
    _cachedPlanets = [
      PlanetModel(
        id: 'sun',
        name: 'Sol',
        description: 'Estrela central do nosso sistema solar, fonte de luz e energia para todos os planetas.',
        imagePath: 'assets/planets/sun.png',
        distanceFromSun: 0.0,
        diameter: 1392684.0,
        moons: 0,
        type: 'estrela',
        facts: {
          'Temperatura': '5.500°C na superfície',
          'Idade': '4.6 bilhões de anos',
          'Composição': 'Hidrogênio e Hélio',
          'Gravidade': '28x maior que a Terra',
        },
      ),
      PlanetModel(
        id: 'mercury',
        name: 'Mercúrio',
        description: 'O planeta mais próximo do Sol, com temperaturas extremas e superfície craterada.',
        imagePath: 'assets/planets/mercury.png',
        distanceFromSun: 57.9,
        diameter: 4879.0,
        moons: 0,
        type: 'terrestre',
        facts: {
          'Temperatura': '-180°C a 430°C',
          'Dia': '59 dias terrestres',
          'Ano': '88 dias terrestres',
          'Atmosfera': 'Praticamente inexistente',
        },
      ),
      PlanetModel(
        id: 'venus',
        name: 'Vênus',
        description: 'O planeta mais quente do sistema solar, com uma densa atmosfera de CO2.',
        imagePath: 'assets/planets/venus.png',
        distanceFromSun: 108.2,
        diameter: 12104.0,
        moons: 0,
        type: 'terrestre',
        facts: {
          'Temperatura': '462°C na superfície',
          'Pressão': '92x maior que a Terra',
          'Rotação': 'Retrógrada (sentido contrário)',
          'Nuvens': 'Ácido sulfúrico',
        },
      ),
      PlanetModel(
        id: 'earth',
        name: 'Terra',
        description: 'Nosso planeta natal, único conhecido com vida, água líquida e atmosfera rica em oxigênio.',
        imagePath: 'assets/planets/earth.png',
        distanceFromSun: 149.6,
        diameter: 12742.0,
        moons: 1,
        type: 'terrestre',
        facts: {
          'Temperatura': '-88°C a 58°C',
          'Água': '71% da superfície',
          'Atmosfera': '78% Nitrogênio, 21% Oxigênio',
          'Vida': 'Único planeta com vida conhecida',
        },
      ),
      PlanetModel(
        id: 'mars',
        name: 'Marte',
        description: 'O planeta vermelho, com montanhas gigantes, vales profundos e possíveis sinais de água.',
        imagePath: 'assets/planets/mars.png',
        distanceFromSun: 227.9,
        diameter: 6779.0,
        moons: 2,
        type: 'terrestre',
        facts: {
          'Temperatura': '-140°C a 20°C',
          'Monte Olimpo': 'Maior vulcão do sistema solar',
          'Atmosfera': '95% CO2, muito fina',
          'Exploração': 'Múltiplas missões ativas',
        },
      ),
      PlanetModel(
        id: 'jupiter',
        name: 'Júpiter',
        description: 'O maior planeta do sistema solar, um gigante gasoso com uma Grande Mancha Vermelha.',
        imagePath: 'assets/planets/jupiter.png',
        distanceFromSun: 778.5,
        diameter: 139820.0,
        moons: 79,
        type: 'gasoso',
        facts: {
          'Tamanho': '11x maior que a Terra',
          'Mancha Vermelha': 'Tempestade de 400 anos',
          'Anéis': 'Muito tênues',
          'Campo Magnético': '14x mais forte que a Terra',
        },
      ),
      PlanetModel(
        id: 'saturn',
        name: 'Saturno',
        description: 'Famoso por seus anéis espetaculares, o segundo maior planeta do sistema solar.',
        imagePath: 'assets/planets/saturn.png',
        distanceFromSun: 1434.0,
        diameter: 116460.0,
        moons: 82,
        type: 'gasoso',
        facts: {
          'Anéis': '7 anéis principais',
          'Densidade': 'Menor que a água',
          'Tempestades': 'Hexágono no polo norte',
          'Exploração': 'Cassini estudou por 13 anos',
        },
      ),
      PlanetModel(
        id: 'uranus',
        name: 'Urano',
        description: 'Planeta gelado com eixo de rotação inclinado, girando de lado.',
        imagePath: 'assets/planets/uranus.png',
        distanceFromSun: 2871.0,
        diameter: 50724.0,
        moons: 27,
        type: 'gasoso',
        facts: {
          'Inclinação': '98° (gira de lado)',
          'Temperatura': '-224°C',
          'Anéis': '13 anéis escuros',
          'Descoberta': 'Primeiro planeta descoberto por telescópio',
        },
      ),
      PlanetModel(
        id: 'neptune',
        name: 'Netuno',
        description: 'O planeta mais distante do Sol, com ventos ultrarrápidos e tempestades intensas.',
        imagePath: 'assets/planets/neptune.png',
        distanceFromSun: 4495.0,
        diameter: 49244.0,
        moons: 14,
        type: 'gasoso',
        facts: {
          'Ventos': 'Até 2.100 km/h',
          'Temperatura': '-218°C',
          'Anéis': '6 anéis principais',
          'Exploração': 'Voyager 2 visitou em 1989',
        },
      ),
      PlanetModel(
        id: 'pluto',
        name: 'Plutão',
        description: 'Planeta anão gelado no Cinturão de Kuiper, com uma órbita excêntrica.',
        imagePath: 'assets/planets/pluto.png',
        distanceFromSun: 5906.0,
        diameter: 2370.0,
        moons: 5,
        type: 'anão',
        facts: {
          'Status': 'Reclassificado como planeta anão em 2006',
          'Órbita': 'Muito excêntrica',
          'Temperatura': '-240°C',
          'Lua': 'Caronte é quase do mesmo tamanho',
        },
      ),
    ];
    
    return _cachedPlanets!;
  }

  @override
  Future<void> cachePlanets(List<PlanetModel> planets) async {
    _cachedPlanets = planets;
  }

  @override
  Future<PlanetModel?> getCachedPlanet(String planetId) async {
    final planets = await getCachedPlanets();
    try {
      return planets.firstWhere((planet) => planet.id == planetId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedPlanets = null;
  }
}
