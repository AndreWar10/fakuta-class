import 'package:flutter/material.dart';
import 'core/config/hive_config.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.initialize();
  runApp(const SolarSystemApp());
}

class SolarSystemApp extends StatelessWidget {
  const SolarSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DependencyInjection.buildProviders(
      child: MaterialApp(
        title: 'Sistema Solar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
