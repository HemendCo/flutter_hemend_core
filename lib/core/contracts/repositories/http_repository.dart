import '../../rust_like/option/option.dart';
import '../typedefs/typedefs.dart';

abstract class IHttpRepository {
  void updateClient({String? baseUrl, String? token});
  void removeToken();
  void stopAllRequests();
  Future<Snap<Option<T>>> get<T extends Object>(
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

  Future<Snap<Option<T>>> getUrl<T extends Object>(
    Uri url, {
    Map<String, String> headers = const {},
    void Function(int count, int total)? onReceiveProgress,
  });

  Future<Snap<Option<T>>> post<T extends Object>(
    String address, {
    Object? body,
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

  Future<Snap<Option<T>>> postUrl<T extends Object>(
    Uri url, {
    Object? body,
    Map<String, String> headers = const {},
    void Function(int sent, int total)? onReceiveProgress,
    void Function(int count, int total)? onSendProgress,
  });
}
