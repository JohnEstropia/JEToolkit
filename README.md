# JEToolkit
JEToolkit is a collection of common utilities for iOS development.


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


## JEDebugging class and friends

`JEDebugging` is just another logging tool that provides several new functionalities.

Main Features:
- All logging are thread-safe.
- Provides clean and readable XCode console logs by overriding `debugDescription`. Log messages are indented, and marked by icons (emoji).
- More informative `debugDescription`s for common NSFoundation objects. For example, printing an `NSDictionary` also tells what class the keys and values are.
- Option to save logs to files. Log files are separated by date, and there is an API to enumerate the `NSData`s for the files.
- Option to display a lightweight, inline HUD console from within the app itself. You can toggle the HUD with a draggable button, and you can stretch the size of the view. The HUD also stays on top of all other views/windows, even if you open a modal view or if you create your own window. The view also provides a way to take a screenshot with the console view hidden.
- JEDump() is a magical macro can log anything you throw at it: compiler primitives, objects, blocks, etc. Run the *JEToolkitTests* unit test to view sample outputs and sample usages.
- Configurable behavior for the console logger, the file logger, and the HUD logger.


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


## Categories

- **`NSCache`**: Provides subscripting support similar to `NSDictionary`.
- **`NSDate`**, **`NSNumber`**, **`NSString`**, **`NSDate`**: Provides utilities for converting to and from known data types.
- **`NSURL`**: API for getting and setting extended attributes.
- **`UIColor`**: Color creation from RGB or hex.
- **`UILabel`**, **`UITextView`**: Provides utilities for computing sizes and heights for the display string.
- **`UIScrollView`**: Automatic handling of keyboard events, including auto-scrolling to descendant `firstResponder`s. All you have to do is call `-addKeyboardObserver` on the scrollview instance.
