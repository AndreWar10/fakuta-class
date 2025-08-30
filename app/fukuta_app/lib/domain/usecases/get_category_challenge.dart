import '../../domain/entities/challenge.dart';
import '../../domain/repositories/challenge_repository.dart';

class GetCategoryChallenge {
  final ChallengeRepository challengeRepository;

  GetCategoryChallenge(this.challengeRepository);

  Future<Challenge> call(String category) async {
    return await challengeRepository.getCategoryChallenge(category);
  }
}
