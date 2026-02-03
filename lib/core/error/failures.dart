/// Failure base class for error handling
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Server/IO failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// File access failures
class FileFailure extends Failure {
  const FileFailure(super.message);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
