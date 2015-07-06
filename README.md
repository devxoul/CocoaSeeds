CocoaSeeds
==========

[![Gem](https://img.shields.io/gem/v/cocoaseeds.svg)](https://rubygems.org/gems/cocoaseeds)
[![Build Status](https://travis-ci.org/devxoul/CocoaSeeds.svg?branch=master)](https://travis-ci.org/devxoul/CocoaSeeds)

Git Submodule Alternative for Cocoa. Inspired by [CocoaPods](https://cocoapods.org).


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

<pre>
MyProject/
|-- MyProject/
|   |-- AppDelegate.swift
|   `-- ...
|-- MyProject.xcodeproj
|-- <b><i>Seedfile</i></b>
`-- ...
</pre>


**Seedfile**

```ruby
# seeds for all targets
github "Alamofire/Alamofire", "1.2.1", :files => "Source/*.{swift,h}"
github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{swift,h}"
github "devxoul/SwipeBack", "1.0.4"  # files default: */**.{h,m,mm,swift}
github "Masonry/SnapKit", "0.10.0", :files => "Source/*.{swift,h}"

# seeds for specific target
target :MyAppTest do
  github "Quick/Quick", "v0.3.1", :files => "Quick/**.{swift,h}"
  github "Quick/Nimble", "v0.4.2", :files => "Nimble/**.{swift,h}"
end
```

Using CocoaSeeds
----------------

```bash
$ seed install
```

Then all the source files will be automatically added to your Xcode project with group named 'Seeds'.

![Seeds-in-Xcode](https://cloud.githubusercontent.com/assets/931655/7502414/cbe45ecc-f476-11e4-9564-450e8887a054.png)


Resolving Filename Conflicts
----------------------------

Since CocoaSeeds uses including source files directly than linking dynamic frameworks, it is important to make sure that all source file names are different. CocoaSeeds provides a way to do this:

**Seedfile**

<pre>
<b>swift_seedname_prefix!</b>  # add this line

github "thoughtbot/Argo", "v1.0.3", :files => "Argo/*/*.swift"
github "thoughtbot/Runes", "v2.0.0", :files => "Source/*.swift"
</pre>

Then all of source files installed via CocoasSeeds will have file names with seed name as prefix.

| Before (filename) | After (seedname_filename) |
|---|---|
| `Seeds/Alamofire/Alamofire.swift` | `Seeds/Alamofire/Alamofire_Alamofire.swift` |
| `Seeds/Argo/Operators/Operators.swift` | `Seeds/Argo/Operators/Argo_Operators.swift` |
| `Seeds/Runes/Operators.swift` | `Seeds/Runes/Runes_Operators.swift` |


FAQ
---

Yes, you can add **Seeds** folder to **.gitignore**.


License
-------

CocoaSeeds is under MIT license. See the LICENSE file for more info.
