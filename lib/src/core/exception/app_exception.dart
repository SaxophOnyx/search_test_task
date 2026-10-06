class AppException implements Exception {
  const new();

  const AppException.unknown();
}

class LimitReachedException extends AppException {
  const new();
}

class FetchFailedException extends AppException {
  const new();
}
