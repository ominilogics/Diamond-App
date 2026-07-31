enum AppRoute {
  splash('/splash'),
  onboarding('/onboarding'),
  login('/login'),
  signup('signup'),
  forgotPassword('forgot-password'),
  main('/main'),
  notifications('/notifications'),
  cards('/cards'),
  events('/events'),
  privacyPolicy('/privacy-policy'),
  termsAndConditions('/terms-and-conditions'),
  testing('/testing'),
  editProfile('/edit-profile'),
  cardDetail('/card-detail'),
  previewCard('/preview-card'),
  editCard('/edit-card'),
  notificationSettings('/notification-settings'),
  orderHistory('/orderHistory'),
  subscription('/subscription'),
  myDrafts('/my-drafts'),
  adminDashboard('/admin-dashboard'),
  openCard('/open');

  const AppRoute(this.path);
  final String path;
}
