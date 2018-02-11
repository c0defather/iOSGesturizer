# iOSGesturizer
Introducing <b>iOSGesturizer - </b> iOS library that easily enables unistroke gesture interaction for any apps running on iOS devices with 3D-touch.
<a href="https://imgflip.com/gif/24cpsb"><img src="https://i.imgflip.com/24cpsb.gif" title="made at imgflip.com"/></a>
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
Copyright 2018 Kuanysh Zhunussov

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
