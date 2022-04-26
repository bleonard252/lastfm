import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:lastfm/src/error.dart';
import 'package:lastfm/src/methods.dart';
import 'package:xml/xml.dart';

abstract class LastFM {
  final String apiKey = "";
  /// Perform a "read" operation on the Last.fm api. This is typically done to
  /// get information about artists, albums, or tracks, or when authenticated to
  /// get information about the user or their listening habits.
  Future<XmlDocument> read(String method, Map<String, String> data);
}

/// An unauthorized LastFM instance. This supports 
class LastFMUnauthorized implements LastFM {
  late final Dio dio = Dio(BaseOptions(
    baseUrl: "http://ws.audioscrobbler.com/2.0/",
    headers: {
      "User-Agent": userAgent ?? "DartLastFm/0.0.1 <https://pub.dev/packages/lastfm>"
    },
    receiveDataWhenStatusError: true,
    responseType: ResponseType.plain,
    validateStatus: (status) => true
  ));
  final String apiKey;
  final String? apiSecret;
  /// The user agent to use in Last.fm requests.
  final String? userAgent;
  String? _authCode;
  LastFMUnauthorized(this.apiKey, [this.apiSecret, this.userAgent]);

  /// Returns the URL to send the user to.
  /// Once the user returns to the app and presses some button,
  /// run [finishAuthorizeDesktop], await it, and (optimally) 
  /// use the returned [LastFMAuthorized] instead.
  Future<String> authorizeDesktop() async {
    final resp = await dio.get("?method=auth.getToken&api_key=$apiKey&api_sig=${sign({'method': 'auth.getToken', 'api_key': apiKey})}");
    late final XmlDocument doc;
    if (resp.data is String) {
      doc = XmlDocument.parse(resp.data);
    } else if (resp.data is XmlDocument) {
      doc = resp.data;
    } else {
      throw UnsupportedError("Last.fm did not return a compatible response type.");
    }
    if (doc.rootElement.getAttribute("status") == "ok") {
      _authCode = doc.rootElement.getElement("token")!.innerText;
      return "https://www.last.fm/api/auth/?api_key=$apiKey&token=$_authCode";
    } else {
      throw LastFMError(doc.rootElement.getElement("error")!);
    }
  }
  /// Triggered when the user says they are done.
  Future<LastFMAuthorized> finishAuthorizeDesktop() async {
    if (_authCode == null) throw LastFMInvalidOperationError("Call authorizeDesktop() first. Please make sure you've read the Setting Up section of the lastfm package readme.");
    final resp = await dio.get("?method=auth.getSession&api_key=$apiKey&token=$_authCode&api_sig=${sign({'method': 'auth.getSession', 'api_key': apiKey, 'token': _authCode!})}");
    late final XmlDocument doc;
    if (resp.data is String) {
      doc = XmlDocument.parse(resp.data);
    } else if (resp.data is XmlDocument) {
      doc = resp.data;
    } else {
      throw UnsupportedError("Last.fm did not return a compatible response type.");
    }
    if (doc.rootElement.getAttribute("status") == "ok") {
      final sk = doc.rootElement.firstElementChild!.getElement('key')!.innerText;
      final un = doc.rootElement.firstElementChild!.getElement('name')!.innerText;
      return LastFMAuthorized(apiKey, secret: apiSecret, sessionKey: sk, username: un);
    } else {
      throw LastFMError(doc.rootElement.getElement("error")!);
    }
  }
  
  @override
  Future<XmlDocument> read(String method, Map<String, String> data) async {
    final resp = await dio.get('/', queryParameters: {...data, "api_key": apiKey, "method": method});
    if (resp.data is String) {
      final doc = XmlDocument.parse(resp.data);
      if (doc.rootElement.getAttribute("status") == "ok" || doc.rootElement.getAttribute("status") == null) {
        return doc;
      } else {
        throw LastFMError(doc.rootElement.getElement("error")!);
      }
    } else if (resp.data is XmlDocument) {
      if (resp.data.rootElement.getAttribute("status") == "ok" || resp.data.rootElement.getAttribute("status") == null) {
        return resp.data;
      } else {
        throw LastFMError(resp.data.rootElement.getElement("error")!);
      }
    } else {
      throw UnsupportedError("Last.fm did not return a compatible response type.");
    }
  }

  /// Used by [authorizeDesktop] and [LastFMAuthorized]. You probably don't need to touch this
  /// as it's all done for you under the hood.
  String sign(Map<String,String> parameters) {
    if (apiSecret == null) throw LastFMInvalidOperationError("You can't sign requests without an API secret.");
    final params = SplayTreeMap<String, String>.from(parameters, (String a, String b) => a.compareTo(b));
    return md5.convert(utf8.encode(params.entries.map((e) => e.key + e.value).join("")+apiSecret!)).toString();
  }
}
class LastFMAuthorized extends LastFMUnauthorized {
  /// Feel free to save this value.
  final String sessionKey;
  /// This is here for your convenience. Also [finishAuthorizeDesktop] fills it.
  final String username;
  LastFMAuthorized(String apiKey, {String? secret, required this.sessionKey, required this.username, String? userAgent}) : super(apiKey, secret, userAgent);

  @override
  Future<XmlDocument> read(String method, Map<String, String> data, [bool authorize = true]) async {
    if (!authorize) return super.read(method, data);
    final params = {...data, "api_key": apiKey, "method": method, "sk": sessionKey};
    final resp = await dio.get('/', queryParameters: {...params, "api_sig": sign(params)});
    final doc = XmlDocument.parse(resp.data);
    if (doc.rootElement.getAttribute("status") == "ok" || doc.rootElement.getAttribute("status") == null) {
      return doc;
    } else {
      throw LastFMError(doc.rootElement.getElement("error")!);
    }
  }
  
  /// Perform a "write" call to the API. This can be used for scrobbling,
  /// liking, and removing tags.
  Future<XmlDocument> write(String method, Map<String, String> data) async {
    final params = {...data, "api_key": apiKey, "method": method, "sk": sessionKey};
    final fd = {...params, "api_sig": sign(params)};
    final resp = await dio.post('/', data: fd, options: Options(contentType: 'application/x-www-form-urlencoded'));
    print(resp.requestOptions.contentType);
    final doc = XmlDocument.parse(resp.data);
    if (doc.rootElement.getAttribute("status") == "ok" || doc.rootElement.getAttribute("status") == null) {
      return doc;
    } else {
      throw LastFMError(doc.rootElement.getElement("error")!);
    }
  }
}