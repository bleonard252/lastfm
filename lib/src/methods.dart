import 'package:lastfm/src/class.dart';

extension LastFMUnauthorizedHelpers on LastFMUnauthorized {

}
extension LastFMAuthorizedHelpers on LastFMAuthorized {
  Future<void> scrobble({required String name, required String artistName, String? albumName, Duration? duration, DateTime? startTime}) {
    throw UnimplementedError();
  }
}