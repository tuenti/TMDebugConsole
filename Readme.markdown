# TMDebugConsole

`TMDebugConsole` is a simple in-app console to be used with [Cocoa Lumberjack.](https://github.com/CocoaLumberjack/CocoaLumberjack) It allows you to see your logs on the device, without needing to be paired with a debug session in XCode, using different colors for errors, warnings, and informative messages

## Screenshots

![Screenshot #1](Screenshots/1.png)
![Screenshot #1](Screenshots/2.png)
![Screenshot #1](Screenshots/3.png)

## Installing

### Using CocoaPods

1. Include the following line in your `Podfile`:
   ```
   pod 'TMDebugConsole', :git => 'https://github.com/tuenti/TMDebugConsole'
   ```
2. Run `pod install`

### Manually

1. Clone, add as a submodule or [download TMDebugConsole](https://github.com/tuenti/TMDebugConsole/zipball/master).
2. Add all the files under `Classes` to your project.
3. Make sure your project is configured to use ARC.

## Dependencies of the sample app

The sample app uses [Cocoa Lumberjack.](https://github.com/CocoaLumberjack/CocoaLumberjack). This dependency is managed using [CocoaPods](http://cocoapods.org). Once you have cloned this repository, and with CocoaPods set up, please install these dependencies opening a Terminal window, changing to the Xcode project directory and running
   ```
   $ pod install
   ```
   
Make sure to always open the Xcode workspace instead of the project file when building the sample app:
   ```
   $ open TMDebugConsoleSample.xcworkspace
   ```

## Credits & Contact

`TMDebugConsole` was created by [iOS team at Tuenti Technologies S.L.](http://github.com/tuenti).
You can follow Tuenti engineering team on Twitter [@tuentieng](http://twitter.com/tuentieng).

## License

`TMDebugConsole` is available under the Apache License, Version 2.0. See LICENSE file for more info.
