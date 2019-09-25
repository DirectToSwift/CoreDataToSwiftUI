<h2>CoreData to SwiftUI
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

![Swift5.1](https://img.shields.io/badge/swift-5.1-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![watchOS](https://img.shields.io/badge/os-watchOS-green.svg?style=flat)
![Travis](https://api.travis-ci.org/DirectToSwift/CoreDataToSwiftUI.svg?branch=chore/replace-zeeql-1&style=flat)

_Going fully declarative_: Direct to SwiftUI.

WORK IN PROGRESS:
Supposedly this will eventually be a 
[Direct to SwiftUI](https://github.com/DirectToSwift/DirectToSwiftUI),
just using 
[CoreData](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1) 
instead of [ZeeQL](http://zeeql.io).


## Notes

The library name is intentionally kept as DirectToSwiftUI. Only the package
is a different one.
Which implies that you can't use CoreData to SwiftUI and Direct to SwiftUI
together!


## Requirements

CoreData to SwiftUI requires an environment capable to run SwiftUI.
That is: macOS Catalina, iOS 13 or watchOS 6.
In combination w/ Xcode 11.

Note that you can run iOS 13/watchOS 6 apps on Mojave in the emulator,
so that is fine as well.

## Using the Package

You can either just drag the Direct to SwiftUI Xcode project into your own
project,
or you can use Swift Package Manager.

The package URL is:
[https://github.com/DirectToSwift/CoreDataToSwiftUI.git
](https://github.com/DirectToSwift/CoreDataToSwiftUI.git).


## Misc

- [The Environment](Sources/DirectToSwiftUI/Environment/README.md)
- [Views](Sources/DirectToSwiftUI/Views/README.md)
- [Database Setup](Sources/DirectToSwiftUI/DatabaseSetup.md)

## What it looks like

A demo application using the Sakila database is provided:
[DVDRentalCoreData](https://github.com/DirectToSwift/DVDRentalCoreData).

### Watch

<p float="left" valign="top">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/01-homepage.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/02-customers.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/03-customer.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/04-movies.png?v=2">
</p>

### Phone

<p float="left" valign="top">
<img width="320" src="http://www.alwaysrightinstitute.com/images/d2s/limited-entities.png">
<img width="320" src="http://www.alwaysrightinstitute.com/images/d2s/list-customer-default.png">
</p>

### macOS

Still too ugly to show, but works in a very restricted way ;-) 

## Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like
[feedback](https://twitter.com/ar_institute),
GitHub stars,
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
