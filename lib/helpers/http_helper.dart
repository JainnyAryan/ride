import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';

class HttpHelper {
  static void validateResponseStatus(Response response) {
    Map<String, dynamic> responseData = jsonDecode(response.body);
    if (response.statusCode == HttpStatus.notFound.code) {
      throw NotFoundHttpException(data: responseData);
    } else if (response.statusCode == HttpStatus.internalServerError.code) {
      throw InternalServerErrorHttpException(data: responseData);
    } else if (response.statusCode == HttpStatus.badRequest.code) {
      throw BadRequestHttpException(data: responseData);
    } else if (response.statusCode == HttpStatus.forbidden.code) {
      throw ForbiddenHttpException(data: responseData);
    } else if (![HttpStatus.ok.code, HttpStatus.created.code]
        .contains(response.statusCode)) {
      throw HttpException(
        httpStatus: HttpStatus.fromCode(response.statusCode),
        detail: 'Unexpected error occurred',
      );
    }
  }
}
