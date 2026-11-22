#import <Foundation/Foundation.h>
#import "CYLRNSearchSupport.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * The results data source of both components (`CylsearchView` and `CylsearchListView`): the `results` of JavaScript and the
 * rows' text; the match highlight is the core's option (`highlightsResultMatches`, `resultMatchHighlightColor`). A
 * `resultsQuery` lists only the results that belong to the text (a late answer never fills the list of a newer text); nil
 * lists the results for every text.
 */
@interface CYLRNSearchResults : NSObject <CYLSearchViewDataSource>
@property (nonatomic, copy) NSArray<NSString *> *results;
@property (nonatomic, copy, nullable) NSString *resultsQuery;
@end

NS_ASSUME_NONNULL_END
