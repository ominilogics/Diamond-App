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

class PaymentFailure extends Failure {
  final bool isCancelled;
  PaymentFailure(super.message, {this.isCancelled = false});
}

class SmsFailure extends Failure {
  SmsFailure(super.message);
}
