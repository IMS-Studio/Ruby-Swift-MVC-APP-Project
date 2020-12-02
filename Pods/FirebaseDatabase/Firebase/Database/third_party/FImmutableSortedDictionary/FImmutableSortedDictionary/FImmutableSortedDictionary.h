
#import <Foundation/Foundation.h>

/**
 * The size threshold where we use a tree backed sorted map instead of an array backed sorted map.
 * This is a more or less arbitrary chosen value, that was chosen to be large enough to fit most of object kind
 * of Firebase data, but small enough to not notice degradation in performance for inserting and lookups.
 * Feel free to empirically determine this constant, but don't expect much gain in real world performance.
 */
#define SORTED_DICTIONARY_ARRAY_TO_RB_TREE_SIZE_THRESHOLD 25

@interface FImmutableSortedDictionary : NSObject

+ (FImmutableSortedDictionary *)dictionaryWithComparator:(NSComparator)comparator;
+ (FImmutableSortedDictionary *)fromDictionary:(NSDictionary *)dictionary withComparator:(NSComparator)comparator;

- (FImmutableSortedDictionary *) insertKey:(id)aKey withValue:(id)aValue;
- (FImmutableSortedDictionary *) removeKey:(id)aKey;
- (id) get:(id) key;
- (id) getPredecessorKey:(id) key;
- (BOOL) isEmpty;
- (int) count;
- (id) minKey;
- (id) maxKey;
- (void) enumerateKeysAndObjectsUsingBlock:(void(^)(id key, id value, BOOL *stop))block;
- (void) enumerateKeysAndObjectsReverse:(BOOL)reverse usingBlock:(void(^)(id key, id value, BOOL *stop))block;
- (BOOL) contains:(id)key;
- (NSEnumerator *) keyEnumerator;
- (NSEnumerator *) keyEnumeratorFrom:(id)startKey;
- (NSEnumerator *) reverseKeyEnumerator;
- (NSEnumerator *) reverseKeyEnumeratorFrom:(id)startKey;

#pragma mark -
#pragma mark Methods similar to NSMutableDictionary

- (FImmutableSortedDictionary *) setObject:(id)anObject forKey:(id)aKey;
- (id) objectForKey:(id)key;
- (FImmutableSortedDictionary *) removeObjectForKey:(id)aKey;

@end
