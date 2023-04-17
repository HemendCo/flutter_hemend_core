import '../typedefs/internal_typedefs.dart';

abstract class IHttpRepository {
  void updateClient({String? baseUrl, String? token});
  void removeToken();
  void stopAllRequests();
  Future<Snap<T>> get<T>(
    String address, {
    Map<String, String> headers = const {},
    void Function(int count, int total)? onReceiveProgress,
  }) {
    return getUrl<T>(
      Uri.parse(address),
      headers: headers,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Snap<T>> getUrl<T>(
    Uri url, {
    Map<String, String> headers = const {},
    void Function(int count, int total)? onReceiveProgress,
  });

  Future<Snap<T>> post<T>(
    String address, {
    dynamic body,
    Map<String, String> headers = const {},
    void Function(int count, int total)? onReceiveProgress,
    void Function(int count, int total)? onSendProgress,
  }) {
    return postUrl<T>(
      Uri.parse(address),
      body: body,
      headers: headers,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  Future<Snap<T>> postUrl<T>(
    Uri url, {
    dynamic body,
    Map<String, String> headers = const {},
    void Function(int sent, int total)? onReceiveProgress,
    void Function(int count, int total)? onSendProgress,
  });
}
