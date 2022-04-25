import 'package:xml/xml.dart';

class LastFMError extends Error {
  late final int code;
  late final String message;
  LastFMError(XmlElement element) {
    code = int.parse(element.getAttribute("code") ?? "0");
    message = element.innerText;
  }

  @override
  String toString() => "Last.fm returned error code "+(code.toString())+": \n"+message;
}
class LastFMInvalidOperationError extends Error {
  final String message;
  LastFMInvalidOperationError(this.message);

  @override
  String toString() => "Last.fm package: $message";
}