# JEToolkit
JEToolkit is a collection of common utilities for iOS development.

## JESynthesize() macro

The `JESynthesize()` macro declares the proper accessor and setter methods for you depending on the data type and the access modifier (`assign`, `strong`, etc) you set. And as an extension for associated objects, `JESynthesize` also supports `weak`.

Features:
- Provides a one-line declaration of properties in categories
- Supports all access modifiers (`assign`, `strong`, etc) including `weak`!
- Because the methods are generated at compile-time, you can get away without declaring any `@property`'s at all.
- Compile-time error checking to prevent mismatching access modifiers and data types (for example, setting `strong` on a `CGRect` type)

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

If you want to know how the macro works, you can check the file *Classes/JEAssociatedObject.h*, or a more extensive explanation [here](http://nspicks.com/2013/12/15/cleaner-properties-implementation-in-categories/).

## JEDebugging class and friends

`JEDebugging` is just another logging tool that provides several new functionalities.

Main Features:
- Provides clean and readable XCode console logs by overriding `debugDescription`
- Option to save logs to log files
- Option to view lightweight, inline console from within the app itself
- All logging are thread-safe

These features are implemented by several sub-modules:
### Readable debugging



## Other Utilities

- **`JEOrderedDictionary`**: An `NSMutableDictionary` subclass that remembers the order you inserted keys. Useful if you want to maintain chronological information or a constant ordering of keys.
- **`JEWeakCache`**: A thread-safe caching mechanism that is similar to `NSCache`. The difference is `JEWeakCache` only keeps a weak reference of the objects, that is, it will keep a reference of objects until nothing else is retaining them.
