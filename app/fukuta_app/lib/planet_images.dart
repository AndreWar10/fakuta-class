class PlanetImageHelper {
  static const Map<String, String> planetImageMap = {
    'Sol': 'assets/planets/sun.png',
    'Mercúrio': 'assets/planets/mercury.png',
    'Vênus': 'assets/planets/venus.png',
    'Terra': 'assets/planets/earth.png',
    'Marte': 'assets/planets/mars.png',
    'Júpiter': 'assets/planets/jupiter.png',
    'Saturno': 'assets/planets/saturn.png',
    'Urano': 'assets/planets/uranus.png',
    'Netuno': 'assets/planets/neptune.png',
    'Plutão': 'assets/planets/pluto.png',
  };

  static String getImagePath(String planetName) {
    return planetImageMap[planetName] ?? 'assets/planets/planet_default.png';
  }

  static bool hasLocalImage(String planetName) {
    return planetImageMap.containsKey(planetName);
  }
}
