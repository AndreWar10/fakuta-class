import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_progress.dart';
import 'widgets/challenge_card.dart';
import 'widgets/progress_card.dart';
import 'widgets/achievement_card.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _cardsController = AnimationController(
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

    _cardsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.elasticOut,
    ));

    _backgroundController.repeat(reverse: true);
    _cardsController.forward();
    
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChallengeProvider>();
      provider.loadUserProgress();
      provider.loadAchievements();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, child) {
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
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(provider),
                  ),
                  
                  // Progress Card
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _cardsAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardsAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ProgressCard(
                              userProgress: provider.userProgress,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Challenges Section
                  SliverToBoxAdapter(
                    child: _buildChallengesSection(provider),
                  ),
                  
                  // Achievements Section
                  SliverToBoxAdapter(
                    child: _buildAchievementsSection(provider),
                  ),
                  
                  // Bottom Spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ChallengeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desafios Espaciais',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Teste seu conhecimento sobre o universo!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  value: provider.userProgress?.totalPoints.toString() ?? '0',
                  label: 'Pontos',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: provider.userProgress?.correctAnswers.toString() ?? '0',
                  label: 'Acertos',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  value: provider.achievements.length.toString(),
                  label: 'Conquistas',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(ChallengeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Escolha seu Desafio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Daily Challenge
          ChallengeCard(
            title: 'Desafio Diário',
            subtitle: 'Uma pergunta especial para hoje!',
            icon: '🌅',
            color: Colors.blue,
            onTap: () => provider.loadDailyChallenge(),
            isAvailable: true,
          ),
          
          const SizedBox(height: 12),
          
          // Quick Challenge
          ChallengeCard(
            title: 'Desafio Rápido',
            subtitle: '3 perguntas para testar seu conhecimento!',
            icon: '⚡',
            color: Colors.green,
            onTap: () => provider.loadQuickChallenge(),
            isAvailable: true,
          ),
          
          const SizedBox(height: 12),
          
          // Category Challenges
          _buildCategoryChallenges(),
        ],
      ),
    );
  }

  Widget _buildCategoryChallenges() {
    final categories = ['Planetas', 'Sistema Solar', 'Temperatura', 'Astronomia'];
    final colors = [Colors.purple, Colors.orange, Colors.red, Colors.teal];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 Por Categoria',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: ChallengeCard(
                  title: categories[index],
                  subtitle: 'Perguntas sobre ${categories[index]}',
                  icon: '🌍',
                  color: colors[index],
                  onTap: () {
                    // Implementar desafio por categoria
                  },
                  isAvailable: true,
                  isCompact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(ChallengeProvider provider) {
    if (provider.achievements.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Suas Conquistas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.achievements.length,
              itemBuilder: (context, index) {
                final achievement = provider.achievements[index];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  child: AchievementCard(
                    achievement: achievement,
                    userProgress: provider.userProgress,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
