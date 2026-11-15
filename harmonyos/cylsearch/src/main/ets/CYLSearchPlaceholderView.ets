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

// The resource type of a media image (`$r('app.media.x')`); other images are system symbols.
const MEDIA_TYPE: number = 20000;

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
   * The image, 80 x 80 vp: a media image (tinted with `imageTintColor` while `tintsImage` is true, as iOS draws its
   * images as templates) or a system symbol (drawn in `imageTintColor`).
   */
  @Trace image: Resource | undefined = undefined;
  /**
   * The color of a template image and of a symbol (iOS `imageView.tintColor`, `secondaryLabelColor` by default).
   */
  @Trace imageTintColor: ResourceColor = $r('sys.color.font_secondary');
  /**
   * Whether a media image is drawn in `imageTintColor`; false for the colored empty image (iOS `.alwaysTemplate`
   * except `CYLSearchPlaceholderStyle.empty`).
   */
  @Trace tintsImage: boolean = true;
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
    const view = new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style),
      CYLSearchPlaceholderView.textForMessage(message));
    view.tintsImage = style !== CYLSearchPlaceholderStyle.empty;
    return view;
  }

  /**
   * A built-in image with your own text (iOS `-initWithStyle:text:`).
   */
  static withStyleText(style: CYLSearchPlaceholderStyle, text: ResourceStr): CYLSearchPlaceholderView {
    const view = new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style), text);
    view.tintsImage = style !== CYLSearchPlaceholderStyle.empty;
    return view;
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
   * The image of a style: the iOS image (`CYLSearch<Name>.png`, the Material Design icons and the colored empty
   * image), in the library's media.
   */
  static imageForStyle(style: CYLSearchPlaceholderStyle): Resource {
    const images: Resource[] = [
      $r('app.media.cyl_search_empty'),
      $r('app.media.cyl_search_no_results'),
      $r('app.media.cyl_search_error'),
      $r('app.media.cyl_search_wifi_off'),
      $r('app.media.cyl_search_signal_wifi_off'),
      $r('app.media.cyl_search_no_internet'),
      $r('app.media.cyl_search_cloud_off'),
      $r('app.media.cyl_search_sync_problem'),
      $r('app.media.cyl_search_sync_disabled'),
      $r('app.media.cyl_search_network_locked'),
      $r('app.media.cyl_search_bluetooth_disabled'),
      $r('app.media.cyl_search_location_off'),
      $r('app.media.cyl_search_public_off'),
      $r('app.media.cyl_search_error_outline'),
      $r('app.media.cyl_search_warning'),
      $r('app.media.cyl_search_report_problem'),
      $r('app.media.cyl_search_blocked'),
      $r('app.media.cyl_search_help'),
      $r('app.media.cyl_search_hourglass'),
      $r('app.media.cyl_search_locked'),
      $r('app.media.cyl_search_visibility_off'),
      $r('app.media.cyl_search_search_off'),
      $r('app.media.cyl_search_folder_off'),
      $r('app.media.cyl_search_folder_open'),
      $r('app.media.cyl_search_download_off'),
      $r('app.media.cyl_search_upload_off'),
      $r('app.media.cyl_search_inbox'),
      $r('app.media.cyl_search_broken_image'),
      $r('app.media.cyl_search_image_unavailable'),
      $r('app.media.cyl_search_photo_library'),
      $r('app.media.cyl_search_music_off'),
      $r('app.media.cyl_search_video_off'),
      $r('app.media.cyl_search_person_off'),
      $r('app.media.cyl_search_group_off'),
      $r('app.media.cyl_search_event_busy'),
      $r('app.media.cyl_search_empty_cart'),
      $r('app.media.cyl_search_favorite'),
      $r('app.media.cyl_search_battery_alert'),
      $r('app.media.cyl_search_unknown_device'),
      $r('app.media.cyl_search_phone_disabled'),
      $r('app.media.cyl_search_wrong_location')
    ];
    const index = style as number;
    return index >= 0 && index < images.length ? images[index] : images[0];
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
      if (this.placeholderView.image !== undefined && this.placeholderView.image.type === MEDIA_TYPE) {
        if (this.placeholderView.tintsImage) {
          Image(this.placeholderView.image)
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .fillColor(this.placeholderView.imageTintColor)
            .renderMode(ImageRenderMode.Template)
            .accessibilityLevel('no')
        } else {
          Image(this.placeholderView.image)
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .accessibilityLevel('no')
        }
      } else if (this.placeholderView.image !== undefined) {
        SymbolGlyph(this.placeholderView.image)
          .fontSize(80)
          .fontColor([this.placeholderView.imageTintColor])
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
