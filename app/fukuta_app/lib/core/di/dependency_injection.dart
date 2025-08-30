import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/remote/challenge_remote_data_source.dart';
import '../../data/datasources/local/challenge_local_data_source.dart';
import '../../data/repositories/challenge_repository_impl.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../data/repositories/user_progress_repository_impl.dart';
import '../../domain/usecases/get_daily_challenge.dart';
import '../../domain/usecases/get_quick_challenge.dart';
import '../../domain/usecases/submit_challenge_answer.dart';
import '../../domain/usecases/get_user_achievements.dart';
import '../../presentation/providers/challenge_provider.dart';

class DependencyInjection {
  static Widget buildProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        // Data Sources
        Provider<ChallengeRemoteDataSource>(
          create: (_) => ChallengeRemoteDataSourceImpl(),
        ),
        Provider<ChallengeLocalDataSource>(
          create: (_) => ChallengeLocalDataSourceImpl(),
        ),
        
        // Repositories
        Provider<ChallengeRepositoryImpl>(
          create: (context) => ChallengeRepositoryImpl(
            context.read<ChallengeRemoteDataSource>(),
            context.read<ChallengeLocalDataSource>(),
          ),
        ),
        Provider<AchievementRepositoryImpl>(
          create: (context) => AchievementRepositoryImpl(
            context.read<ChallengeRemoteDataSource>(),
            context.read<ChallengeLocalDataSource>(),
          ),
        ),
        Provider<UserProgressRepositoryImpl>(
          create: (context) => UserProgressRepositoryImpl(
            context.read<ChallengeLocalDataSource>(),
          ),
        ),
        
        // Use Cases
        Provider<GetDailyChallenge>(
          create: (context) => GetDailyChallenge(
            context.read<ChallengeRepositoryImpl>(),
          ),
        ),
        Provider<GetQuickChallenge>(
          create: (context) => GetQuickChallenge(
            context.read<ChallengeRepositoryImpl>(),
          ),
        ),
        Provider<SubmitChallengeAnswer>(
          create: (context) => SubmitChallengeAnswer(
            context.read<ChallengeRepositoryImpl>(),
            context.read<UserProgressRepositoryImpl>(),
          ),
        ),
        Provider<GetUserAchievements>(
          create: (context) => GetUserAchievements(
            context.read<AchievementRepositoryImpl>(),
            context.read<UserProgressRepositoryImpl>(),
          ),
        ),
        
        // Main Provider
        ChangeNotifierProvider<ChallengeProvider>(
          create: (context) => ChallengeProvider(
            getDailyChallenge: context.read<GetDailyChallenge>(),
            getQuickChallenge: context.read<GetQuickChallenge>(),
            submitChallengeAnswer: context.read<SubmitChallengeAnswer>(),
            getUserAchievements: context.read<GetUserAchievements>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
