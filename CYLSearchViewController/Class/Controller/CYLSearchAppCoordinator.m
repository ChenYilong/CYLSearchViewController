//
//  CYLSearchAppCoordinator.m
//  CYLSearchViewController
//

#import "CYLSearchAppCoordinator.h"
#import "CYLSearchMainViewController.h"

@interface CYLSearchSampleDataProvider : NSObject <CYLSearchDataProviding>

@property (nonatomic, copy) NSArray<NSString *> *items;

@end

@implementation CYLSearchSampleDataProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSUInteger index = 1; index <= 40; index++) {
            [items addObject:[NSString stringWithFormat:@"Sample result %lu - pull down to refresh",
                              (unsigned long)index]];
        }
        _items = [items copy];
    }
    return self;
}

- (NSArray<NSString *> *)searchResultsForQuery:(NSString *)query
{
    if (query.length == 0) {
        return self.items;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *item, NSDictionary *bindings) {
        return [item localizedCaseInsensitiveContainsString:query];
    }];
    return [self.items filteredArrayUsingPredicate:predicate];
}

- (void)reloadSearchResultsWithCompletion:(CYLSearchReloadCompletion)completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        completion(nil);
    });
}

@end

@implementation CYLSearchAppCoordinator

+ (UINavigationController *)rootNavigationController
{
    CYLSearchSampleDataProvider *dataProvider = [[CYLSearchSampleDataProvider alloc] init];
    CYLSearchMainViewController *searchController =
        [[CYLSearchMainViewController alloc] initWithDataProvider:dataProvider];
    return [[UINavigationController alloc] initWithRootViewController:searchController];
}

@end
