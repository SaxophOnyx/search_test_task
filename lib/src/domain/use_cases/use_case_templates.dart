abstract interface class UseCase<In, Out> {
  Out execute(In input);
}

abstract interface class FutureUseCase<In, Out> {
  Future<Out> execute(In input);
}

abstract interface class StreamUseCase<In, Out> {
  Stream<Out> execute(In input);
}

class NoParams {
  const NoParams();
}
