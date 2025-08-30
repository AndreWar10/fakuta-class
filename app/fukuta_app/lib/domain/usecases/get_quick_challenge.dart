import '../entities/challenge.dart';
import '../repositories/challenge_repository.dart';

class GetQuickChallenge {
  final ChallengeRepository repository;

  GetQuickChallenge(this.repository);

  Future<Challenge> call() async {
    return await repository.getQuickChallenge();
  }
}
