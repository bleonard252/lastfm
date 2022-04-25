# Last.fm wrapper for Dart
A package that aims to simplify accessing the Last.fm API from Dart, which can let your users look up song information, track their listening, and like songs, among other things.

## Installation
Add `lastfm: ^0.0.1` to the `dependencies` in your pubspec.yaml or just run one of these:
```
flutter pub add lastfm
dart pub add lastfm
```

## Usage
1. Make sure you have created a [Last.fm API account](https://www.last.fm/api/accounts). Get the API key and shared secret into your code safely. **DO NOT embed them into your code directly!** Instead, write them down somewhere (such as a `.gitignore`d `.env` file) and build them using `--define` or (if you're using Flutter) `--dart-define`.
2. Authorize your users:
```dart
LastFM lastfm = LastFMUnauthorized(apiKey, sharedSecret);
// you can stop here if all you need is to read public data
launch(await lastfm.authorizeDesktop()); //authorizeDesktop returns a URL
sleep(60*1000); //wait for user input here
lastfm = await lastfm.finishAuthorizeDesktop();
```
3. Call some methods:
```dart
// These all return [XmlDocument]s from the xml package.
// They are wrapped by default, and [LastFMError]s are thrown instead of passed.
final allAboutTool = await lastfm.read('artist.getInfo', {"artist": "Tool"}, false);
final toolsAlbums = await lastfm.read('artist.getTopAlbums', {"artist": "Tool"});
await lastfm.read('track.love', {"track": "Never Gonna Give You Up", "artist": "Rick Astley"});
```

Keep in mind:
* The API key and secret are stored in memory and you don't have to regurgitate them for every request (see above).
* The signature shenanigans are taken care of for authenticated read and write methods. If you're using `read` and you don't want it to be authenticated when it probably is, add a `false` parameter to the end of the `read` call (see `allAboutTool` above).