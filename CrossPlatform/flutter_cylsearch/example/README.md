# flutter_cylsearch example

The native search bar of CYLSearchViewController in a Flutter page, and buttons that open its native search page with
the suggestions as a list or as tags (a query without results shows CYLTableViewPlaceHolder's placeholder).

- Android: `flutter build apk --debug` (JDK 17). The app includes `android/merged` as a composite build for the core.
- iOS: `flutter build ios --simulator`. `ios/Podfile` uses the local CYLSearchViewController pod and pins its
  sub-repositories by commit.
