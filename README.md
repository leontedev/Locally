# Locally - Navigation Companion

[![Version](https://img.shields.io/badge/version-1.1-yellow.svg)](https://github.com/leontedev/Locally)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-red.svg)](https://github.com/leontedev/Locally)
[![Swift Version](https://img.shields.io/badge/Swift-5.1-brightgreen.svg)](https://github.com/leontedev/Locally)
[![Twitter](https://img.shields.io/badge/Twitter-@leonte_dev-blue.svg?style=flat)](https://twitter.com/leonte_dev)
[![Website](https://img.shields.io/badge/Web-leonte.dev-lightgrey.svg?style=flat)](https://www.leonte.dev)

### Your Locations Agenda

**Locally is your private, favorite locations repo. Quickly jump into your preferred navigation app, with your choice of transit type.**

[![Download App Store](./download.svg)](https://apps.apple.com/ro/app/locally-navigation-companion/id1488488997)

![](onboard_s.png) ![](main_s.png) ![](add_s.png) ![](settings_s.png)


## Version 1.1
- Added Uber & Lyft navigation options
- Share Current Location (address & coordinates)
- Improvement to Current Location localization:
The app monitors "SignificantLocationChanges" to preserve battery life. However pressing the "Current Location" button will kick off the regular, and more precise startUpdatingLocation() function for 5 seconds. 

**Technologies used:**
- SwiftUI
- MapKit & CoreLocation
- CoreData
- CloudKit

*Check the [Projects tab](https://github.com/leontedev/Locally/projects) for upcoming features.*