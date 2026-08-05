import 'package:montajat_customer_app/core/exceptions/failure.dart';

class ServerException implements Exception {
  final ServerFailure serverFailure;

  const ServerException({required this.serverFailure});
}
