sealed class MyResult<T> {
  const MyResult();
}

class Success<T> extends MyResult<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends MyResult<T> {
  final String message;
  const Error(this.message);
}
