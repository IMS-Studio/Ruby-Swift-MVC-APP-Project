
#import <Foundation/Foundation.h>
#import "FImmutableSortedDictionary.h"
#import "FLLRBNode.h"

@interface FTreeSortedDictionary : FImmutableSortedDictionary

@property (nonatomic, copy, readonly) NSComparator comparator;
@property (nonatomic, strong, readonly) id<FLLRBNode> root;

- (id)initWithComparator:(NSComparator)aComparator;

// Override methods to return subtype
- (FTreeSortedDictionary *) insertKey:(id)aKey withValue:(id)aValue;
- (FTreeSortedDictionary *) removeKey:(id)aKey;

@end
