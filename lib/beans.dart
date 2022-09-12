/// Class to be used when no response is expected.
class NoResponseExpected {
  NoResponseExpected();
}

/// Class to manage the response from the server.
class ServiceResult {
  /// HTTP Code returned.
  int httpCode;

  /// Exception if any.
  Exception? exception;

  /// The headers returned.
  /// Can be used to get tokens, cookies, etc
  Map<String, String> headers;

  /// Enum to find easily of the response if fine or not.
  ServiceExecutionResult result;

  /// The bean containing the response if any.
  var entity;

  bool isSuccess() {
    return (result == ServiceExecutionResult.success);
  }

  ServiceResult._(
      {required this.httpCode,
      required this.headers,
      required this.result,
      required this.entity,
      this.exception});

  factory ServiceResult.onSuccess(
      int httpCode, Map<String, String> headers, var entity) {
    return ServiceResult._(
        httpCode: httpCode,
        headers: headers,
        result: ServiceExecutionResult.success,
        entity: entity);
  }

  factory ServiceResult.onSuccessWithNoEntity(
      int httpCode, Map<String, String> headers) {
    return ServiceResult._(
        httpCode: httpCode,
        headers: headers,
        result: ServiceExecutionResult.success,
        entity: null);
  }

  factory ServiceResult.onParsingFailure(int httpCode,
      Map<String, String> headers, String body, Exception exception) {
    return ServiceResult._(
        httpCode: httpCode,
        headers: headers,
        result: ServiceExecutionResult.parsing_failure,
        entity: body,
        exception: exception);
  }

  factory ServiceResult.onHttpAccessError(
      int httpCode, Map<String, String> headers, String body) {
    return ServiceResult._(
        httpCode: httpCode,
        headers: headers,
        result: ServiceExecutionResult.failure_invalid_request,
        entity: body);
  }

  factory ServiceResult.onInternalError(String errorMessageKey) {
    return ServiceResult._(
        httpCode: -1,
        headers: {},
        result: ServiceExecutionResult.failure_internal_error,
        entity: errorMessageKey);
  }
}

enum ServiceExecutionResult {
  success,
  failure_invalid_request,
  parsing_failure,
  failure_internal_error
}

class ParsingException implements Exception {
  final Object rootCause;

  ParsingException(this.rootCause);
}
