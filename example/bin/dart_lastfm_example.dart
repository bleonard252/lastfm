import 'dart:io';

import 'package:lastfm/lastfm.dart';

void main(List<String> arguments) async {
  if (!bool.hasEnvironment("API_KEY")) throw "API_KEY environment variable required";
  LastFM lastfm = LastFMUnauthorized(String.fromEnvironment("API_KEY"), bool.hasEnvironment("SHARED_SECRET") ? String.fromEnvironment("SHARED_SECRET") : null);
  print(await lastfm.read("track.getInfo", {"artist": "Imagine Dragons", "track": "Bones"}));
  if (bool.hasEnvironment("SHARED_SECRET")) {
    print("Go to the following address:");
    print(await (lastfm as LastFMUnauthorized).authorizeDesktop());
    stdin.readByteSync();
    lastfm = await lastfm.finishAuthorizeDesktop();
    (lastfm as LastFMAuthorized).read("user.getLovedTracks", {"user": lastfm.username});
    await lastfm.write("track.love", {"track": "GET UP", "artist": "Shinedown"});
    lastfm.scrobble(track: "Never Gonna Give You Up", artist: "Rick Astley", startTime: DateTime.now().subtract(Duration(minutes: 2)));
  }
}
