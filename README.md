# Love Dive

<p align="center">
<img src="https://github.com/nick-maker/Love-Dive/blob/main/Screenshots/Logo.png" width="256" height="256"/>
</p>

<p align="center">
  <b>Love Dive</b> is a one-stop diving log app focusing on chart support and weather forecasting for Apple Watch Ultra users who love free diving.
</p>

<p align="center"><a href="https://apps.apple.com/tw/app/love-dive/id6450437347?l=en-GB">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a></p>


## Features

### Hightlights
- Apple Watch Ultra free diving log with chart support
- Plan better with on-map weather info for dive sites. 
- Animated breathe timer with live activities and dynamic island support.

<img src="https://github.com/nick-maker/Love-Dive/blob/main/Screenshots/1359.png" width="1080" height=""/>

<img src="https://github.com/nick-maker/Love-Dive/blob/main/Screenshots/1360.png" width="1080" height=""/>

## Technical Highlights
- Set up an algorithm for extracting diving data from **HealthKit**, with subsequent sorting and seamless integration into **SwiftUI charts** for improved data visualization and interpretation.
- Integrated **MapKit** and a **RESTful API** in order to synchronously display diving sites and weather data on **MapView**.
- Engineered a dual-layer cache mechanism for weather data, utilizing **UserDefaults** and **Firestore** to mitigate API usage constraints, thereby optimizing data retrieval performance while maintaining service availability for all users.
- Incorporated a variety of filters in **CIFilterBuiltins** for enriched color processing of photos in diving logs.
- Implemented an animated timer through **ActivityKit** and **WidgetKit**, enhancing user interaction and visual appeal.
- Applied **dependency injection** for unit testing, ensuring testability, reusability, and maintainability.


## Libraries
- [Firestore](https://firebase.google.com/products/firestore?gclid=Cj0KCQiA-qGNBhD3ARIsAO_o7ynVqh2xVTgG6WIKFSfdCN4x9lHJrit2kdCT99IfZPNxPPbbtPHr6qsaAv4lEALw_wcB&gclsrc=aw.ds)
- [lottie-ios](https://github.com/airbnb/lottie-ios)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Crashlytics](https://firebase.google.com/products/crashlytics?hl=en)


## Version
1.0.0


## Requirement
- Xcode 14.0 or later
- iOS 16.2 or later


## Release Notes
| Version | Date | Description                                                                                     |
| :-------| :----|:------------------------------------------------------------------------------------------------|
| 1.0.0   | 2023.07.19 | Launched in App Store|


## Contact

Nick Liu
[hybrida666@gmail.com](hybrida666@gmail.com)

## License

This project is licensed under the terms of the MIT license