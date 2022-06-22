import 'dart:convert';

import 'package:http/http.dart' as http;

class PostBuilder {
  String _url;

  PostBuilder(this._url);

  Map<String, String>? _header = <String, String>{};
  final Map<String, dynamic> _body = <String, dynamic>{};

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void addFormData(String key, var value) {
    _body[key] = value;
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
}

class PutBuilder {
  String _url;

  PutBuilder(this._url);

  Map<String, String>? _header = <String, String>{};
  final Map<String, dynamic> _body = <String, dynamic>{};

  void setHeader(HeaderBuilder headerBuilder) {
    _header = headerBuilder.get();
  }

  void addFormData(String key, var value) {
    _body[key] = value;
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
}

class GetBuilder {
//Same syntax as for JAX-RS meaning /rest/service/{var1}/{var2}
  final String _url;

  String _interpretedURL;

  GetBuilder(this._url) : _interpretedURL = _url;

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

  Future<http.Response> get() async {
    Uri _uri = Uri.parse(_interpretedURL);
    return http.get(_uri, headers: _header);
  }
}

abstract class HeaderBuilder {
  Map<String, String> get();
}

/*
class HeaderBuilder {
  static Map<String, String> get(AppContext appContext) {
    Map<String, String> _header = new Map<String, String>();
    _header['Content-Type'] = 'application/json';

    if (appContext.hasToken) {
      _header['authorization'] = 'Bearer ' + appContext.getToken.token;
    }
    return _header;
  }
}
*/
