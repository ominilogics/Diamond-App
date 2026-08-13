import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signIn(String email, String password);
  Future<Either<Failure, void>> signUp(
    String email,
    String password,
    String fullName, {
    String? dateOfBirth,
  });
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> updateProfile(
    String fullName, {
    String? dateOfBirth,
  });
  Future<Either<Failure, void>> deleteAccount({Function(String)? onProgress});
}
