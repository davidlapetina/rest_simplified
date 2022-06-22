abstract class ToJsonMapParser<T> {
  Map<String, String> toMap(T t);
}

abstract class FromJsonParser<T> {
  T toObject(Map<String, dynamic> json);
  List<T> toList(dynamic json) {
    List<T> results = json.map((item) => toObject(item)).toList();
    return results;
  }
}

class ParserFactory {
  final Map<dynamic, ToJsonMapParser> _toJsonParsersMap =
      <dynamic, ToJsonMapParser>{};
  final Map<dynamic, FromJsonParser> _fromJsonParsersMap =
      <dynamic, FromJsonParser>{};

  void addToJsonMapParser<T>(ToJsonMapParser parser) {
    _toJsonParsersMap[T] = parser;
  }

  void addFromJsonMapParser<T>(FromJsonParser parser) {
    _fromJsonParsersMap[T] = parser;
  }

  ToJsonMapParser toMap<T>() {
    ToJsonMapParser? parser = _toJsonParsersMap[T];
    if (parser == null) {
      throw Exception('Unknown entity');
    }
    return parser;
  }

  FromJsonParser fromJSON<T>() {
    FromJsonParser? parser = _fromJsonParsersMap[T];
    if (parser == null) {
      throw Exception('Unknown entity');
    }
    return parser;
  }
}
