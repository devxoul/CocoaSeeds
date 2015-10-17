CocoaSeeds
==========

[![Gem](https://img.shields.io/gem/v/cocoaseeds.svg)](https://rubygems.org/gems/cocoaseeds)
[![Build Status](https://travis-ci.org/devxoul/CocoaSeeds.svg?branch=master)](https://travis-ci.org/devxoul/CocoaSeeds)

Git Submodule Alternative for Cocoa. Inspired by [CocoaPods](https://cocoapods.org).


Why?
----

- iOS 7 projects do not support the use of Swift libraries from [CocoaPods](https://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).
    > ld: warning: embedded dylibs/frameworks only run on iOS 8 or later

- CocoaSeeds just downloads the source code and add it to your Xcode project. No static libraries, no dynamic frameworks.
- Git Submodule sucks.
- It can be used with CocoaPods and Carthage.


Installation
------------

You can get CocoaSeeds from [RubyGems](https://rubygems.org).

```bash
$ [sudo] gem install cocoaseeds
```


How to Use CocoaSeeds
----------------

### 1. Write a Seedfile

A *Seedfile* is a ruby script that manifests the dependencies of your project. You can manage third party libraries by simply specifying them in the Seedfile. Currently, CocoaSeeds supports only GitHub and BitBucket repositories. However, we are planning to support other version control systems.

Let's make an empty file named **Seedfile** in the directory where your Xcode project file is located. Here is a sample Seedfile:

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

Can you guess what each line does? It has basic information about the third party libraries. 

Each line in a Seedfile consists of three parts: source, tag, and files. Let's look at the second line of the previous sample.

```ruby
github "devxoul/JLToast", "1.2.5", :files => "JLToast/*.{swift,h}"
~~~~~~~~~~~~~~~~~~~~~~~~  ~~~~~~~  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       (Source)            (Tag)              (Files)
```

| Parts  | Example                           | Required | Default               |
|--------|-----------------------------------|:--------:|:---------------------:|
| Source | `github "devxoul/SwipeBack"`      | Required | -                     |
| Tag    | `1.0.4`                           | Required | -                     |
| Files  | `:files => "JLToast/*.{swift,h}"` | Optional | `*/**.{h,m,mm,swift}` |

> **Tip:** You can pass an array to `:files` for multiple file patterns:
>
> ```ruby
> :files => ["/path1/*.swift", "/path2/*.swift"]
> ```

Want to use branch names instead of tags? See the [Branch support](#branch-support) section.

#### Specifying targets

Third party libraries can be included as a specific target by creating a target block. For example, if you want to add some testing libraries such as Quick and Nimble into test target, you can specify them like this:

```ruby
target :MyAppTest do
  github "Quick/Quick", "v0.3.1", :files => "Quick/**.{swift,h}"
  github "Quick/Nimble", "v0.4.2", :files => "Nimble/**.{swift,h}"
end
```

### 2. Install dependencies

After you are done with your Seedfile, it's time to load those libraries into your project. This is pretty simple. Just open the terminal, cd to your project directory and execute `seed install` command.

```bash
$ seed install
```

Then, all the source files will be automatically downloaded and added to a group named 'Seeds'.

![Seeds-in-Xcode](https://cloud.githubusercontent.com/assets/931655/7502414/cbe45ecc-f476-11e4-9564-450e8887a054.png)


### 3. Enjoy

Build your project and enjoy!


Beta Features
-------------

There are some beta features that seem to work but are not fully tested in the real world. Please keep that in mind if you want to use those features. (Don't worry too much. I'm using them for my company's projects.)


#### Branch support

Previously, you could specify a library only with a tag. However, depending on your situation, such as using an experimental branch like `swift-2.0`, you can specify them with a branch name instead of the tag. What you need to do is just replacing the tag with the branch name.

```ruby
github 'devxoul/SwiftyImage', 'swift-2.0', :files => 'SwiftyImage/SwiftyImage.swift'
```


#### Resolving filename conflicts

Since CocoaSeeds tries to include source files directly rather than linking dynamic frameworks, it is important to make sure that all sources have different names. CocoaSeeds provides a way to do this:

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

* Are you using this in real-world projects? (Does Apple allow apps to use CocoaSeeds?)
    * Of course I am. I'm developing a social media service that has about 1.6 million users. The app is on AppStore without any complaints from Apple.

* Can I ignore **Seeds** folder in VCS *(version control system)*?
    * Yes, you can ignore the **Seeds** folder (by adding it to `.gitignore` if you use Git).


License
-------

**CocoaSeeds** is under MIT license. See the LICENSE file for more info.
