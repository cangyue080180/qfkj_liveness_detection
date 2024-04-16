
enum Status {
  success,
  requestError,
  tokenError,
  compareError,
  error,
  unknown
}

class Response<T>{
  final Status status;
  final String msg;
  final T? data;

  Response({
    required this.status,
    required this.msg,
    this.data
});
}