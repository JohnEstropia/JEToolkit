# JEToolkit
JEToolkit is a collection of time-saving utilities for iOS development.


## JEDebugging class and friends

`JEDebugging` is a logging framework that will surely help you, your testers, and even your web development teammates.

### Main Features
- Provides clean and readable logs. Log messages are indented and marked by log level-specific markers.
This code:
``` obj-c
JELog(@"This is a sample log");
JELogNotice(@"This is a notice-level log");
JELogAlert(@"This is an alert-level log");
JEAssert(100 > 900, @"This is an assert failure log");
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
By default, this view will not be created in release mode. You can expand/collapse the HUD with a draggable button, and you can stretch the size of the view. The HUD also stays on top of all other views/windows, even if you open a modal view or if you create your own window. There is also a button to send log files via `UIActivityViewController`, as well as a button to clear all displayed logs.
- Configurable settings for the console logger, the file logger, and the HUD logger.


## JESynthesize() macro

The `JESynthesize()` macro declares the proper accessor and setter methods for you depending on the data type and the access modifier (`assign`, `strong`, etc) you set. And as an extension for associated objects, `JESynthesize` also supports `weak`.

Features:
- Provides a one-line declaration of properties in categories
- Supports all access modifiers (`assign`, `strong`, etc) including `weak`!
- Because the methods are generated at compile-time, you can get away without declaring any `@property`'s at all.
- Compile-time error checking to prevent mismatching access modifiers and data types (for example, setting `strong` on a `CGRect` type is not allowed)

Usage:
```obj-c
@implementation ...

JESynthesize(assign, CGRect, frame, setFrame);
JESynthesize(strong, NSString *, name, setName);
JESynthesize(copy, void(^)(void), completion, setCompletion);
JESynthesize(unsafe_unretained, id, unsafeObject, setUnsafeObject);
JESynthesize(weak, id<UITableViewDelegate>, delegate, setDelegate);
JESynthesize(strong, NSString *, readonlyID, changeReadonlyID);

...
```

If you want to know how the macro works, you can check the file *JESynthesize/JESynthesize.h*, or a more extensive explanation [here](http://nspicks.com/2013/12/15/cleaner-properties-implementation-in-categories/).


## Safety macros

- **`JEKeypath(...)`**: Returns and checks existence of a KVC (or KVO) keypath during compile time. For KVC operators, you can also use the `JEKeypathOperator(...)` variant. If the keypath doesn't exist, compilation will fail.
```obj-c
[obj setValue:@"John" forKey:JEKeypath(Person *, name)];
[obj setValue:@"John" forKey:JEKeypath(typeof(self), name)]; // typeof() operator
[obj setValue:@"John" forKey:JEKeypath(Person *, friend.name)]; // dot notation
NSArray *names = [friends valueForKeypath:JEKeypathOperator(unionOfObjects, Person *, name)];
```
- **`JEL10n(...)`**: A shorthand for `NSLocalizedString(...)` or `NSLocalizedStringFromTable(...)` that asserts the existence of a localization string in a *.strings* file at runtime.
```obj-c
label.text = JEL10n(@"myviewcontroller.label.title"); // load from Localizable.strings
label.text = JEL10n(@"myviewcontroller.label.title", @"CustomStrings"); // load from CustomStrings.strings
```
- **`JEScopeWeak(...) and JEScopeStrong(...)`**: Tired of writing `weakSelf`, `strongSelf`, `weakSomething`, `strongSomething`, etc? With `JEScopeWeak` and `JEScopeStrong` you can turn this
```obj-c
typeof(self) __weak weakSelf = self;
[request downloadSomethingWithCompletion:^{
    typeof(self) __strong strongSelf = weakSelf;
    [strongSelf doSomethingElse];
}];
```
to this
```obj-c
JEScopeWeak(self);
[request downloadSomethingWithCompletion:^{
    JEScopeStrong(self);
    [self doSomethingElse];
}];
```

## Other utility classes

- **`JEOrderedDictionary`**: An `NSMutableDictionary` subclass that remembers the order you inserted keys. Useful if you want to maintain chronological information or a constant ordering of keys.
- **`JEWeakCache`**: A thread-safe caching mechanism that is similar to `NSCache`. The difference is `JEWeakCache` only keeps a weak reference of the objects, that is, it will keep a reference of objects until nothing else is retaining them.


## Convenience categories

- **`NSObject`**: Tired of writing a corresponding `[NSNotificationCenter removeObserver:self]` in `dealloc`? You can now add observers to `NSNotificationCenter` that automatically unregister themselves on deallocation. Here's an example usage:
```obj-c
[self registerForNotificationsWithName:UIApplicationDidEnterBackgroundNotification
      targetBlock:^(NSNotification *note) {
          // do something...
      }];
```
- **`NSCache`**: Provides subscripting support similar to `NSDictionary`.
- **`NSDate`**, **`NSNumber`**, **`NSString`**, **`NSDate`**: Provides utilities for converting to and from known data types.
- **`NSURL`**: API for getting and setting extended attributes.
- **`UIColor`**: Color creation from RGB or hex.
- **`UILabel`**, **`UITextView`**: Provides utilities for computing sizes and heights for the display string.
- **`UIScrollView`**: Automatic handling of keyboard events, including auto-scrolling to descendant `firstResponder`s. All you have to do is setup your scrollViews (or more commonly, tableViews) this way:
```obj-c
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollView addKeyboardObserver];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scrollView removeKeyboardObserver];
}
```

## Installation
- Requires ARC

### via Cocoapods
```
pod 'JEToolkit', :git => 'https://github.com/JohnEstropia/JEToolkit.git'
```
Note that cocoapods currently doesn't support Swift yet.
### as Framework (iOS 8 above)
Clone this repository and drag and drop **JEToolkit.xcodeproj** to your app project.


## To-do list

- Push to cocoapods trunk
- Swift alternatives for some of the macros

Feel free to report any issues or send suggestions!

## License

JEToolkit is released under an MIT license. See the LICENSE file for more information
