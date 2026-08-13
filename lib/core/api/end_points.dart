class EndPoints {
  static const String baseUrl = "https://bb2.sapapi.muntajat.sa";
  static const String requestOtp = '$baseUrl/api/b2b/v1/auth/otp/request';
  static const String verifyOtp = '$baseUrl/api/b2b/v1/auth/otp/verify';
  static const String logout = '$baseUrl/api/b2b/v1/auth/logout';
  static const String registration = '$baseUrl/api/b2b/v1/registration';
  static const String profile = '$baseUrl/api/b2b/v1/profile';
  static const String profileCredit = '$profile/credit';
  static const String profileAddresses = '$profile/addresses';
  static const String addresses = '$baseUrl/api/b2b/v1/addresses';
  static const String addressCities = '$addresses/cities';
  static const String home = '$baseUrl/api/b2b/v1/home';
  static const String categories = '$baseUrl/api/b2b/v1/categories';
  static const String expiryOffers = '$baseUrl/api/b2b/v1/offers/expiry';
  static const String catalogProducts = '$baseUrl/api/b2b/v1/catalog/products';
  static const String cart = '$baseUrl/api/b2b/v1/cart';
  static const String cartItems = '$cart/items';
  static const String orders = '$baseUrl/api/b2b/v1/orders';
  static const String finance = '$baseUrl/api/b2b/v1/finance';
  static const String financeSummary = '$finance/summary';
  static const String financeAging = '$finance/aging';
  static const String financeStatement = '$finance/statement';
  static const String financePayments = '$finance/payments';
  static const String financeCreditNotes = '$finance/credit-notes';
  static const String financeInvoices = '$finance/invoices';
  static const String reports = '$baseUrl/api/b2b/v1/reports';
  static const String savedReports = '$reports/saved';
  static const String reportRuns = '$reports/runs';
  static const String returns = '$baseUrl/api/b2b/v1/returns';
  static const String returnReasons = '$returns/reasons';
  static const String eligibleReturnOrders = '$returns/eligible-orders';
  static const String reorder = '$baseUrl/api/b2b/v1/reorder';
  static const String reorderMyProducts = '$reorder/my-products';
  static const String reorderDue = '$reorder/due';

  static String productDetails(String itemCode) =>
      '$catalogProducts/${Uri.encodeComponent(itemCode)}';

  static String addressDetails(Object id) => '$addresses/$id';

  static String preferredAddress(Object id) =>
      '${addressDetails(id)}/preferred';

  static String cartItem(String itemCode) =>
      '$cartItems/${Uri.encodeComponent(itemCode)}';

  static String orderDetails(String orderNumber) =>
      '$orders/${Uri.encodeComponent(orderNumber)}';

  static String cancelOrder(String orderNumber) =>
      '${orderDetails(orderNumber)}/cancel';

  static String financeInvoiceDetails(String docNum) =>
      '$financeInvoices/${Uri.encodeComponent(docNum)}';

  static String savedReport(Object id) => '$savedReports/$id';

  static String report(String type) => '$reports/${Uri.encodeComponent(type)}';

  static String exportReport(String type) => '${report(type)}/export';

  static String downloadReportRun(Object id) => '$reportRuns/$id/download';

  static String returnOrderLines(String orderNumber) =>
      '$returns/orders/${Uri.encodeComponent(orderNumber)}/lines';

  static String returnDetails(String reference) =>
      '$returns/${Uri.encodeComponent(reference)}';
  // static const String baseUrl = "https://waqty.alemtayaz.shop/public";
  // static const String _imageBaseUrl = "storage/app/public/";

  // String getImageFromApi(String imageUrl) {
  //   return baseUrl + _imageBaseUrl + imageUrl;
  // }
}
