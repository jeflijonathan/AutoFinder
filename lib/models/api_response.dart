class ApiResponse<T> {
  final String status;
  final int statusCode;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  // Helper untuk mempersingkat pembuatan response sukses
  factory ApiResponse.success(
    T? data, {
    String message = "Operasi berhasil",
    int code = 200,
  }) {
    return ApiResponse(
      status: "success",
      statusCode: code,
      message: message,
      data: data,
    );
  }

  // Helper untuk mempersingkat pembuatan response error
  factory ApiResponse.error(String message, int code) {
    return ApiResponse(
      status: "error",
      statusCode: code,
      message: message,
      data: null,
    );
  }
}
