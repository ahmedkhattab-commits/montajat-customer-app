class EndPoints {
  static const String baseUrl = "https://bb2.sapapi.muntajat.sa";
  static const String requestOtp = '$baseUrl/api/b2b/v1/auth/otp/request';
  static const String verifyOtp = '$baseUrl/api/b2b/v1/auth/otp/verify';
  static const String logout = '$baseUrl/api/b2b/v1/auth/logout';
  static const String profile = '$baseUrl/api/b2b/v1/profile';
  static const String profileCredit = '$profile/credit';
  static const String profileAddresses = '$profile/addresses';
  static const String addresses = '$baseUrl/api/b2b/v1/addresses';
  static const String addressCities = '$addresses/cities';
  static const String home = '$baseUrl/api/b2b/v1/home';
  static const String categories = '$baseUrl/api/b2b/v1/categories';
  static const String expiryOffers = '$baseUrl/api/b2b/v1/offers/expiry';
  static const String catalogProducts = '$baseUrl/api/b2b/v1/catalog/products';

  static String productDetails(String itemCode) =>
      '$catalogProducts/${Uri.encodeComponent(itemCode)}';

  static String addressDetails(Object id) => '$addresses/$id';

  static String preferredAddress(Object id) =>
      '${addressDetails(id)}/preferred';
  // static const String baseUrl = "https://waqty.alemtayaz.shop/public";
  // static const String _imageBaseUrl = "storage/app/public/";

  // String getImageFromApi(String imageUrl) {
  //   return baseUrl + _imageBaseUrl + imageUrl;
  // }
}
