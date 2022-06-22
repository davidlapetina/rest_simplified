library rest_simplified;

import 'package:rest_simplified/parsers_factory.dart';
import 'package:rest_simplified/rest_accessor.dart';
import 'package:rest_simplified/src/rest/request_builder.dart';
import 'package:rest_simplified/src/rest/url_factory.dart';

/// Main entry point for the API.
class RestSimplified {
  URLFactory _urlFactory;
  RestAccessor _restAccessor;
  RestSimplified._(this._urlFactory, HeaderBuilder? defaultHeaderBuilder)
      : _restAccessor = RestAccessor.build(_urlFactory, defaultHeaderBuilder);

  /// Factory to setup the library.
  /// It is possible to define a [HeaderBuilder] that can be used for each request. In case the HeaderBuilder
  /// is not provided then you can define it when accessing to each request (see RestAccessor)
  /// [baseURL] is used to build the full URL, See [addURL]
  factory RestSimplified.build(String baseURL,
      {HeaderBuilder? defaultHeaderBuilder}) {
    return RestSimplified._(URLFactory(baseURL), defaultHeaderBuilder);
  }

  /// This method is used to map URL with a Bean that is sent to the server and a protocol.
  /// For instance:
  /// addURL<Car>(Protocol.get, '/myCar')
  /// addURL<Car>(Protocol.post, '/createCar')
  /// addURL<Customer>(Protocol.get, '/customer/{customerId}') see [RestAccessor] for the interpretation of {customerId} parameter
  void addURL<T>(Protocol protocol, String path) {
    _urlFactory.addURL<T>(protocol, path);
  }

  /// In order to serialize a bean to Json format you need to add a [ToJsonMapParser].
  /// For instance:
  /// addToJsonMapParser<Car>(CarJsonMapParser())
  void addToJsonMapParser<T>(ToJsonMapParser parser) {
    _restAccessor.parserFactory.addToJsonMapParser<T>(parser);
  }

  /// In order to deserialize a bean from Json format you need to add a [FromJsonParser].
  /// For instance:
  /// addFromJsonMapParser<Car>(CarFromJsonParser())
  void addFromJsonMapParser<T>(FromJsonParser parser) {
    _restAccessor.parserFactory.addFromJsonMapParser<T>(parser);
  }

  /// Accessor to the Rest/HTTP operations.
  /// See [RestAccessor]
  RestAccessor getRestAccessor() {
    return _restAccessor;
  }
}
