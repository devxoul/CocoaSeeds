CocoaSeeds
==========

[![Release](http://img.shields.io/github/release/devxoul/CocoaSeeds.svg?style=flat)](https://github.com/devxoul/CocoaSeeds/releases?style=flat)

Git Submodule Alternative for Cocoa.


Why?
----

- iOS 7 projects are not available to use Swift libraries from [CocoaPods](https://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).
    > ld: warning: embedded dylibs/frameworks only run on iOS 8 or later

- CocoaSeeds just downloads the source code and add to your Xcode project. No static libraries, no dynamic frameworks at all.
- Git Submodule sucks.
- It can be used with CocoaPods and Carthage.


Installation
------------

```bash
$ [sudo] gem install cocoaseeds
```


Seedfile
--------

You have to write a **Seedfile** in the same directory with **.xcodeproj**.

```ruby
github 'Alamofire/Alamofire', '1.2.1', :files => 'Source/*.{swift,h}'
github 'devxoul/JLToast', '1.2.2', :files => 'JLToast/*.{swift,h}'
github 'Masonry/SnapKit', '0.10.0', :files => 'Source/*.{swift,h}'
```

<pre>
MyProject/
|-- MyProject/
|   |-- AppDelegate.swift
|   `-- ...
|-- MyProject.xcodeproj
|-- <b>Seedfile</b>
`-- ...
</pre>


Using CocoaSeeds
----------------

```bash
$ seed install
```

Then all the source files will be automatically added to your Xcode project with group named 'Seeds'.

![Seeds-in-Xcode](https://cloud.githubusercontent.com/assets/931655/7502414/cbe45ecc-f476-11e4-9564-450e8887a054.png)


FAQ
---

Yes, you can add **Seeds** folder to **.gitignore**.


License
-------

CocoaSeeds is under MIT license. See the LICENSE file for more info.
