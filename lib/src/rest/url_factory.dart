enum Protocol { get, post, put, all }

class URLFactory {
  String baseURL;
  URLFactory(this.baseURL);

  Map<dynamic, String> getPaths = <dynamic, String>{};
  Map<dynamic, String> postPaths = <dynamic, String>{};
  Map<dynamic, String> putPaths = <dynamic, String>{};

  void addURL<T>(Protocol protocol, String path) {
    switch (protocol) {
      case Protocol.get:
        getPaths[T] = path;
        break;
      case Protocol.post:
        postPaths[T] = path;
        break;
      case Protocol.put:
        putPaths[T] = path;
        break;
      case Protocol.all:
        getPaths[T] = path;
        postPaths[T] = path;
        putPaths[T] = path;
        break;
    }
  }

  String getURL<T>(Protocol protocol) {
    String? path;
    switch (protocol) {
      case Protocol.get:
        path = getPaths[T];
        break;
      case Protocol.post:
        path = postPaths[T];
        break;
      case Protocol.put:
        path = putPaths[T];
        break;
      case Protocol.all:
        path = getPaths[T];
        break;
    }

    if (path == null) throw Exception("Should not be here");
    return baseURL + path;
  }
}
