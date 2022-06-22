import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rest_simplified/beans.dart';
import 'package:rest_simplified/parsers_factory.dart';
import 'package:rest_simplified/src/rest/request_builder.dart';
import 'package:rest_simplified/src/rest/url_factory.dart';

enum Protocol { get, post, put, all }

/// Defines the Rest/HTTP operations.
abstract class RestAccessor {
  final ParserFactory parserFactory = ParserFactory();

  /// For Rest/ GET operation.
  /// [queryParams] will add the parameters as a query url/?key1=value1&key2=value2...
  /// [pathParams] will transform any value such as {key} in a url, for instance if the URL defined is '/customer/{customerId}'
  /// then any key/value in the map such as pathParams[customerId]='123456' will be transformed as '/customer/123456'
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> get<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder});

  /// For Rest/ POST operation.
  /// When doing POST you have to define the return type expected, even if it is the same as Input
  /// In case no return value is expected, you must use [NoResponseExpected], for instance: post<Car,NoResponseExpected>(myCar);
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> post<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder});

  /// For Rest/ PUT operation.
  /// When doing PUT you have to define the return type expected, even if it is the same as Input
  /// In case no return value is expected, you must use [NoResponseExpected], for instance: put<Car,NoResponseExpected>(myCar);
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> put<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder});

  /// Build method used internally.
  /// Do not use it. It will be hidden in future version.
  static RestAccessor build(
      URLFactory urlFactory, HeaderBuilder? defaultHeaderBuilder) {
    return _RestAccessorImpl(urlFactory,
        defaultHeaderBuilder: defaultHeaderBuilder);
  }
}

class _RestAccessorImpl extends RestAccessor {
  final URLFactory _urlFactory;
  HeaderBuilder? defaultHeaderBuilder;

  _RestAccessorImpl(this._urlFactory, {this.defaultHeaderBuilder});

  Future<ServiceResult> get<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder}) async {
    GetBuilder get = GetBuilder(_urlFactory.getURL<Output>(Protocol.get));

    if (headerBuilder != null) {
      get.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      get.setHeader(defaultHeaderBuilder!);
    }

    if (pathParams != null) {
      pathParams.forEach((key, value) {
        get.setURLParam(key, value);
      });
    }

    get.setQueryParams(queryParams);

    final http.Response response = await get.get();

    if (response.statusCode != 200) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, _decode(response));
    }

    try {
      dynamic json = _decode(response);
      if (json is List) {
        return ServiceResult.onSuccess(response.statusCode, response.headers,
            parserFactory.fromJSON<Output>().toList(json));
      }

      return ServiceResult.onSuccess(response.statusCode, response.headers,
          parserFactory.fromJSON<Output>().toObject(json));
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  Future<ServiceResult> post<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    PostBuilder post = PostBuilder(_urlFactory.getURL<Input>(Protocol.post));

    if (headerBuilder != null) {
      post.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      post.setHeader(defaultHeaderBuilder!);
    }

    Map<String, dynamic> parameters = parserFactory.toMap<Input>().toMap(input);

    parameters.forEach((key, value) {
      post.addFormData(key, value);
    });

    post.setQueryParams(queryParams);

    final http.Response response = await post.post();

    if (response.statusCode != 200 && response.statusCode != 201) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, _decode(response));
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      dynamic json = _decode(response);
      if (json is List) {
        return ServiceResult.onSuccess(response.statusCode, response.headers,
            parserFactory.fromJSON<Output>().toList(json));
      }

      return ServiceResult.onSuccess(response.statusCode, response.headers,
          parserFactory.fromJSON<Output>().toObject(json));
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  Future<ServiceResult> put<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    PutBuilder put = PutBuilder(_urlFactory.getURL<Input>(Protocol.put));

    if (headerBuilder != null) {
      put.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      put.setHeader(defaultHeaderBuilder!);
    }

    Map<String, dynamic> parameters = parserFactory.toMap<Input>().toMap(input);

    parameters.forEach((key, value) {
      put.addFormData(key, value);
    });

    put.setQueryParams(queryParams);

    final http.Response response = await put.put();

    if (response.statusCode != 200) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, _decode(response));
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      dynamic json = _decode(response);
      if (json is List) {
        return ServiceResult.onSuccess(response.statusCode, response.headers,
            parserFactory.fromJSON<Output>().toList(json));
      }

      return ServiceResult.onSuccess(response.statusCode, response.headers,
          parserFactory.fromJSON<Output>().toObject(json));
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  dynamic _decode(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }
}
