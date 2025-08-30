import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'challenges_screen.dart';
import 'solar_system_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
      curve: Curves.easeOut,
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
        pageBuilder: (context, animation, secondaryAnimation) => const SolarSystemScreen(),
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

  void _navigateToChallenges() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ChallengesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
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
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Title
                          AnimatedBuilder(
                            animation: _titleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _titleAnimation.value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - _titleAnimation.value.clamp(0.0, 1.0))),
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
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Center Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Container(
                        padding: EdgeInsets.all(0),
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
                            
                            SizedBox(height: 60),
                            
                            // Description
                            Flexible(
                              child: Text(
                                'Descubra os mistérios do nosso sistema solar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
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
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Container(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Buttons Row
                            Row(
                              children: [
                                // Explore Button
                                Expanded(
                                  child: AnimatedBuilder(
                                    animation: _titleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _titleAnimation.value.clamp(0.0, 1.0),
                                        child: Container(
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
                                                        'EXPLORAR',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: math.max(MediaQuery.of(context).size.width * 0.04, 14),
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
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Challenges Button
                                Expanded(
                                  child: AnimatedBuilder(
                                    animation: _titleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _titleAnimation.value.clamp(0.0, 1.0),
                                        child: Container(
                                          height: math.max(MediaQuery.of(context).size.height * 0.07, 50),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFE65100),
                                                Color(0xFFFF6F00),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange.withValues(alpha: 0.4),
                                                blurRadius: 20,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(30),
                                              onTap: _navigateToChallenges,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.quiz,
                                                      color: Colors.white,
                                                      size: MediaQuery.of(context).size.width * 0.06,
                                                    ),
                                                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                                    Flexible(
                                                      child: Text(
                                                        'DESAFIOS',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: math.max(MediaQuery.of(context).size.width * 0.04, 14),
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
                                ),
                              ],
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
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width;
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
