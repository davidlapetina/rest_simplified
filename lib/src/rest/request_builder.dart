import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rest_simplified/rest_simplified.dart';

abstract class MethodBuilder {
  void setHeader(HeaderBuilder headerBuilder);

  void setBody(dynamic body);

  void setQueryParams(Map<String, String>? queryParams);

  Future<http.Response> execute();
}

class PostBuilder implements MethodBuilder {
  String _url;

  PostBuilder(this._url);

  Map<String, String>? _header = <String, String>{};
  dynamic _body;

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void setBody(dynamic body) {
    this._body = body;
  }

  void setQueryParams(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return;
    }
    _url = _url + '?';

    queryParams.forEach((key, value) {
      _url = _url + key + '=' + value + '&';
    });
    _url = _url.substring(0, _url.length - 1); //remove trailing &
  }

  Future<http.Response> post() async {
    return http.post(Uri.parse(_url),
        headers: _header, body: jsonEncode(_body));
  }

  @override
  Future<http.Response> execute() {
    return post();
  }
}

class PatchBuilder implements MethodBuilder {
  String _url;

  PatchBuilder(this._url);

  Map<String, String>? _header = <String, String>{};
  dynamic _body;

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void setBody(dynamic body) {
    this._body = body;
  }

  void setQueryParams(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return;
    }
    _url = _url + '?';

    queryParams.forEach((key, value) {
      _url = _url + key + '=' + value + '&';
    });
    _url = _url.substring(0, _url.length - 1); //remove trailing &
  }

  Future<http.Response> patch() async {
    return http.patch(Uri.parse(_url),
        headers: _header, body: jsonEncode(_body));
  }

  @override
  Future<http.Response> execute() {
    return patch();
  }
}

class PutBuilder implements MethodBuilder {
  String _url;

  PutBuilder(this._url);

  Map<String, String>? _header = <String, String>{};
  dynamic _body;

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void setBody(dynamic body) {
    this._body = body;
  }

  void setQueryParams(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return;
    }
    _url = _url + '?';

    queryParams.forEach((key, value) {
      _url = _url + key + '=' + value + '&';
    });
    _url = _url.substring(0, _url.length - 1); //remove trailing &
  }

  Future<http.Response> put() async {
    return http.put(Uri.parse(_url), headers: _header, body: jsonEncode(_body));
  }

  @override
  Future<http.Response> execute() {
    return put();
  }
}

class GetBuilder implements MethodBuilder {
//Same syntax as for JAX-RS meaning /rest/service/{var1}/{var2}

  String _interpretedURL;

  GetBuilder(String url) : _interpretedURL = url;

  var _header = new Map<String, String>();

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  @override
  void setBody(dynamic body) {
    // Do nothing
  }

  void setURLParam(String key, String value) {
    _interpretedURL = _interpretedURL.replaceAll("{" + key + "}", value);
  }

  //Must be called after above
  void setQueryParams(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return;
    }
    _interpretedURL = _interpretedURL + '?';

    queryParams.forEach((key, value) {
      _interpretedURL = _interpretedURL + key + '=' + value + '&';
    });
    _interpretedURL = _interpretedURL.substring(
        0, _interpretedURL.length - 1); //remove trailing &
  }

  Future<http.Response> get() async {
    Uri _uri = Uri.parse(_interpretedURL);
    return http.get(_uri, headers: _header);
  }

  @override
  Future<http.Response> execute() {
    return get();
  }
}

class DeleteBuilder implements MethodBuilder {
  String _interpretedURL;

  DeleteBuilder(String url) : _interpretedURL = url;

  var _header = new Map<String, String>();

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void setURLParam(String key, String value) {
    _interpretedURL = _interpretedURL.replaceAll("{" + key + "}", value);
  }

  //Must be called after above
  void setQueryParams(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return;
    }
    _interpretedURL = _interpretedURL + '?';

    queryParams.forEach((key, value) {
      _interpretedURL = _interpretedURL + key + '=' + value + '&';
    });
    _interpretedURL = _interpretedURL.substring(
        0, _interpretedURL.length - 1); //remove trailing &
  }

  Future<http.Response> delete() async {
    Uri _uri = Uri.parse(_interpretedURL);
    return http.delete(_uri, headers: _header);
  }

  @override
  Future<http.Response> execute() {
    return delete();
  }

  @override
  void setBody(dynamic body) {
    // Do nothing
  }
}
