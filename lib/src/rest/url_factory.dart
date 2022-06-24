import 'package:rest_simplified/rest_accessor.dart';

class URLFactory {
  String baseURL;
  URLFactory(this.baseURL);

  Map<dynamic, String> getPaths = <dynamic, String>{};
  Map<dynamic, String> postPaths = <dynamic, String>{};
  Map<dynamic, String> putPaths = <dynamic, String>{};
  Map<dynamic, String> deletePaths = <dynamic, String>{};
  Map<dynamic, String> patchPaths = <dynamic, String>{};

  void addPath<T>(Method method, String path) {
    switch (method) {
      case Method.delete:
        deletePaths[T] = path;
        break;
      case Method.get:
        getPaths[T] = path;
        break;
      case Method.post:
        postPaths[T] = path;
        break;
      case Method.put:
        putPaths[T] = path;
        break;
      case Method.patch:
        patchPaths[T] = path;
        break;
      case Method.all:
        deletePaths[T] = path;
        getPaths[T] = path;
        postPaths[T] = path;
        putPaths[T] = path;
        patchPaths[T] = path;
        break;
    }
  }

  String getURL<T>(Method method) {
    String? path;
    switch (method) {
      case Method.delete:
        path = deletePaths[T];
        break;
      case Method.get:
        path = getPaths[T];
        break;
      case Method.post:
        path = postPaths[T];
        break;
      case Method.put:
        path = putPaths[T];
        break;
      case Method.patch:
        path = patchPaths[T];
        break;
      case Method.all:
        path = getPaths[T];
        break;
    }

    if (path == null) throw Exception("Should not be here");
    return baseURL + path;
  }
}
