class SplashContentModel {
  const SplashContentModel({
    required this.assetPath,
    required this.designWidth,
    required this.designHeight,
  });

  final String assetPath;
  final double designWidth;
  final double designHeight;

  static const SplashContentModel defaultContent = SplashContentModel(
    assetPath: 'assets/images/splash/splash_screen.png',
    designWidth: 428,
    designHeight: 882,
  );
}
