# iOSGesturizer
Introducing <b>iOSGesturizer - </b> iOS library that easily enables unistroke gesture interaction for any apps running on iOS devices with 3D-touch.

## Features

- Customizable gestures.
- Gestures can be executed anywhere on the screen.
- Gesture mode is activated when a user applies additional pressure to the screen.
- Supports training mode to learn gestures (based on <a href="http://www.olivierbau.com/octopocus.php">OctoPocus</a>).

## Requirements

- Requires iOS 11 or later
- Requires 3D-touch

## Demo Project

Build and run the <i>FoodTrack</i> project in Xcode. Basically, we took an app provided in Apple's tutorials and applied iOSGesturizer to it.

## Installation

### The Pod Way

Simply add the following line to your <code>Podfile</code>:

	platform :ios, '11.0'
	pod 'iOSGesturizer'
	
### The Old School Way

The simplest way to use iOSGesturizer with your application is to add iOSGesturizer folder as a framework in Builds Settings in your XCode project.

## Usage

In AppDelegate class add the following line:
```
var window: UIWindow? = GesturizerWindow()
```

Also, in your main View Controller add the following lines:

```
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let window = UIApplication.shared.keyWindow! as! GesturizerWindow
    let view = GesturizerView()
    view.gestureHandler = {index in
        // index is the index of a gesture that was recognizer
	// do whatever you need
    }
    window.setGestureView(view: view)
    window.addSubview(view)
}
```

## Customization

For customization of gestures provide your data points into TemplateData class.


	
## License

```
MIT License

Copyright (c) 2018 Kuanysh Zhunussov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
