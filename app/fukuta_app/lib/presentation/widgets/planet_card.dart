import 'package:flutter/material.dart';
import '../../domain/entities/planet.dart';

class PlanetCard extends StatefulWidget {
  final Planet planet;
  final VoidCallback onTap;

  const PlanetCard({
    super.key,
    required this.planet,
    required this.onTap,
  });

  @override
  State<PlanetCard> createState() => _PlanetCardState();
}

class _PlanetCardState extends State<PlanetCard>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controller para flutuação (cima/baixo e lados)
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3), // 3 segundos para um ciclo de flutuação
      vsync: this,
    );
    
    // Animação de flutuação com Curves.easeInOut para movimento suave
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Inicia a animação
    _floatingController.repeat(reverse: true); // Vai e volta para criar movimento flutuante
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getPlanetColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: PlanetPatternPainter(),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento à esquerda
                  children: [
                    // Planet Image with Floating Animation
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft, // Alinha à esquerda
                        child: AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            // Calcula o offset de flutuação
                            final floatingOffsetX = (0.5 - _floatingAnimation.value) * 8; // Movimento lateral de ±4px
                            final floatingOffsetY = (0.5 - _floatingAnimation.value) * 6; // Movimento vertical de ±3px
                            
                            return Transform.translate(
                              offset: Offset(floatingOffsetX, floatingOffsetY),
                              child: Image.asset(
                                widget.planet.imagePath,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getPlanetIcon(),
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Planet Info - Alinhado à esquerda
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento à esquerda
                      children: [
                        Text(
                          widget.planet.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left, // Alinhamento de texto à esquerda
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.planet.type.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left, // Alinhamento de texto à esquerda
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${widget.planet.distanceFromSun.toStringAsFixed(1)}M km',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left, // Alinhamento de texto à esquerda
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  List<Color> _getPlanetColors() {
    switch (widget.planet.type.toLowerCase()) {
      case 'terrestre':
        return [
          const Color(0xFF8D6E63),
          const Color(0xFF6D4C41),
        ];
      case 'gasoso':
        return [
          const Color(0xFF42A5F5),
          const Color(0xFF1976D2),
        ];
      case 'anão':
        return [
          const Color(0xFF9E9E9E),
          const Color(0xFF757575),
        ];
      default:
        return [
          const Color(0xFF9C27B0),
          const Color(0xFF7B1FA2),
        ];
    }
  }

  IconData _getPlanetIcon() {
    switch (widget.planet.type.toLowerCase()) {
      case 'terrestre':
        return Icons.public;
      case 'gasoso':
        return Icons.cloud;
      case 'anão':
        return Icons.radio_button_unchecked;
      default:
        return Icons.public;
    }
  }
}

class PlanetPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw some decorative lines
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i < 5; i++) {
      final x = (size.width / 5) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
