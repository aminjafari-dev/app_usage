import 'dart:convert';
import 'dart:io';

import 'package:app_usage/features/drive_sync/drive_sync_config.dart';

/// HTTP client for the free Apps Script Drive sync endpoint.
///
/// How to use:
/// ```dart
/// await DriveSyncApi().upload(
///   userId: id,
///   days: {'2026-09-05': {'com.app': 120}},
/// );
/// ```
class DriveSyncApi {
  /// Creates an API client.
  DriveSyncApi();

  /// POSTs pending day maps for [userId]. Throws on non-2xx / ok:false.
  ///
  /// Google Apps Script web apps respond to POST with a 302 to a
  /// `script.googleusercontent.com/macros/echo?...` URL. The JSON body is
  /// retrieved with a GET on that Location (re-POSTing returns 405).
  Future<void> upload({
    required String userId,
    required Map<String, Map<String, int>> days,
  }) async {
    final uri = Uri.parse(DriveSyncConfig.baseUrl);
    final body = jsonEncode({
      'apiKey': DriveSyncConfig.apiKey,
      'userId': userId,
      'days': days,
    });

    final response = await _postThenFollowEcho(uri, body);
    final status = response.statusCode;
    final responseBody = response.body;

    if (status < 200 || status >= 300) {
      throw DriveSyncApiException(statusCode: status, body: responseBody);
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is Map && decoded['ok'] == false) {
      throw DriveSyncApiException(statusCode: status, body: responseBody);
    }
  }

  Future<_HttpTextResponse> _postThenFollowEcho(Uri uri, String body) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final post = await client.postUrl(uri);
      post.followRedirects = false;
      post.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      post.write(body);
      final postResponse =
          await post.close().timeout(const Duration(seconds: 45));
      final postStatus = postResponse.statusCode;

      if (postStatus >= 200 && postStatus < 300) {
        final text = await postResponse.transform(utf8.decoder).join();
        return _HttpTextResponse(postStatus, text);
      }

      if (_isRedirect(postStatus)) {
        final location = postResponse.headers.value(HttpHeaders.locationHeader);
        await postResponse.drain<void>();
        if (location == null || location.isEmpty) {
          return _HttpTextResponse(postStatus, 'Redirect without Location');
        }

        final echoUri = uri.resolve(location);
        final get = await client.getUrl(echoUri);
        get.followRedirects = true;
        final getResponse =
            await get.close().timeout(const Duration(seconds: 45));
        final text = await getResponse.transform(utf8.decoder).join();
        return _HttpTextResponse(getResponse.statusCode, text);
      }

      final text = await postResponse.transform(utf8.decoder).join();
      return _HttpTextResponse(postStatus, text);
    } finally {
      client.close(force: true);
    }
  }

  bool _isRedirect(int status) =>
      status == HttpStatus.movedTemporarily ||
      status == HttpStatus.movedPermanently ||
      status == HttpStatus.seeOther ||
      status == HttpStatus.temporaryRedirect ||
      status == 308;
}

class _HttpTextResponse {
  const _HttpTextResponse(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

/// Thrown when the sync backend rejects or fails a request.
class DriveSyncApiException implements Exception {
  /// Creates an exception from an HTTP failure.
  DriveSyncApiException({required this.statusCode, required this.body});

  /// HTTP status from the backend.
  final int statusCode;

  /// Raw response body for debugging.
  final String body;

  @override
  String toString() => 'DriveSyncApiException($statusCode): $body';
}
