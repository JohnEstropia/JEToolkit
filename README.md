# JEToolkit
JEToolkit is a (growing) collection of common helpers for iOS development.


## JESynthesize() macro

Tired of declaring accessors and mutators for each property?

Want to implement properties in categories but find implementing associative objects too verbose?

`JESynthesize()` declares the proper accessor and setter methods for you depending on the data type and the access modifier (`assign`, `strong`, etc) all in compile time! And as an extension for associated objects, `JESynthesize` also supports `weak`.

```objc

@implementation ...

JESynthesize(assign, NSInteger, index, setIndex);
JESynthesize(strong, NSString *, name, setName);
JESynthesize(copy, void(^)(void), completion, setCompletion);
JESynthesize(unsafe_unretained, id, unsafeObject, setUnsafeObject);
JESynthesize(weak, id<UITableViewDelegate>, delegate, setDelegate);
JESynthesize(strong, NSString *, readonlyID, changeReadonlyID);
```

## JEDebugging class
