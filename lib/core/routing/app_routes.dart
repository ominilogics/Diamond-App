enum AppRoute {
  login('/login'),
  signup('/signup'),
  forgotPassword('/forgot-password'),
  main('/main');

  const AppRoute(this.path);
  final String path;
}
