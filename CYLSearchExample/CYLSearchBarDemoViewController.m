#import "CYLSearchBarDemoViewController.h"
#import <CYLSearchViewController/CYLSearchBarView.h>
#import <CYLSearchViewController/CYLSearchResources.h>

static NSString *CYLDemoText(NSString *key)
{
    return [CYLSearchResources localizedStringForKey:key];
}

@interface CYLSearchBarDemoViewController () <CYLSearchBarViewDelegate>
@property (nonatomic, strong, readonly) CYLSearchBarView *searchBarView;
@property (nonatomic, strong, readonly) UILabel *statusLabel;
@end

@implementation CYLSearchBarDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.searchBar");
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    _searchBarView = [[CYLSearchBarView alloc] initWithFrame:CGRectZero];
    _searchBarView.placeholder = CYLDemoText(@"demo.searchBar.placeholder");
    _searchBarView.showsCancelButton = YES;
    _searchBarView.fieldShadowOpacity = 0.12;
    _searchBarView.delegate = self;
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeSystem];
    [camera setImage:[UIImage systemImageNamed:@"camera"] forState:UIControlStateNormal];
    camera.accessibilityLabel = CYLDemoText(@"demo.searchBar.camera");
    _searchBarView.trailingAccessoryViews = @[camera];
    _searchBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_searchBarView];

    _statusLabel = [UILabel new];
    _statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _statusLabel.adjustsFontForContentSizeCategory = YES;
    _statusLabel.textColor = UIColor.secondaryLabelColor;
    _statusLabel.numberOfLines = 0;
    _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_statusLabel];
    [self cyl_showText:@""];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_searchBarView.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [_searchBarView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [_searchBarView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [_statusLabel.topAnchor constraintEqualToAnchor:_searchBarView.bottomAnchor constant:16],
        [_statusLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:16],
        [_statusLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-16],
    ]];
}

- (void)cyl_showText:(NSString *)text
{
    self.statusLabel.text = [NSString stringWithFormat:CYLDemoText(@"demo.searchBar.text"), text];
}

- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text
{
    [self cyl_showText:text];
}

- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView
{
    self.statusLabel.text = [NSString stringWithFormat:CYLDemoText(@"demo.searchBar.searched"), searchBarView.text ?: @""];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusLabel.text);
}

- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView
{
    searchBarView.text = nil;
    [self cyl_showText:@""];
}

@end
