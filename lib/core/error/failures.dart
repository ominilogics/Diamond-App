abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}
