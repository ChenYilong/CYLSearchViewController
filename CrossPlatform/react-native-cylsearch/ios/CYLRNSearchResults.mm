#import "CYLRNSearchResults.h"

@implementation CYLRNSearchResults

- (instancetype)init
{
  if (self = [super init]) {
    _results = @[];
  }
  return self;
}

- (NSArray *)searchView:(CYLSearchView *)searchView resultsForQuery:(NSString *)query
{
  return (self.resultsQuery == nil || [query isEqualToString:self.resultsQuery]) ? self.results : @[];
}

- (void)searchView:(CYLSearchView *)searchView configureResultCell:(UITableViewCell *)cell withResult:(id)result
{
  UIListContentConfiguration *configuration = [cell defaultContentConfiguration];
  configuration.text = [result isKindOfClass:[NSString class]] ? result : [result description];
  configuration.textProperties.numberOfLines = 0;
  cell.contentConfiguration = configuration;
  cell.accessibilityTraits |= UIAccessibilityTraitButton;
}

@end
