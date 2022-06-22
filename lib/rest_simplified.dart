library rest_simplified;

import 'package:rest_simplified/rest/parsers_factory.dart';
import 'package:rest_simplified/rest/request_builder.dart';
import 'package:rest_simplified/rest/services.dart';
import 'package:rest_simplified/rest/url_factory.dart';

class RestSimplified {
  URLFactory _urlFactory;
  RestAccessor _restAccessor;
  RestSimplified._(this._urlFactory, HeaderBuilder? defaultHeaderBuilder)
      : _restAccessor = RestAccessor.build(_urlFactory, defaultHeaderBuilder);

  factory RestSimplified.build(
      String baseURL, HeaderBuilder? defaultHeaderBuilder) {
    return RestSimplified._(URLFactory(baseURL), defaultHeaderBuilder);
  }

  void addURL<T>(Protocol protocol, String path) {
    _urlFactory.addURL(protocol, path);
  }

  void addToJsonMapParser<T>(ToJsonMapParser parser) {
    _restAccessor.parserFactory.addToJsonMapParser(parser);
  }

  void addFromJsonMapParser<T>(FromJsonParser parser) {
    _restAccessor.parserFactory.addFromJsonMapParser(parser);
  }

  RestAccessor getRestAccessor() {
    return _restAccessor;
  }
}
