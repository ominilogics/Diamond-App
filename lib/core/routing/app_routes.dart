enum AppRoute {
  login('/login'),
  signup('/signup'),
  forgotPassword('/forgot-password');

  const AppRoute(this.path);
  final String path;
}
