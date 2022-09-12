import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rest_simplified/beans.dart';
import 'package:rest_simplified/parsers_factory.dart';
import 'package:rest_simplified/rest_simplified.dart';
import 'package:rest_simplified/src/rest/request_builder.dart';
import 'package:rest_simplified/src/rest/url_factory.dart';

/// Defines the protocols. All implies get, post, put.
enum Method { delete, get, patch, post, put, all }

/// Defines the Rest/HTTP operations.
abstract class RestAccessor {
  final ParserFactory parserFactory = ParserFactory();

  /// For Rest/ DELETE operation.
  /// [queryParams] will add the parameters as a query url/?key1=value1&key2=value2...
  /// [pathParams] will transform any value such as {key} in a url, for instance if the URL defined is '/customer/{customerId}'
  /// then any key/value in the map such as pathParams[customerId]='123456' will be transformed as '/customer/123456'
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> delete<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder});

  /// For Rest/ GET operation.
  /// [queryParams] will add the parameters as a query url/?key1=value1&key2=value2...
  /// [pathParams] will transform any value such as {key} in a url, for instance if the URL defined is '/customer/{customerId}'
  /// then any key/value in the map such as pathParams[customerId]='123456' will be transformed as '/customer/123456'
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> get<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder});

  /// For Rest/ PATCH operation.
  /// When doing PATCH you have to define the return type expected, even if it is the same as Input
  /// In case no return value is expected, you must use [NoResponseExpected], for instance: put<Car,NoResponseExpected>(myCar);
  /// It is possible to define a specific [HeaderBuilder]
  Future<ServiceResult> patch<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder});

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

  Future<ServiceResult> service<Output>(
      Method method, String path, Map<String, dynamic> input,
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

  Future<ServiceResult> delete<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder}) async {
    DeleteBuilder delete =
        DeleteBuilder(_urlFactory.getURL<Output>(Method.get));

    if (headerBuilder != null) {
      delete.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      delete.setHeader(defaultHeaderBuilder!);
    }

    if (pathParams != null) {
      pathParams.forEach((key, value) {
        delete.setURLParam(key, value);
      });
    }

    delete.setQueryParams(queryParams);

    final http.Response response = await delete.delete();

    if (response.statusCode != 200) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, response.body);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  ServiceResult _extractEntity<Output>(http.Response response) {
    dynamic json = _decode(response);

    if (Output == String) {
      return ServiceResult.onSuccess(
          response.statusCode, response.headers, json.toString());
    }

    if (Output == bool) {
      return ServiceResult.onSuccess(response.statusCode, response.headers,
          json.toString().toLowerCase() == ' true');
    }

    if (Output == int) {
      return ServiceResult.onSuccess(
          response.statusCode, response.headers, int.parse(json));
    }

    if (Output == double) {
      return ServiceResult.onSuccess(
          response.statusCode, response.headers, double.parse(json));
    }

    if (json is List) {
      return ServiceResult.onSuccess(response.statusCode, response.headers,
          parserFactory.fromJSON<Output>().toList(json));
    }

    return ServiceResult.onSuccess(response.statusCode, response.headers,
        parserFactory.fromJSON<Output>().toObject(json));
  }

  Future<ServiceResult> get<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder}) async {
    GetBuilder get = GetBuilder(_urlFactory.getURL<Output>(Method.get));

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
          response.statusCode, response.headers, response.body);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  Future<ServiceResult> patch<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    PatchBuilder patch = PatchBuilder(_urlFactory.getURL<Input>(Method.patch));

    if (headerBuilder != null) {
      patch.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      patch.setHeader(defaultHeaderBuilder!);
    }

    Map<String, dynamic> body = parserFactory.toMap<Input>().toMap(input);
    patch.setBody(body);

    patch.setQueryParams(queryParams);

    final http.Response response = await patch.patch();

    if (response.statusCode != 200 && response.statusCode != 201) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, response.body);
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  Future<ServiceResult> post<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    PostBuilder post = PostBuilder(_urlFactory.getURL<Input>(Method.post));

    if (headerBuilder != null) {
      post.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      post.setHeader(defaultHeaderBuilder!);
    }

    Map<String, dynamic> body = parserFactory.toMap<Input>().toMap(input);
    post.setBody(body);

    post.setQueryParams(queryParams);

    final http.Response response = await post.post();

    if (response.statusCode != 200 && response.statusCode != 201) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, response.body);
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  Future<ServiceResult> put<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    PutBuilder put = PutBuilder(_urlFactory.getURL<Input>(Method.put));

    if (headerBuilder != null) {
      put.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      put.setHeader(defaultHeaderBuilder!);
    }

    Map<String, dynamic> body = parserFactory.toMap<Input>().toMap(input);
    put.setBody(body);

    put.setQueryParams(queryParams);

    final http.Response response = await put.put();

    if (response.statusCode != 200) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, response.body);
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }

  dynamic _decode(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  @override
  Future<ServiceResult> service<Output>(
      Method method, String path, Map<String, dynamic> input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder}) async {
    MethodBuilder build;
    switch (method) {
      case Method.delete:
        build = DeleteBuilder(_urlFactory.getRawURL(path));
        break;
      case Method.patch:
        build = DeleteBuilder(_urlFactory.getRawURL(path));
        break;
      case Method.post:
        build = DeleteBuilder(_urlFactory.getRawURL(path));
        break;
      case Method.put:
        build = DeleteBuilder(_urlFactory.getRawURL(path));
        break;
      case Method.get:
        build = DeleteBuilder(_urlFactory.getRawURL(path));
        break;
      default:
        throw Exception('Should not be here');
    }
    if (headerBuilder != null) {
      build.setHeader(headerBuilder);
    } else if (defaultHeaderBuilder != null) {
      build.setHeader(defaultHeaderBuilder!);
    }

    build.setBody(input);

    build.setQueryParams(queryParams);

    final http.Response response = await build.execute();

    if (response.statusCode != 200) {
      return ServiceResult.onHttpAccessError(
          response.statusCode, response.headers, response.body);
    }

    if (Output == NoResponseExpected) {
      //Nothing to expect
      return ServiceResult.onSuccessWithNoEntity(
          response.statusCode, response.headers);
    }

    try {
      return _extractEntity<Output>(response);
    } catch (_) {
      return ServiceResult.onParsingFailure(response.statusCode,
          response.headers, response.body, ParsingException(_));
    }
  }
}
