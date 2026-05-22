class ServiceCallback<T> {
  final Function(T data) onSuccessData;
  final Function(String error) onErrorData;
  final Function()? onFullFailed;

  ServiceCallback({
    required this.onSuccessData,
    required this.onErrorData,
    this.onFullFailed,
  });
}
