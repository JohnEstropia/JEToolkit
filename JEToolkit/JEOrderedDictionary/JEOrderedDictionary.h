//
//  JEOrderedDictionary.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

/*! The JEOrderedDictionary class is an NSMutableDictionary subclass that remembers the order of inserted keys. This is typically useful in cases where the chronological information or a constant ordering of keys is important.
 */
@interface JEOrderedDictionary : NSMutableDictionary

/*! Returns the object for the first key added to the dictionary
 @return The object for the first key added to the receiver or nil if the dictionary is empty
 */
- (nullable id)firstObject;

/*! Returns the object for the last key added to the dictionary
 @return The object for the last key added to the receiver or nil if the dictionary is empty
 */
- (nullable id)lastObject;

/*! Returns the object at the specified index of the receiver.
 This method is the same as objectAtIndex:
 @param idx The index of the object to be retrieved
 @return If idx is beyond the end of the dictionary (that is, if idx is greater than or equal to the value returned by count), an NSRangeException is raised.
 */
- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

/*! Returns the object at the specified index of the receiver
 @param idx The index of the object to be retrieved
 @return If idx is beyond the end of the dictionary (that is, if idx is greater than or equal to the value returned by count), an NSRangeException is raised.
 */
- (nullable id)objectAtIndex:(NSUInteger)idx;

/*! Returns the first key added to the dictionary
 @return The first key added to the receiver or nil if the dictionary is empty
 */
- (nullable id)firstKey;

/*! Returns the last key added to the dictionary
 @return The last key added to the receiver or nil if the dictionary is empty
 */
- (nullable id)lastKey;

/*! Returns the key at the specified index of the receiver
 @param idx The index of the key to be retrieved
 @return If idx is beyond the end of the dictionary (that is, if idx is greater than or equal to the value returned by count), an NSRangeException is raised.
 */
- (nullable id)keyAtIndex:(NSUInteger)idx;

/*! Returns the index of the specified key
 @param key The key
 @return The index whose corresponding key value is equal to key. If none of the objects in the dictionary is equal to key, returns NSNotFound.
 */
- (NSUInteger)indexOfKey:(nonnull id)key;

/*! Applies a given block object to the entries of the dictionary.
 If the block sets *stop to YES, the enumeration stops.
 @param block A block object to operate on entries in the dictionary.
 */
- (void)enumerateIndexesAndKeysAndObjectsUsingBlock:(nonnull void (^)(NSUInteger idx, id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop))block;

/*! Applies a given block object to the entries of the dictionary.
 If the block sets *stop to YES, the enumeration stops.
 @param opts Enumeration options.
 @param block A block object to operate on entries in the dictionary.
 */
- (void)enumerateIndexesAndKeysAndObjectsWithOptions:(NSEnumerationOptions)opts
                                          usingBlock:(nonnull void (^)(NSUInteger idx, id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop))block;

/*! Applies a given block object to the entries of the dictionary at the specified indexes
 If the block sets *stop to YES, the enumeration stops.
 @param opts The indexes of the objects over which to enumerate.
 @param opts Enumeration options.
 @param block A block object to operate on entries in the dictionary.
 */
- (void)enumerateIndexesAndKeysAndObjectsAtIndexes:(nonnull NSIndexSet *)indexes
                                           options:(NSEnumerationOptions)opts
                                        usingBlock:(nonnull void (^)(NSUInteger idx, id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop))block;

@end
