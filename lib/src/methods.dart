import 'package:lastfm/src/class.dart';

extension LastFMUnauthorizedHelpers on LastFMUnauthorized {

}
extension LastFMAuthorizedHelpers on LastFMAuthorized {
  /// Used to add a track-play to a user's profile. Scrobble a track, or a batch of tracks.
  /// It is important to not use the corrections returned by the now playing
  /// service as input for the scrobble request, unless they have been explicitly approved by the user.
  /// 
  /// A track should only be scrobbled when the following conditions have been met:
  /// * The track must be longer than 30 seconds.
  /// * *And* the track has been played for at least half its duration, or for 4 minutes (whichever occurs earlier.)
  /// 
  /// As soon as these conditions have been met, the scrobble request may be sent at any time.
  /// It is often most convenient to send a scrobble request when a track has finished playing.
  Future<void> scrobble({required String track, required String artist, String? album, int? trackNumber, Duration? duration, DateTime? startTime}) {
    return write("track.scrobble", {
      "track": track,
      "artist": artist,
      if (album != null) "album": album,
      if (trackNumber != null) "trackNumber": trackNumber.toString(),
      if (duration != null) "duration": duration.inSeconds.toString(),
      if (startTime != null) "timestamp": startTime.toUtc().millisecondsSinceEpoch.toString(),
    });
  }
  /// Used to notify Last.fm that a user has started listening to a track.
  /// 
  /// **Please note:** this method does NOT scrobble (add to history or charts).
  /// You must use [scrobble] to actually commit these. Follow the rules on that method.
  /// 
  /// The "Now Playing" service lets a client notify Last.fm that a user has started
  /// listening to a track. This does not affect a user's charts, but will feature
  /// the current track on their profile page, along with an indication of what
  /// music player they're using.
  /// 
  /// This API method call is optional for scrobbling clients, but recommended.
  /// Requests should be sent as soon as a user starts listening to a track.
  Future<void> updateNowPlaying({required String track, required String artist, String? album, String? albumArtist, int? trackNumber, Duration? duration}) {
    return write("track.updateNowPlaying", {
      "track": track,
      "artist": artist,
      if (album != null) "album": album,
      if (albumArtist != null) "albumArtist": albumArtist,
      if (trackNumber != null) "trackNumber": trackNumber.toString(),
      if (duration != null) "duration": duration.inSeconds.toString(),
    });
  }
}