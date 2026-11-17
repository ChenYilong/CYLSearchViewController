#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchBarDemoViewController.h"
#import "CYLSearchExampleAppDelegate.h"
#import <SVGAPlayer/SVGA.h>
#import "CYLSearchExample-Swift.h"
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

static NSString *CYLDemoText(NSString *key)
{
    return [CYLSearchResources localizedStringForKey:key];
}

@interface CYLSearchPlaceholderGalleryViewController : UITableViewController
@end

/// A text of the example's own strings (CYLSearchTabs.bundle), as the tab titles.
static NSString *CYLExampleText(NSString *key)
{
    NSBundle *bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"CYLSearchTabs" ofType:@"bundle"]];
    return [bundle localizedStringForKey:key value:key table:@"CYLSearchTabs"];
}

/// The SVGA demo above the Examples list, as CYLTabBarController's Example-Rive shows its Rive and SVGA demos above the
/// Bell list: an SVGA animation that plays once (tap to play it again), and a button that switches where the tab icons
/// come from (SF Symbols, SVGA through the initialization keys, SVGA through a configuration file) and rebuilds the tab
/// bar (`CYLDemoTabIconSource`, also a launch argument).
@interface CYLSVGADemoHeaderView : UIView
@property (nonatomic, strong) SVGAPlayer *player;
@property (nonatomic, strong) UIButton *sourceButton;
@end

@implementation CYLSVGADemoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    self.player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    self.player.loops = 1;
    self.player.clearsAfterStop = NO;
    self.player.isAccessibilityElement = YES;
    self.player.accessibilityTraits = UIAccessibilityTraitButton;
    self.player.accessibilityLabel = CYLExampleText(@"svga.demo");
    self.player.accessibilityHint = CYLExampleText(@"svga.demo.hint");
    self.player.accessibilityIdentifier = @"CYLSVGADemoPlayer";
    [self.player addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)]];
    [self addSubview:self.player];

    UILabel *label = [UILabel new];
    label.text = CYLExampleText(@"svga.demo");
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = UIColor.secondaryLabelColor;
    label.numberOfLines = 0;
    label.isAccessibilityElement = NO;
    label.tag = 1;
    [self addSubview:label];

    self.sourceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sourceButton.titleLabel.numberOfLines = 0;
    self.sourceButton.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.sourceButton.accessibilityIdentifier = @"CYLSVGADemoSourceButton";
    self.sourceButton.accessibilityHint = CYLExampleText(@"svga.source.hint");
    [self.sourceButton addTarget:self action:@selector(switchSource) forControlEvents:UIControlEventTouchUpInside];
    [self.sourceButton setTitle:[NSString stringWithFormat:CYLExampleText(@"svga.source"), [self.class sourceName]] forState:UIControlStateNormal];
    [self addSubview:self.sourceButton];

    NSURL *url = [NSBundle.mainBundle URLForResource:@"tab_activity" withExtension:@"svga"];
    NSData *data = url ? [NSData dataWithContentsOfURL:url] : nil;
    if (data) {
        __weak typeof(self) weakSelf = self;
        [[SVGAParser new] parseWithData:data cacheKey:@"CYLSVGADemo" completionBlock:^(SVGAVideoEntity *videoItem) {
            weakSelf.player.videoItem = videoItem;
            [weakSelf play];
        } failureBlock:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = 16, width = CGRectGetWidth(self.bounds);
    self.player.frame = CGRectMake(inset, 12, 64, 64);
    UIView *label = [self viewWithTag:1];
    label.frame = CGRectMake(inset + 76, 12, width - inset * 2 - 76, 64);
    self.sourceButton.frame = CGRectMake(inset, 84, width - inset * 2, 44);
    self.sourceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
}

+ (NSString *)sourceName
{
    NSArray<NSString *> *names = @[ @"svga.source.symbols", @"svga.source.keys", @"svga.source.file" ];
    NSInteger source = [NSUserDefaults.standardUserDefaults integerForKey:@"CYLDemoTabIconSource"];
    return CYLExampleText(names[(NSUInteger)MAX(0, MIN(source, 2))]);
}

- (void)play
{
    [self.player stepToFrame:0 andPlay:YES];
}

- (void)switchSource
{
    NSInteger source = ([NSUserDefaults.standardUserDefaults integerForKey:@"CYLDemoTabIconSource"] + 1) % 3;
    [NSUserDefaults.standardUserDefaults setInteger:source forKey:@"CYLDemoTabIconSource"];
    // The examples tab stays selected in the new tab bar.
    [NSUserDefaults.standardUserDefaults setObject:@"1" forKey:@"CYLDemoTab"];
    UIWindow *window = self.window;
    window.rootViewController = [CYLSearchExampleAppDelegate rootViewController];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"CYLDemoTab"];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

@end

@implementation CYLSearchPlaceholderGalleryViewController

/// The messages shown with every style. The styles, images and texts are CYLTableViewPlaceHolder's CYLPlaceholderView
/// (the core's former CYLSearchPlaceholderView was a duplicate of it and is gone).
+ (NSArray<NSNumber *> *)messages
{
    return @[@(CYLPlaceholderMessageEmpty), @(CYLPlaceholderMessageNoResults), @(CYLPlaceholderMessageNoInternet),
             @(CYLPlaceholderMessageError)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.styles");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CYLPlaceholderStyleCount + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == CYLPlaceholderStyleCount ? 3 : (NSInteger)self.class.messages.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == CYLPlaceholderStyleCount) return CYLDemoText(@"demo.custom");
    return [CYLPlaceholderView imageNameForStyle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoOption"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoOption"];
    NSArray<NSString *> *custom = @[@"demo.custom.textOnly", @"demo.custom.imageOnly", @"demo.custom.both"];
    if (indexPath.section == CYLPlaceholderStyleCount) {
        cell.textLabel.text = CYLDemoText(custom[indexPath.row]);
        cell.imageView.image = indexPath.row == 0
            ? [[CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoResults] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            : [UIImage systemImageNamed:@"heart.fill"];
    } else {
        CYLPlaceholderMessage message = (CYLPlaceholderMessage)self.class.messages[indexPath.row].integerValue;
        cell.textLabel.text = [CYLPlaceholderView localizedTextForMessage:message];
        UIImage *image = [CYLPlaceholderView imageForStyle:indexPath.section];
        cell.imageView.image = indexPath.section == CYLPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    cell.imageView.tintColor = UIColor.secondaryLabelColor;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYLPlaceholderView *placeholder;
    if (indexPath.section < CYLPlaceholderStyleCount) {
        CYLPlaceholderMessage message = (CYLPlaceholderMessage)self.class.messages[indexPath.row].integerValue;
        placeholder = [[CYLPlaceholderView alloc] initWithStyle:indexPath.section message:message];
    } else if (indexPath.row == 0) {
        placeholder = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNoResults text:CYLDemoText(@"demo.custom.text")];
    } else {
        UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
        placeholder = [[CYLPlaceholderView alloc] initWithImage:image text:indexPath.row == 1 ? nil : CYLDemoText(@"demo.custom.text")];
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

@implementation CYLSearchDemoMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // The navigation title only: `title` would also rename the tab this menu sits in.
    self.navigationItem.title = CYLDemoText(@"demo.title");
    self.tableView.tableHeaderView = [[CYLSVGADemoHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 136)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // `-CYLDemoRow 2` on launch opens that row, for screenshots.
    static BOOL opened;
    NSString *row = [NSUserDefaults.standardUserDefaults stringForKey:@"CYLDemoRow"];
    if (opened || row.length == 0) return;
    opened = YES;
    NSInteger index = row.integerValue;
    if (index < 0 || index >= [self tableView:self.tableView numberOfRowsInSection:0]) return;
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // The fifth row: the SVGA tab bar hosted in SwiftUI (CYLSVGASwiftUIDemo.swift).
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoMenu"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoMenu"];
    NSArray<NSString *> *rows = @[@"demo.reproduction", @"demo.styles", @"demo.searchBar", @"demo.ports"];
    cell.textLabel.text = indexPath.row < (NSInteger)rows.count ? CYLDemoText(rows[indexPath.row]) : CYLExampleText(@"svga.swiftui");
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"CYLDemoRow%ld", (long)indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        // The SVGA tab bar hosted in SwiftUI, full screen (a tab bar cannot be pushed inside another one).
        UIViewController *host = [NSClassFromString(@"CYLSVGASwiftUIDemo") performSelector:@selector(viewController)];
        [self presentViewController:host animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    UIViewController *controller;
    if (indexPath.row == 0) {
        CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
        controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    } else if (indexPath.row == 1) {
        controller = [[CYLSearchPlaceholderGalleryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    } else if (indexPath.row == 2) {
        controller = [CYLSearchBarDemoViewController new];
    } else {
        // The Swift ports of five other search libraries' examples (docs/search-api-comparison.md).
        // The class is written in Swift (@objc(CYLSearchPortsViewController)); the app has no bridging header, so
        // its generated header does not list internal Swift classes.
        Class ports = NSClassFromString(@"CYLSearchPortsViewController");
        controller = [(UITableViewController *)[ports alloc] initWithStyle:UITableViewStyleInsetGrouped];
    }
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
