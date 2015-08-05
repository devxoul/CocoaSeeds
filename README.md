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

You can get CocoaSeeds from [RubyGems](https://rubygems.org).

```bash
$ [sudo] gem install cocoaseeds
```


Using CocoaSeeds
----------------

### 1. Write Seedfile

*Seedfile* is a ruby script that demonstrates dependencies. You can specify third party libraries from GitHub repository with simple expressions. CocoaSeeds currently supports GitHub only, but supporting many other sources are in our future roadmap.

Let's make an empty file named **Seedfile** in the same directory with your Xcode project file. Then open it with your preferred editor.

Here is a sample Seedfile:

**Seedfile**

```ruby
github "Alamofire/Alamofire", "1.2.1", :files => "Source/*.{swift,h}"
github "devxoul/JLToast", "1.2.5", :files => "JLToast/*.{swift,h}"
github "devxoul/SwipeBack", "1.0.4"
github "Masonry/SnapKit", "0.10.0", :files => "Source/*.{swift,h}"

target :MyAppTest do
  github "Quick/Quick", "v0.3.1", :files => "Quick/**.{swift,h}"
  github "Quick/Nimble", "v0.4.2", :files => "Nimble/**.{swift,h}"
end
```

Can you guess what each lines do? Seedfile has only basic information about third party libraries. Let's look at the single line. Each expressions are made with sections: source, tag and files.

```ruby
github "devxoul/JLToast", "1.2.5", :files => "JLToast/*.{swift,h}"
~~~~~~~~~~~~~~~~~~~~~~~~  ~~~~~~~  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       (Source)            (Tag)              (Files)
```

| Section | Example                           | Required | Default               |
|---------|-----------------------------------|:--------:|:---------------------:|
| Source  | `github "devxoul/SwipeBack"`      | Required | -                     |
| Tag     | `1.0.4`                           | Required | -                     |
| Files   | `:files => "JLToast/*.{swift,h}"` | Optional | `*/**.{h,m,mm,swift}` |

Looking for using branches instead of tags? See the [Branch support](#branch-support) section.


#### Specifying targets

Third party libraries can be added specific targets by using target block. For example, you'd like to add some testing libraries such as Quick and Nimble to your test target, you can specify it in Seedfile:

```ruby
target :MyAppTest do
  github "Quick/Quick", "v0.3.1", :files => "Quick/**.{swift,h}"
  github "Quick/Nimble", "v0.4.2", :files => "Nimble/**.{swift,h}"
end
```

Source files in the target block will only be added to target.


### 2. Install dependencies

After you done with Seedfile, it's time to add those third party libraries into your project. This is pretty simple. Just open the terminal, cd to your project directory and execute `seed install` command.

```bash
$ seed install
```

Then all the source files will be automatically downloaded and added to your Xcode project with group named 'Seeds'.

![Seeds-in-Xcode](https://cloud.githubusercontent.com/assets/931655/7502414/cbe45ecc-f476-11e4-9564-450e8887a054.png)


### 3. Enjoy

Build your project and enjoy!


Beta Features
-------------

There are some beta features in CocoaSeeds which mean 'seemed to work but not fully tested in real world'. Please take care of using those features. (Don't be worry. I'm using these in my company project.)


#### Branch support

CocoaSeeds originally supports git tags only. For some reasons, such as using experimental feature branches like `swift-2.0`, you can use branches instead of tags. What you need to do is just replacing the tag with branch name. Anything else is same.

```ruby
github 'devxoul/SwiftyImage', 'swift-2.0', :files => 'SwiftyImage/SwiftyImage.swift'
```


#### Resolving filename conflicts

Since CocoaSeeds uses including source files directly than linking dynamic frameworks, it is important to make sure that all sources have different file names. CocoaSeeds provides a way to do this:

**Seedfile**

<pre>
<b>swift_seedname_prefix!</b>  # add this line

github "thoughtbot/Argo", "v1.0.3", :files => "Argo/*/*.swift"
github "thoughtbot/Runes", "v2.0.0", :files => "Source/*.swift"
</pre>

Then all of source files installed via CocoasSeeds will have names with the seed names as prefix.

| Before *(filename)* | After *(seedname_filename)* |
|---|---|
| `Seeds/Alamofire/Alamofire.swift` | `Seeds/Alamofire/Alamofire_Alamofire.swift` |
| `Seeds/Argo/Operators/Operators.swift` | `Seeds/Argo/Operators/Argo_Operators.swift` |
| `Seeds/Runes/Operators.swift` | `Seeds/Runes/Runes_Operators.swift` |


FAQ
---

* Are you using this in your real-world project? (Does Apple allows the apps to be submitted on AppStore using CocoaSeeds?)
    * Of course I am. I'm developing the social media service that 1.6 million users are using. It's on AppStore without any complaints from Apple.

* Can I ignore **Seeds** folder in VCS *(version control system)*?
    * Yes, you can make **Seeds** folder to be ignored.


License
-------

**CocoaSeeds** is under MIT license. See the LICENSE file for more info.
