import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/solar_system_provider.dart';
import '../widgets/planet_card.dart';
import '../widgets/planet_details_modal.dart';
import '../widgets/solar_system_header.dart';
import '../../domain/entities/planet.dart';

class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _planetsController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _planetsAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _planetsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _planetsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _planetsController,
      curve: Curves.elasticOut,
    ));

    _backgroundController.repeat(reverse: true);
    _planetsController.forward();
    
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SolarSystemProvider>();
      provider.loadSolarSystem();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _planetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Consumer<SolarSystemProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Animated Background
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A0E21),
                          Color.lerp(
                            const Color(0xFF0A0E21),
                            const Color(0xFF1A237E),
                            _backgroundAnimation.value,
                          )!,
                          const Color(0xFF0A0E21),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    SolarSystemHeader(
                      onBackPressed: () => Navigator.of(context).pop(),
                      onFilterChanged: provider.filterPlanetsByType,
                      currentFilter: provider.currentFilter,
                    ),

                    // Content
                    Expanded(
                      child: _buildContent(provider),
                    ),
                  ],
                ),
              ),

              // Loading Overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),

              // Error Overlay
              if (provider.error != null)
                _buildErrorOverlay(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(SolarSystemProvider provider) {
    if (provider.error != null) {
      return _buildErrorContent(provider.error!);
    }

    if (!provider.hasSolarSystem) {
      return const Center(
        child: Text(
          'Carregando sistema solar...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _planetsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _planetsAnimation.value.clamp(0.0, 1.0),
          child: Opacity(
            opacity: _planetsAnimation.value.clamp(0.0, 1.0),
            child: _buildPlanetsGrid(provider),
          ),
        );
      },
    );
  }

  Widget _buildPlanetsGrid(SolarSystemProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.filteredPlanets.length,
      itemBuilder: (context, index) {
        final planet = provider.filteredPlanets[index];
        return PlanetCard(
          planet: planet,
          onTap: () => _showPlanetDetails(planet, provider),
        );
      },
    );
  }

  Widget _buildErrorContent(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar sistema solar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<SolarSystemProvider>();
                provider.loadSolarSystem();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(SolarSystemProvider provider) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                // Clear error
                provider.clearSelection();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanetDetails(Planet planet, SolarSystemProvider provider) {
    provider.selectPlanet(planet.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlanetDetailsModal(planet: planet),
    );
  }
}
