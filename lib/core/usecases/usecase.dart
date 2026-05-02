import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';

/// Contract for all use cases.
/// [ResultType] is the return type, [Params] is the input parameter type.
abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

/// Use when a use case requires no parameters.
class NoParams {
  const NoParams();
}
