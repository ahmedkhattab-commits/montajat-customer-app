import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';

void main() {
  test('loads category products with pagination', () async {
    final consumer = _FakeApiConsumer(_response);
    final result = await RemoteProductsRepository(consumer).getProducts(
      filter: const ProductsScreenArguments(
        source: ProductsFilterSource.category,
        filterValue: 'Food',
        title: 'Food',
      ),
      page: 2,
    );

    final uri = Uri.parse(consumer.lastPath!);
    expect(uri.queryParameters['category'], 'Food');
    expect(uri.queryParameters['page'], '2');
    expect(uri.queryParameters['per_page'], '20');
    expect(result.currentPage, 2);
    expect(result.hasMore, isTrue);
    expect(result.items.single.itemCode, 'P16100035');
    expect(result.items.single.name, isNull);
    expect(result.items.single.price, isNull);
    expect(result.items.single.availableQuantity, 25);
  });

  test('loads brand products using brand_code', () async {
    final consumer = _FakeApiConsumer(_response);
    await RemoteProductsRepository(consumer).getProducts(
      filter: const ProductsScreenArguments(
        source: ProductsFilterSource.brand,
        filterValue: '100',
        title: 'Brand',
      ),
      page: 1,
      sort: 'name',
    );

    final uri = Uri.parse(consumer.lastPath!);
    expect(uri.queryParameters['brand_code'], '100');
    expect(uri.queryParameters['category'], isNull);
    expect(uri.queryParameters['sort'], 'name');
  });

  test('loads all products without a classification filter', () async {
    final consumer = _FakeApiConsumer(_response);
    await RemoteProductsRepository(consumer).getProducts(
      filter: const ProductsScreenArguments(
        source: ProductsFilterSource.all,
        filterValue: '',
        title: 'Products',
      ),
      page: 1,
    );

    final uri = Uri.parse(consumer.lastPath!);
    expect(uri.queryParameters['category'], isNull);
    expect(uri.queryParameters['brand_code'], isNull);
  });

  test('sends product name or item code in q', () async {
    final consumer = _FakeApiConsumer(_response);
    await RemoteProductsRepository(consumer).getProducts(
      filter: const ProductsScreenArguments(
        source: ProductsFilterSource.all,
        filterValue: '',
        title: 'Search results',
      ),
      page: 1,
      query: 'P16100035',
    );

    expect(Uri.parse(consumer.lastPath!).queryParameters['q'], 'P16100035');
  });
}

final _response = http.Response(
  '{"success":true,"data":[{'
  '"item_code":"P16100035","name":null,"name_en":null,'
  '"uom":"","units_per_carton":1,"brand_code":100,'
  '"image_url":"https://gal.holeno.com/imghd/P16100035.png",'
  '"price":{"unit_price":null,"unit_price_with_vat":null,'
  '"vat_rate":0.15,"currency":"SAR","price_list":1},'
  '"availability":{"status":"in_stock","label":"Available",'
  '"label_en":"In stock","can_order":true,"available_quantity":25}}],'
  '"meta":{"pagination":{"current_page":2,"per_page":20,'
  '"total":7957,"last_page":398,"has_more":true}}}',
  200,
);

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer(this.response);

  final http.Response response;
  String? lastPath;

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    lastPath = path;
    return response;
  }

  @override
  Future<http.Response> delete(String path, Map<String, String>? headers) =>
      throw UnimplementedError();

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}
