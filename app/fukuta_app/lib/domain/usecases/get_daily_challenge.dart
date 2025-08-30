import '../entities/challenge.dart';
import '../repositories/challenge_repository.dart';

class GetDailyChallenge {
  final ChallengeRepository repository;

  GetDailyChallenge(this.repository);

  Future<Challenge> call() async {
    return await repository.getDailyChallenge();
  }
}
