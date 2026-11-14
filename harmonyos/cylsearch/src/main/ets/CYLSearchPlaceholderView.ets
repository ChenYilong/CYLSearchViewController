import { common } from '@kit.AbilityKit';
import { CYLSearchResources } from './CYLSearchResources';

/**
 * The common placeholder kinds: an empty list, no search results, or an error (iOS `CYLSearchPlaceholderKind`).
 */
export enum CYLSearchPlaceholderKind {
  /**
   * Nothing to show yet.
   */
  empty = 0,
  /**
   * The search found nothing.
   */
  noResults = 1,
  /**
   * Loading failed.
   */
  error = 2
}

/**
 * The image of a placeholder (iOS `CYLSearchPlaceholderStyle`); each style has a system symbol on HarmonyOS.
 */
export enum CYLSearchPlaceholderStyle {
  /**
   * The `empty` image.
   */
  empty = 0,
  /**
   * The `noResults` image.
   */
  noResults = 1,
  /**
   * The `error` image.
   */
  error = 2,
  /**
   * The `wifiOff` image.
   */
  wifiOff = 3,
  /**
   * The `signalWifiOff` image.
   */
  signalWifiOff = 4,
  /**
   * The `noInternet` image.
   */
  noInternet = 5,
  /**
   * The `cloudOff` image.
   */
  cloudOff = 6,
  /**
   * The `syncProblem` image.
   */
  syncProblem = 7,
  /**
   * The `syncDisabled` image.
   */
  syncDisabled = 8,
  /**
   * The `networkLocked` image.
   */
  networkLocked = 9,
  /**
   * The `bluetoothDisabled` image.
   */
  bluetoothDisabled = 10,
  /**
   * The `locationOff` image.
   */
  locationOff = 11,
  /**
   * The `publicOff` image.
   */
  publicOff = 12,
  /**
   * The `errorOutline` image.
   */
  errorOutline = 13,
  /**
   * The `warning` image.
   */
  warning = 14,
  /**
   * The `reportProblem` image.
   */
  reportProblem = 15,
  /**
   * The `blocked` image.
   */
  blocked = 16,
  /**
   * The `help` image.
   */
  help = 17,
  /**
   * The `hourglass` image.
   */
  hourglass = 18,
  /**
   * The `locked` image.
   */
  locked = 19,
  /**
   * The `visibilityOff` image.
   */
  visibilityOff = 20,
  /**
   * The `searchOff` image.
   */
  searchOff = 21,
  /**
   * The `folderOff` image.
   */
  folderOff = 22,
  /**
   * The `folderOpen` image.
   */
  folderOpen = 23,
  /**
   * The `downloadOff` image.
   */
  downloadOff = 24,
  /**
   * The `uploadOff` image.
   */
  uploadOff = 25,
  /**
   * The `inbox` image.
   */
  inbox = 26,
  /**
   * The `brokenImage` image.
   */
  brokenImage = 27,
  /**
   * The `imageUnavailable` image.
   */
  imageUnavailable = 28,
  /**
   * The `photoLibrary` image.
   */
  photoLibrary = 29,
  /**
   * The `musicOff` image.
   */
  musicOff = 30,
  /**
   * The `videoOff` image.
   */
  videoOff = 31,
  /**
   * The `personOff` image.
   */
  personOff = 32,
  /**
   * The `groupOff` image.
   */
  groupOff = 33,
  /**
   * The `eventBusy` image.
   */
  eventBusy = 34,
  /**
   * The `emptyCart` image.
   */
  emptyCart = 35,
  /**
   * The `favorite` image.
   */
  favorite = 36,
  /**
   * The `batteryAlert` image.
   */
  batteryAlert = 37,
  /**
   * The `unknownDevice` image.
   */
  unknownDevice = 38,
  /**
   * The `phoneDisabled` image.
   */
  phoneDisabled = 39,
  /**
   * The `wrongLocation` image.
   */
  wrongLocation = 40,
  /**
   * The number of styles.
   */
  count = 41
}

/**
 * The localized message of a placeholder (iOS `CYLSearchPlaceholderMessage`).
 */
export enum CYLSearchPlaceholderMessage {
  /**
   * "No data".
   */
  empty = 0,
  /**
   * "No matching results".
   */
  noResults = 1,
  /**
   * "Something went wrong".
   */
  error = 2,
  /**
   * "Check your internet connection".
   */
  network = 3
}

const STYLE_NAMES: string[] = [
    'Empty',
    'NoResults',
    'Error',
    'WifiOff',
    'SignalWifiOff',
    'NoInternet',
    'CloudOff',
    'SyncProblem',
    'SyncDisabled',
    'NetworkLocked',
    'BluetoothDisabled',
    'LocationOff',
    'PublicOff',
    'ErrorOutline',
    'Warning',
    'ReportProblem',
    'Blocked',
    'Help',
    'Hourglass',
    'Locked',
    'VisibilityOff',
    'SearchOff',
    'FolderOff',
    'FolderOpen',
    'DownloadOff',
    'UploadOff',
    'Inbox',
    'BrokenImage',
    'ImageUnavailable',
    'PhotoLibrary',
    'MusicOff',
    'VideoOff',
    'PersonOff',
    'GroupOff',
    'EventBusy',
    'EmptyCart',
    'Favorite',
    'BatteryAlert',
    'UnknownDevice',
    'PhoneDisabled',
    'WrongLocation'
];

/**
 * An image above a message, centered: the empty, no-result and error states of a list (iOS
 * `CYLSearchPlaceholderView`). This class is the placeholder's content; `CYLSearchPlaceholderComponent` draws it.
 */
@ObservedV2
export class CYLSearchPlaceholderView {
  /**
   * The image, a system symbol drawn 80 vp high in the secondary text color.
   */
  @Trace image: Resource | undefined = undefined;
  /**
   * The message.
   */
  @Trace text: ResourceStr = '';

  /**
   * Your own image and text (iOS `-initWithImage:text:`).
   */
  constructor(image: Resource | undefined, text: ResourceStr) {
    this.image = image;
    this.text = text;
  }

  /**
   * A placeholder of a common kind with its built-in image and message (iOS `-initWithKind:`).
   */
  static withKind(kind: CYLSearchPlaceholderKind): CYLSearchPlaceholderView {
    if (kind === CYLSearchPlaceholderKind.noResults) {
      return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.noResults,
        CYLSearchPlaceholderMessage.noResults);
    }
    if (kind === CYLSearchPlaceholderKind.error) {
      return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.error,
        CYLSearchPlaceholderMessage.error);
    }
    return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.empty, CYLSearchPlaceholderMessage.empty);
  }

  /**
   * A built-in image with a built-in message (iOS `-initWithStyle:message:`).
   */
  static withStyleMessage(style: CYLSearchPlaceholderStyle,
    message: CYLSearchPlaceholderMessage): CYLSearchPlaceholderView {
    return new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style),
      CYLSearchPlaceholderView.textForMessage(message));
  }

  /**
   * A built-in image with your own text (iOS `-initWithStyle:text:`).
   */
  static withStyleText(style: CYLSearchPlaceholderStyle, text: ResourceStr): CYLSearchPlaceholderView {
    return new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style), text);
  }

  /**
   * Your own image with a built-in message (iOS `-initWithImage:message:`).
   */
  static withImageMessage(image: Resource | undefined,
    message: CYLSearchPlaceholderMessage): CYLSearchPlaceholderView {
    return new CYLSearchPlaceholderView(image, CYLSearchPlaceholderView.textForMessage(message));
  }

  /**
   * The name of the image of a style, as on iOS ("CYLSearchNoResults"); (iOS `+imageNameForStyle:`).
   */
  static imageNameForStyle(style: CYLSearchPlaceholderStyle): string {
    const index = style as number;
    return index >= 0 && index < STYLE_NAMES.length ? `CYLSearch${STYLE_NAMES[index]}` : 'CYLSearchEmpty';
  }

  /**
   * The system symbol of a style.
   */
  static imageForStyle(style: CYLSearchPlaceholderStyle): Resource {
    const symbols: Resource[] = [
    $r('sys.symbol.archivebox'),
    $r('sys.symbol.magnifyingglass'),
    $r('sys.symbol.exclamationmark_circle'),
    $r('sys.symbol.wifi_slash'),
    $r('sys.symbol.wifi_slash'),
    $r('sys.symbol.wifi_slash'),
    $r('sys.symbol.icloud_slash'),
    $r('sys.symbol.exclamationmark_triangle'),
    $r('sys.symbol.nosign'),
    $r('sys.symbol.lock'),
    $r('sys.symbol.bluetooth_slash'),
    $r('sys.symbol.map_slash'),
    $r('sys.symbol.nosign'),
    $r('sys.symbol.exclamationmark_circle'),
    $r('sys.symbol.exclamationmark_triangle'),
    $r('sys.symbol.exclamationmark_triangle'),
    $r('sys.symbol.nosign'),
    $r('sys.symbol.questionmark_circle'),
    $r('sys.symbol.hourglass'),
    $r('sys.symbol.lock'),
    $r('sys.symbol.eye_slash'),
    $r('sys.symbol.magnifyingglass'),
    $r('sys.symbol.folder'),
    $r('sys.symbol.folder'),
    $r('sys.symbol.arrow_down_circle'),
    $r('sys.symbol.arrow_up_circle'),
    $r('sys.symbol.archivebox'),
    $r('sys.symbol.picture'),
    $r('sys.symbol.picture'),
    $r('sys.symbol.picture'),
    $r('sys.symbol.nosign'),
    $r('sys.symbol.video'),
    $r('sys.symbol.person_2'),
    $r('sys.symbol.person_2'),
    $r('sys.symbol.calendar'),
    $r('sys.symbol.cart'),
    $r('sys.symbol.heart'),
    $r('sys.symbol.battery'),
    $r('sys.symbol.questionmark_circle'),
    $r('sys.symbol.phone'),
    $r('sys.symbol.map_slash')
    ];
    const index = style as number;
    return index >= 0 && index < symbols.length ? symbols[index] : symbols[0];
  }

  /**
   * The text of a built-in message, as a resource that follows the app's language.
   */
  static textForMessage(message: CYLSearchPlaceholderMessage): Resource {
    if (message === CYLSearchPlaceholderMessage.noResults) {
      return $r('app.string.cyl_placeholder_search');
    }
    if (message === CYLSearchPlaceholderMessage.error) {
      return $r('app.string.cyl_placeholder_error');
    }
    if (message === CYLSearchPlaceholderMessage.network) {
      return $r('app.string.cyl_placeholder_network');
    }
    return $r('app.string.cyl_placeholder_empty');
  }

  /**
   * The text of a built-in message as a string, in the app's language.
   */
  static localizedTextForMessage(context: common.Context, message: CYLSearchPlaceholderMessage): string {
    const keys: string[] = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
    return CYLSearchResources.localizedString(context, keys[message as number] ?? keys[0]);
  }
}

/**
 * Draws a `CYLSearchPlaceholderView`: its image above its message, centered in the space it is given.
 */
@ComponentV2
export struct CYLSearchPlaceholderComponent {
  /**
   * The placeholder to draw.
   */
  @Require @Param placeholderView: CYLSearchPlaceholderView;

  build() {
    Column({ space: 12 }) {
      if (this.placeholderView.image !== undefined) {
        SymbolGlyph(this.placeholderView.image)
          .fontSize(80)
          .fontColor([$r('sys.color.font_secondary')])
          .accessibilityLevel('no')
      }
      Text(this.placeholderView.text)
        .fontSize(17)
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(16)
    .accessibilityGroup(true)
  }
}
