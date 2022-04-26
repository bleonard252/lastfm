## 0.0.4
* **BREAKING:** The scrobble `startTime/timestamp` is now actually required (it won't work without it anyway).
* Removed a stray `print`.
* Make the scrobble `startTime/timestamp` be passed in seconds.
* Added a scrobble to the example.

## 0.0.2
* Added `LastFMAuthorizedMethods.scrobble` and `LastFMAuthorizedMethods.updateNowPlaying`
* Moved the example so pub.dev shows it

## 0.0.1

* Authenticate using the "desktop" method to the API.
* Read and write for each method in the API.
* Basic scrobbling support (both methods).
* Basic album/artist/track reading methods and specialized classes for their output.