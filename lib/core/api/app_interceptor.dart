import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/my_app.dart';

class AppInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    request.headers[ConstantKeys.contentType] = ConstantKeys.applicationJson;
    request.headers[ConstantKeys.acceptText] = ConstantKeys.applicationJson;

    final context = navigatorKey.currentContext;
    request.headers[ConstantKeys.acceptLanguage] = context != null
        ? Localizations.localeOf(context).languageCode
        : 'ar';

    debugPrint(request.toString());

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    debugPrint(response.toString());
    return response;
  }
}
