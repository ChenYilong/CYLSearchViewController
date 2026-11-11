#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchExampleViewController.h"
#import <CYLSearchViewController/CYLSearchBarView.h>
#import <CYLSearchViewController/CYLSearchPlaceholderView.h>
#import <CYLSearchViewController/CYLSearchResources.h>

static NSString *CYLDemoText(NSString *key)
{
    return [CYLSearchResources localizedStringForKey:key];
}

@interface CYLSearchPlaceholderGalleryViewController : UITableViewController
@end

@implementation CYLSearchPlaceholderGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.styles");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CYLSearchPlaceholderStyleCount + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == CYLSearchPlaceholderStyleCount ? 3 : 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == CYLSearchPlaceholderStyleCount) return CYLDemoText(@"demo.custom");
    return [CYLSearchPlaceholderView imageNameForStyle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoOption"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoOption"];
    NSArray<NSString *> *messages = @[@"placeholder.empty", @"placeholder.search", @"placeholder.error", @"placeholder.network"];
    NSArray<NSString *> *custom = @[@"demo.custom.textOnly", @"demo.custom.imageOnly", @"demo.custom.both"];
    cell.textLabel.text = CYLDemoText(indexPath.section == CYLSearchPlaceholderStyleCount ? custom[indexPath.row] : messages[indexPath.row]);
    if (indexPath.section == CYLSearchPlaceholderStyleCount) {
        cell.imageView.image = indexPath.row == 0
            ? [[CYLSearchResources imageNamed:@"CYLSearchNoResults"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            : [UIImage systemImageNamed:@"heart.fill"];
    } else {
        UIImage *image = [CYLSearchResources imageNamed:[CYLSearchPlaceholderView imageNameForStyle:indexPath.section]];
        cell.imageView.image = indexPath.section == CYLSearchPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    cell.imageView.tintColor = UIColor.secondaryLabelColor;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYLSearchPlaceholderView *placeholder;
    if (indexPath.section < CYLSearchPlaceholderStyleCount) {
        placeholder = [[CYLSearchPlaceholderView alloc] initWithStyle:indexPath.section message:indexPath.row];
    } else if (indexPath.row == 0) {
        placeholder = [[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleNoResults text:CYLDemoText(@"demo.custom.text")];
    } else {
        UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
        if (indexPath.row == 1) {
            placeholder = [[CYLSearchPlaceholderView alloc] initWithImage:image message:CYLSearchPlaceholderMessageNetwork];
        } else {
            placeholder = [[CYLSearchPlaceholderView alloc] initWithImage:image text:CYLDemoText(@"demo.custom.text")];
        }
        placeholder.imageView.tintColor = UIColor.systemPinkColor;
    }
    UIViewController *detail = [UIViewController new];
    detail.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    detail.view.backgroundColor = UIColor.systemBackgroundColor;
    placeholder.frame = detail.view.bounds;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [detail.view addSubview:placeholder];
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@interface CYLSearchBarDemoViewController : UIViewController <CYLSearchBarViewDelegate>
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

@implementation CYLSearchDemoMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.title");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoMenu"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoMenu"];
    NSArray<NSString *> *rows = @[@"demo.reproduction", @"demo.styles", @"demo.searchBar"];
    cell.textLabel.text = CYLDemoText(rows[indexPath.row]);
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller;
    if (indexPath.row == 0) {
        CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
        controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    } else if (indexPath.row == 1) {
        controller = [[CYLSearchPlaceholderGalleryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    } else {
        controller = [CYLSearchBarDemoViewController new];
    }
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
