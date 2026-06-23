class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isLeft;

  Either.left(this._left) : isLeft = true, _right = null;
  Either.right(this._right) : isLeft = false, _left = null;

  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    if (isLeft) return leftFn(_left as L);
    return rightFn(_right as R);
  }
}
