# Real-Time Location Tracker

Flutter app that tracks the user's live GPS position on Google Maps.
Built for Module 18 assignment: Google Maps and Geolocator.

## Features

- Smooth camera animation to the user's current location
- Location fetched every 10 seconds with `geolocator`
- Marker updates to the latest position
- Polyline drawn through every recorded location
- Tap marker to open an info window: "My current location" + latitude/longitude
- Splash, permission handling (denied, blocked, GPS off), route history screens
- Satellite/normal map toggle, follow-me toggle, pause/resume tracking

## Tech

Flutter, `google_maps_flutter`, `geolocator`, `provider`

## Project structure

```
lib/
  core/         constants, theme, formatters, routes
  models/       TrackPoint
  services/     LocationService (permissions + GPS)
  controllers/  TrackingController (timer, path, distance)
  screens/      splash, permission, tracker, history
  widgets/      stats panel, map action button
```

## Setup

1. Install Flutter and run `flutter doctor`.
2. Clone the repo and run `flutter pub get`.
3. Create a Google Maps API key with **Maps SDK for Android** enabled.
4. Add the key to `android/local.properties` (this file is git-ignored):

   ```
   MAPS_API_KEY=your_api_key_here
   ```

5. Run on a device with Google Play services: `flutter run`.