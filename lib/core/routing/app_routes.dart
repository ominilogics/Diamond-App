enum AppRoute {
  login('/login'),
  signup('/signup'),
  forgotPassword('/forgot-password'),
  main('/main'),
  notifications('/notifications'),
  cards('/cards'),
  testing('/testing'),
  editProfile('/edit-profile');

  const AppRoute(this.path);
  final String path;
}
