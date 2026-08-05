class HomeProductModel {
  const HomeProductModel({
    required this.nameKey,
    required this.quantityKey,
    required this.imageAsset,
    required this.price,
    this.available = true,
  });

  final String nameKey;
  final String quantityKey;
  final String imageAsset;
  final String price;
  final bool available;
}
