import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/remote/challenge_remote_data_source.dart';
import '../../data/datasources/remote/user_progress_remote_data_source.dart';
import '../../data/datasources/local/challenge_local_data_source.dart';
import '../../data/datasources/local/solar_system_local_data_source.dart';
import '../../data/repositories/challenge_repository_impl.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../data/repositories/user_progress_repository_impl.dart';
import '../../data/repositories/solar_system_repository_impl.dart';
import '../../domain/usecases/get_daily_challenge.dart';
import '../../domain/usecases/get_quick_challenge.dart';
import '../../domain/usecases/get_category_challenge.dart';
import '../../domain/usecases/submit_challenge_answer.dart';
import '../../domain/usecases/get_user_achievements.dart';
import '../../domain/usecases/get_solar_system.dart';
import '../../domain/usecases/get_planet_details.dart';
import '../../presentation/providers/challenge_provider.dart';
import '../../presentation/providers/solar_system_provider.dart';

class DependencyInjection {
  static Widget buildProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        // Data Sources
        Provider<ChallengeRemoteDataSource>(
          create: (_) => ChallengeRemoteDataSourceImpl(),
        ),
        Provider<UserProgressRemoteDataSource>(
          create: (_) => UserProgressRemoteDataSourceImpl(),
        ),
        Provider<ChallengeLocalDataSource>(
          create: (_) => ChallengeLocalDataSourceImpl(),
        ),
        Provider<SolarSystemLocalDataSource>(
          create: (_) => SolarSystemLocalDataSourceImpl(),
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
            context.read<UserProgressRemoteDataSource>(),
          ),
        ),
        Provider<SolarSystemRepositoryImpl>(
          create: (context) => SolarSystemRepositoryImpl(
            context.read<SolarSystemLocalDataSource>(),
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
        Provider<GetCategoryChallenge>(
          create: (context) => GetCategoryChallenge(
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
        Provider<GetSolarSystem>(
          create: (context) => GetSolarSystem(
            context.read<SolarSystemRepositoryImpl>(),
          ),
        ),
        Provider<GetPlanetDetails>(
          create: (context) => GetPlanetDetails(
            context.read<SolarSystemRepositoryImpl>(),
          ),
        ),
        
        // Main Providers
        ChangeNotifierProvider<ChallengeProvider>(
          create: (context) => ChallengeProvider(
            getDailyChallenge: context.read<GetDailyChallenge>(),
            getQuickChallenge: context.read<GetQuickChallenge>(),
            getCategoryChallenge: context.read<GetCategoryChallenge>(),
            submitChallengeAnswer: context.read<SubmitChallengeAnswer>(),
            getUserAchievements: context.read<GetUserAchievements>(),
            userProgressRepository: context.read<UserProgressRepositoryImpl>(),
          ),
        ),
        ChangeNotifierProvider<SolarSystemProvider>(
          create: (context) => SolarSystemProvider(
            getSolarSystem: context.read<GetSolarSystem>(),
            getPlanetDetails: context.read<GetPlanetDetails>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
