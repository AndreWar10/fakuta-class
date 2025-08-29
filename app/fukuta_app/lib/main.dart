import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'planet_images.dart';

void main() => runApp(const SolarSystemApp());

class SolarSystemApp extends StatelessWidget {
  const SolarSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const SpaceHomePage(),
    );
  }
}

class SpaceHomePage extends StatefulWidget {
  const SpaceHomePage({super.key});

  @override
  State<SpaceHomePage> createState() => _SpaceHomePageState();
}

class _SpaceHomePageState extends State<SpaceHomePage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _titleController;
  late AnimationController _particlesController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particlesController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _backgroundController.repeat(reverse: true);
    _titleController.forward();
    _particlesController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _titleController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _navigateToSolarSystem() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SolarSystemHomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
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

          // Floating Particles
          Positioned.fill(
            child: CustomPaint(
              painter: HomeParticlesPainter(
                animation: _particlesAnimation,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Top Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Container(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Title
                            AnimatedBuilder(
                              animation: _titleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _titleAnimation.value,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.rocket_launch,
                                        size: math.max(MediaQuery.of(context).size.width * 0.2, 60),
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                      Text(
                                        'EXPLORE',
                                        style: TextStyle(
                                          fontSize: math.max(MediaQuery.of(context).size.width * 0.12, 32),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 8,
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                      Text(
                                        'THE UNIVERSE',
                                        style: TextStyle(
                                          fontSize: math.max(MediaQuery.of(context).size.width * 0.06, 18),
                                          fontWeight: FontWeight.w300,
                                          color: Colors.blue[200],
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Container(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Floating Planet
                            AnimatedBuilder(
                              animation: _particlesAnimation,
                              builder: (context, child) {
                                final floatingOffset = math.sin(_particlesAnimation.value * 2 * math.pi) * 15;
                                                                 return Transform.translate(
                                   offset: Offset(0, floatingOffset),
                                   child: Container(
                                     width: math.min(MediaQuery.of(context).size.width * 0.5, 200),
                                     height: math.min(MediaQuery.of(context).size.width * 0.5, 200),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.blue.withValues(alpha: 0.3),
                                          Colors.purple.withValues(alpha: 0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.5),
                                          blurRadius: 50,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset('assets/astronaut/astronaut.png'),
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                            
                            // Description
                            Flexible(
                              child: Text(
                                'Descubra os mistérios do nosso sistema solar',
                                style: TextStyle(
                                  fontSize: math.max(MediaQuery.of(context).size.width * 0.045, 16),
                                  color: Colors.grey[300],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            
                            Flexible(
                              child: Text(
                                'Navegue pelos planetas e explore suas características únicas',
                                style: TextStyle(
                                  fontSize: math.max(MediaQuery.of(context).size.width * 0.035, 14),
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: Container(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Explore Button
                            AnimatedBuilder(
                              animation: _titleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _titleAnimation.value,
                                  child: Container(
                                    width: double.infinity,
                                    height: math.max(MediaQuery.of(context).size.height * 0.07, 50),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1A237E),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: _navigateToSolarSystem,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.explore,
                                                color: Colors.white,
                                                size: MediaQuery.of(context).size.width * 0.06,
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                              Flexible(
                                                child: Text(
                                                  'EXPLORAR SISTEMA SOLAR',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: math.max(MediaQuery.of(context).size.width * 0.045, 16),
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Home Particles
class HomeParticlesPainter extends CustomPainter {
  final Animation<double> animation;

  HomeParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 30; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 73) % size.height;
      final radius = 1.0 + (i % 3) * 0.5;
      
      // Animate particles
      final offsetX = math.sin(animation.value * 2 * math.pi + i) * 3;
      final offsetY = math.cos(animation.value * 2 * math.pi + i) * 3;
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }

    // Draw shooting stars
    final shootingStarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final startX = (i * 200) % size.width;
      final startY = (i * 100) % size.height;
      final endX = startX + 50;
      final endY = startY + 50;
      
      final progress = (animation.value + i * 0.3) % 1.0;
      final currentX = startX + (endX - startX) * progress;
      final currentY = startY + (endY - startY) * progress;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(currentX, currentY),
        shootingStarPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SolarSystemHomePage extends StatefulWidget {
  const SolarSystemHomePage({super.key});

  @override
  State<SolarSystemHomePage> createState() => _SolarSystemHomePageState();
}

class _SolarSystemHomePageState extends State<SolarSystemHomePage> {
  List<Planet> planets = [];
  bool isLoading = true;
  String? error;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  Future<void> fetchPlanets() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse('https://63ee56ee5e9f1583bdc10f2c.mockapi.io/api/v1/systemSolar'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Planet> fetchedPlanets = data.map((json) => Planet.fromJson(json)).toList();
        
        setState(() {
          planets = fetchedPlanets;
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
    setState(() {
        error = e.toString();
        isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A237E),
              Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sistema Solar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Explore os planetas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: fetchPlanets,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : error != null
                        ? Center(
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
                                  'Erro ao carregar dados',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: fetchPlanets,
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          )
                        : planets.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum planeta encontrado',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Column(
                                children: [
                                  // Planet Cards with Special Transitions
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        // Background Space Particles
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: SpaceParticlesPainter(
                                              currentIndex: currentIndex,
                                              totalPlanets: planets.length,
                                            ),
                                          ),
                                        ),
                                        // PageView with Enhanced Transitions
                                        PageView.builder(
                                          onPageChanged: (index) {
                                            setState(() {
                                              currentIndex = index;
                                            });
                                          },
                                          itemCount: planets.length,
                                          itemBuilder: (context, index) {
                                            return AnimatedBuilder(
                                              animation: PageController(),
                                              builder: (context, child) {
                                                final isActive = currentIndex == index;
                                                final progress = (currentIndex - index).abs();
                                                
                                                return Transform.rotate(
                                                  angle: isActive ? 0.0 : (currentIndex - index) * 0.1,
                                                  child: Transform.scale(
                                                    scale: isActive ? 1.0 : 0.85,
                                                    child: Opacity(
                                                      opacity: isActive ? 1.0 : 0.7 - (progress * 0.2),
                                                      child: Transform.translate(
                                                        offset: Offset(
                                                          (currentIndex - index) * 20,
                                                          0,
                                                        ),
                                                        child: PlanetCard(
                                                          planet: planets[index],
                                                          isActive: isActive,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Page Indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        planets.length,
                                        (index) => Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          width: currentIndex == index ? 20 : 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: currentIndex == index
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanetCard extends StatefulWidget {
  final Planet planet;
  final bool isActive;

  const PlanetCard({super.key, required this.planet, required this.isActive});

  @override
  State<PlanetCard> createState() => _PlanetCardState();
}

class _PlanetCardState extends State<PlanetCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.forward();
      _floatingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlanetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward();
      _floatingController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse();
      _floatingController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: widget.isActive ? 0.0 : _rotationAnimation.value,
              child: Card(
                elevation: 20 + (_glowAnimation.value * 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A237E).withValues(alpha: 0.8 + (_glowAnimation.value * 0.1)),
                        const Color(0xFF0A0E21).withValues(alpha: 0.9 + (_glowAnimation.value * 0.05)),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3 * _glowAnimation.value),
                        blurRadius: 20 + (_glowAnimation.value * 10),
                        spreadRadius: 5 + (_glowAnimation.value * 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Planet Image and Name
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Planet Image with Floating Animation
                              AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  final floatingOffset = math.sin(_floatingAnimation.value * 2 * math.pi) * 8;
                                  final horizontalOffset = math.cos(_floatingAnimation.value * 2 * math.pi) * 3;
                                  
                                  return Transform.translate(
                                    offset: Offset(horizontalOffset, floatingOffset),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withValues(alpha: 0.3 * _glowAnimation.value),
                                            blurRadius: 20 + (_glowAnimation.value * 10),
                                            spreadRadius: 5 + (_glowAnimation.value * 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: PlanetImageHelper.hasLocalImage(widget.planet.name)
                                            ? Image.asset(
                                                PlanetImageHelper.getImagePath(widget.planet.name),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildFallbackImage();
                                                },
                                              )
                                            : Image.network(
                                                widget.planet.images.png,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildFallbackImage();
                                                },
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              // Planet Name with Glow Effect
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 24 + (_glowAnimation.value * 2),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue.withValues(alpha: 0.8 * _glowAnimation.value),
                                      blurRadius: 10 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.planet.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Planet Type with Pulse Animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2 + (_glowAnimation.value * 0.1)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.5 + (_glowAnimation.value * 0.3)),
                                    width: 1 + (_glowAnimation.value * 0.5),
                                  ),
                                ),
                                child: Text(
                                  widget.planet.type,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[200],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Planet Details
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Resume with Fade Animation
                              AnimatedOpacity(
                                opacity: _glowAnimation.value,
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  height: 80,
                                  child: Text(
                                    widget.planet.resume,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[300],
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.justify,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Features Grid with Staggered Animation
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2.8,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildFeatureCard('Temperatura', widget.planet.features.temperature),
                                    _buildFeatureCard('Gravidade', widget.planet.features.gravity),
                                    _buildFeatureCard('Raio', widget.planet.features.radius),
                                    _buildFeatureCard('Satélites', '${widget.planet.features.satellites.number}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

    Widget _buildFeatureCard(String title, String value) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1 + (_glowAnimation.value * 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2 + (_glowAnimation.value * 0.1)),
              width: 1 + (_glowAnimation.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1 * _glowAnimation.value),
                blurRadius: 5 * _glowAnimation.value,
                spreadRadius: 1 * _glowAnimation.value,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13 + (_glowAnimation.value * 1),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.blue.withValues(alpha: 0.5 * _glowAnimation.value),
                        blurRadius: 3 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.public,
        size: 70,
        color: Colors.white,
      ),
    );
  }
}

// Data Models
class Planet {
  final String id;
  final String name;
  final String type;
  final String resume;
  final String introduction;
  final PlanetImages images;
  final List<String> searchTags;
  final PlanetFeatures features;
  final String geography;

  Planet({
    required this.id,
    required this.name,
    required this.type,
    required this.resume,
    required this.introduction,
    required this.images,
    required this.searchTags,
    required this.features,
    required this.geography,
  });

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      resume: json['resume'] ?? '',
      introduction: json['introduction'] ?? '',
      images: PlanetImages.fromJson(json['images'] ?? {}),
      searchTags: List<String>.from(json['searchTags'] ?? []),
      features: PlanetFeatures.fromJson(json['features'] ?? {}),
      geography: json['geography'] ?? '',
    );
  }
}

class PlanetImages {
  final String svg;
  final String png;

  PlanetImages({
    required this.svg,
    required this.png,
  });

  factory PlanetImages.fromJson(Map<String, dynamic> json) {
    return PlanetImages(
      svg: json['svg'] ?? '',
      png: json['png'] ?? '',
    );
  }
}

class PlanetFeatures {
  final List<String> orbitalPeriod;
  final String orbitalSpeed;
  final String rotationDuration;
  final String radius;
  final String diameter;
  final String sunDistance;
  final String oneWayLightToTheSun;
  final PlanetSatellites satellites;
  final String temperature;
  final String gravity;

  PlanetFeatures({
    required this.orbitalPeriod,
    required this.orbitalSpeed,
    required this.rotationDuration,
    required this.radius,
    required this.diameter,
    required this.sunDistance,
    required this.oneWayLightToTheSun,
    required this.satellites,
    required this.temperature,
    required this.gravity,
  });

  factory PlanetFeatures.fromJson(Map<String, dynamic> json) {
    return PlanetFeatures(
      orbitalPeriod: List<String>.from(json['orbitalPeriod'] ?? []),
      orbitalSpeed: json['orbitalSpeed'] ?? '',
      rotationDuration: json['rotationDuration'] ?? '',
      radius: json['radius'] ?? '',
      diameter: json['Diameter'] ?? '',
      sunDistance: json['sunDistance'] ?? '',
      oneWayLightToTheSun: json['oneWayLightToTheSun'] ?? '',
      satellites: PlanetSatellites.fromJson(json['satellites'] ?? {}),
      temperature: json['temperature'] ?? '',
      gravity: json['gravity'] ?? '',
    );
  }
}

class PlanetSatellites {
  final int number;
  final List<String> names;

  PlanetSatellites({
    required this.number,
    required this.names,
  });

  factory PlanetSatellites.fromJson(Map<String, dynamic> json) {
    return PlanetSatellites(
      number: json['number'] ?? 0,
      names: List<String>.from(json['names'] ?? []),
    );
  }
}

// Custom Painter for Space Particles Background
class SpaceParticlesPainter extends CustomPainter {
  final int currentIndex;
  final int totalPlanets;

  SpaceParticlesPainter({
    required this.currentIndex,
    required this.totalPlanets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 73) % size.height;
      final radius = 1.0 + (i % 3) * 0.5;
      
      // Animate particles based on current planet
      final offsetX = math.sin(DateTime.now().millisecondsSinceEpoch * 0.001 + i) * 2;
      final offsetY = math.cos(DateTime.now().millisecondsSinceEpoch * 0.001 + i) * 2;
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }

    // Draw orbital rings
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.4;
    
    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * (i + 1) / 3;
      final progress = (currentIndex / (totalPlanets - 1));
      final angle = progress * 2 * math.pi;
      
      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(center, radius, paint);
      
      // Draw moving dot on orbital ring
      final dotPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        3.0,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
