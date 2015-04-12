# JEToolkit
[![Version](https://img.shields.io/cocoapods/v/JEToolkit.svg?style=flat)](http://cocoadocs.org/docsets/JEToolkit)
[![Platform](https://img.shields.io/cocoapods/p/JEToolkit.svg?style=flat)](http://cocoadocs.org/docsets/JEToolkit)
[![License](https://img.shields.io/cocoapods/l/JEToolkit.svg?style=flat)](http://cocoadocs.org/docsets/JEToolkit)

JEToolkit is a collection of time-saving goodies for iOS development.

#### Now with Swift 1.2 support!
- Added Swift function counterparts to some Objective-C methods/macros that also makes sense in Swift code.
- Evertyhing is audited for nullability (`nullable`, `nonnull`, etc).
- Objective-C-only projects will still benefit from all available features!

## Modules Summary
- [**`JEToolkit/JEToolkit`**](#jetoolkit): Useful categories, functions, and macros for safety, convenience, and readability.
- [**`JEToolkit/JEDebugging`**](#jedebugging): A performant, configurable debugging framework that outputs to the debugger console, to an in-app console view, and/or to log files.
- [**`JEToolkit/JESettings`**](#jesettings): A class-based wrapper to NSUserDefaults and keychain access. Lets you access key-values just by declaring properties.
- [**`JEToolkit/JEOrderedDictionary`**]: An `NSMutableDictionary` subclass that remembers the order you inserted keys. Useful if you want to maintain chronological information or a constant ordering of keys.
- [**`JEToolkit/JEWeakCache`**]: A thread-safe caching mechanism that is similar to `NSCache`. The difference is `JEWeakCache` only keeps a weak reference of the objects, that is, it will keep a reference of objects until nothing else is retaining them.

Use each submodule independently (via cocoapods) or link everything as a whole package!


## <a name="jetoolkit">JEToolkit/JEToolkit</a> module
The `JEToolkit` module contains utilities that once you start using, you can never program without. They're that useful!

### Safer handling of `NSNotification`s (Objective-C and Swift)
Tired of writing a corresponding `[NSNotificationCenter removeObserver:self]` in `dealloc`? You can now add observers to `NSNotificationCenter` that automatically unregister themselves on deallocation. Here's an example usage:
```obj-c
// Obj-C
[self registerForNotificationsWithName:UIApplicationDidEnterBackgroundNotification
      targetBlock:^(NSNotification *note) {
          // do something...
}];
```
```swift
// Swift
self.registerForNotificationsWithName(UIApplicationDidEnterBackgroundNotification) { (note) in
    // do something...
}
```
Variants that let you pass in other parameters (such as `object`, `targetQueue`) are available as well!

### Adding properties to categories (Objective-C only)
Objective-C normally doesn't allow declaring `@properties` to categories. The **`JESynthesize()`** macro lets you do exactly that by declaring the proper accessor and setter methods for you depending on the data type and the access modifier (`assign`, `strong`, etc) you set. And as an extension for associated objects, `JESynthesize` also supports `weak` (!!).
- Provides a one-line declaration of properties in categories
- Supports all access modifiers (`assign`, `strong`, etc) including `weak`!
- Because the methods are generated at compile-time, you can get away without declaring any `@property`'s at all.
- Compile-time error checking to prevent mismatching access modifiers and data types (for example, setting `strong` on a `CGRect` type is not allowed)
```obj-c
// Obj-C
@implementation // ...

JESynthesize(assign, CGRect, frame, setFrame);
JESynthesize(strong, NSString *, name, setName);
JESynthesize(copy, void(^)(void), completion, setCompletion);
JESynthesize(unsafe_unretained, id, unsafeObject, setUnsafeObject);
JESynthesize(weak, id<UITableViewDelegate>, delegate, setDelegate);
JESynthesize(strong, NSString *, readonlyID, changeReadonlyID);

// ...
```

### Asserting localized strings (Objective-C and Swift)
The **`JEL10n()`** function is a replacement for `NSLocalizedString()` that asserts the existence of a localization (l10n) string in a *.strings* file at runtime.

```obj-c
// Obj-C
label.text = JEL10n(@"myviewcontroller.label.title"); // load from Localizable.strings
label.text = JEL10nFromTable(@"CustomStrings", @"myviewcontroller.label.title"); // load from CustomStrings.strings
```
```swift
// Swift
label.text = JEL10n("myviewcontroller.label.title") // load from Localizable.strings
label.text = JEL10nFromTable("CustomStrings", "myviewcontroller.label.title") // load from CustomStrings.strings
```

### Compile-time check of KVC keys (Objective-C only)
The **`JEKeypath(...)`** macro returns and checks existence of a KVC (or KVO) keypath during compile time. For KVC operators, you can also use the `JEKeypathOperator(...)` variant. If the keypath doesn't exist, compilation will fail.
```obj-c
// Obj-C
[obj setValue:@"John" forKey:JEKeypath(Person *, name)];
[obj setValue:@"John" forKey:JEKeypath(typeof(self), name)]; // typeof() operator
[obj setValue:@"John" forKey:JEKeypath(Person *, friend.name)]; // dot notation
NSArray *names = [friends valueForKeypath:JEKeypathOperator(unionOfObjects, Person *, name)];
```
Refactoring proeprty names is not scary anymore!

### Elegant handling of weak-strong block capture (Objective-C only)
Tired of writing `weakSelf`, `strongSelf`, `weakSomething`, `strongSomething`, etc? With **`JEScopeWeak()`** and **`JEScopeStrong()`** you can turn this
```obj-c
// Obj-C
typeof(self) __weak weakSelf = self;
[request downloadSomethingWithCompletion:^{
    typeof(self) __strong strongSelf = weakSelf;
    [strongSelf doSomethingElse];
}];
```
to this
```obj-c
// Obj-C
JEScopeWeak(self);
[request downloadSomethingWithCompletion:^{
    JEScopeStrong(self);
    [self doSomethingElse];
}];
```
Breaking retain cycles without cluttering your code!

### Automatic keyboard handling for scrollviews (Objective-C and Swift)
A **`UIScrollView`** category allows automatic handling of keyboard events, including auto-scrolling to descendant `firstResponder`s. All you have to do is setup your scrollViews (or more commonly, tableViews) this way:
```obj-c
// Obj-C
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollView addKeyboardObserver];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scrollView removeKeyboardObserver];
}
```
```swift
// Swift
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.scrollView.addKeyboardObserver()
}
override func viewWillDisappea(animated: Bool) {
    super.viewWillDisappear(animated)
    self.scrollView.removeKeyboardObserver()
}
```

### And a whole lot more!

- **`NSCache`** subscripting support similar to `NSDictionary`
- **`NSDate`**, **`NSNumber`**, **`NSString`**, and **`NSDate`** utilities for converting to and from known data types
- **`NSURL`** API for getting and setting extended attributes
- **`UIColor`** creation from RGB or hex.
- **`UILabel`** and **`UITextView`** utilities for computing sizes and heights for the display string
- **`UITableView`** and **`UICollectionView`** utilities for type-safe dequeuing of cells
- and really, still a lot more!


## <a name="jedebugging">JEToolkit/JEDebugging</a> module
The `JEDebugging` module is a logging framework that will surely help you and your teammates (even the server guys and your testers!)

### Main Features
- Provides clean and readable logs. Log messages are indented and marked by log level-specific markers.
This code:
``` obj-c
// Obj-C
JELog(@"This is a sample log");
JELogNotice(@"This is a notice-level log");
JELogAlert(@"This is an alert-level log");
JEAssert(100 > 900, @"This is an assert failure log");
```
``` swift
// Swift
JELog("This is a sample log")
JELogNotice("This is a notice-level log")
JELogAlert("This is an alert-level log")
JEAssert(100 > 900, "This is an assert failure log")
```
will print out this way:
<br/><img src="https://cloud.githubusercontent.com/assets/3029684/4608336/3d4865c4-527c-11e4-8093-ddc912a9b3f2.png" alt="Console screenshot" width="524" />
- More informative `debugDescription`s for common NSFoundation objects. For example, inspecting a dictionary using the lldb `po` command also tells what types the keys and values are (also note that `NSNumber`s show the actual data type of the stored value):
<br /><img src="https://cloud.githubusercontent.com/assets/3029684/4608381/f75bfc90-527d-11e4-83f5-c90dd9b9c70b.png" alt="Console screenshot" width="588" />
- The awesome `JEDump(...)` macro lets you inspect and log anything you throw at it: ints, C arrays, structs, objects, blocks, etc. Check out the *JEToolkitTests* unit test or the *JEToolkitDemo* project to view more sample outputs and sample usages.
- All logging are thread-safe.
- Option to save logs to files. Log files are separated by date, and there is an API to enumerate the logs' `NSData`s or `NSURL`s.
- Option to display a lightweight, inline HUD console from within the app itself.
<br /><img src="https://cloud.githubusercontent.com/assets/3029684/4608566/52e84ab4-5283-11e4-9f51-b986eeb8169d.gif" alt="Inline HUD screenshot" /><br />
By default, this view will not be created in release mode. You can expand/collapse the HUD with a draggable button, and you can stretch the size of the view. The HUD also stays on top of all other views/windows, even if you open a modal view or if you create your own window. There is also a button to send log files via `UIActivityViewController` (Air-Drop is a godsend!), as well as a button to clear all displayed logs.
- Configurable settings for the console logger, the file logger, and the HUD logger.


## <a name="jesettings">JEToolkit/JESettings</a> module
















## Installation
- Requires iOS 7 SDK and above
- Requires ARC

### Install via Cocoapods (Objective-C only)
```
pod 'JEToolkit', '~> 2.0'
```
Unfortunately, Cocoapod's Swift support requires the library to be compiled as a Framework, which isn't supported on iOS 7.
Thus, Swift files were intendedly not included in JEToolkit's podspec so that Objective-C-only projects can still use JEToolkit as a static library, and without requiring the Swift runtime.
To use with Swift, install as a submodule.
### Install manually
The recommended way to add manually is to install as a git submodule.
```
git submodule add https://github.com/JohnEstropia/JEToolkit.git <destination directory>
```
You can also clone the repository independent to the app **.xcodeproj** directory, then drag and drop **JEToolkit.xcodeproj** to your app project.


## Contributions?

Feel free to report any issues or send suggestions!
日本語で連絡していただいても構いません！

## License

JEToolkit is released under an MIT license. See the LICENSE file for more information
