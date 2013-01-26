## RCLocationManager
Easy to use iOS class to manage location system, very useful.

This is allows you to **tracking user location**, **monitoring regions** and obtain the **user location**.

<img src="http://f.cl.ly/items/0F0u0b102G1V2T0E252g/Captura%20de%20pantalla%202012-08-05%20a%20la(s)%2009.37.25.png" />

## Usage
- Clone the repository:

```bash
$ git clone git@github.com:rcabamo/RCLocationManager.git
```

- Check out the sample project.

- Drag the ```RCLocationManager``` folder into your project.
- Include the header file:

```objc
#import "RCLocationManager.h"
```

- Create a ```RCLocationManager``` and suscribe the notifications. Example:

```objc
RCLocationManager *locationManager = [[RCLocationManager alloc] initWithUserDistanceFilter:kCLLocationAccuracyHundredMeters userDesiredAccuracy:kCLLocationAccuracyBest purpose:@"My custom purpose message" delegate:self];
```
- Check the header file for all the things you can customize.

## Dependencies

```RCLocationManager``` requires your application to be linked against the ```CoreLocation.framework``` framework.

## Compatibility
- Supports ARC. If you want to use it in a project without ARC, mark ```RCLocationManager.m``` with the linker flag ```-fobjc-arc```.

##Credits

Thanks to [Alejandro Martinez](https://twitter.com/alexito4) for his help :)

## License
Copyright 2012 [Ricardo Caballero](http://twitter.com/rcabamo) (hello@rcabamo.es)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
 limitations under the License. 

Attribution is not required, but appreciated.