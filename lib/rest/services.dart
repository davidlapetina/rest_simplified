import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rest_simplified/rest/beans.dart';
import 'package:rest_simplified/rest/parsers_factory.dart';
import 'package:rest_simplified/rest/request_builder.dart';
import 'package:rest_simplified/rest/url_factory.dart';

abstract class RestAccessor {
  final ParserFactory parserFactory = ParserFactory();

  Future<ServiceResult> get<Output>(
      {Map<String, String>? queryParams,
      Map<String, String>? pathParams,
      HeaderBuilder? headerBuilder});
  Future<ServiceResult> post<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder});
  Future<ServiceResult> put<Input, Output>(Input input,
      {Map<String, String>? queryParams, HeaderBuilder? headerBuilder});

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
