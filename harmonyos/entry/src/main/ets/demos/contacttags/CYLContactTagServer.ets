import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { CYLPlaceholderSharedHUD } from 'cylplaceholder';
import {
  CYL_CONTACT_TAGS_MINE,
  CYL_CONTACT_TAGS_SERVER,
  CYLContactTag,
  CYLContactTagPreferences,
  cylContactTagsText
} from './CYLContactTagStore';

/** The `CYLContactTagsServerLatency` launch parameter (`--pi CYLContactTagsServerLatency 2`), in seconds. */
export const CYL_CONTACT_TAGS_LATENCY_KEY: string = 'CYLContactTagsServerLatency';

/**
 * The contact tags demo's simulated server (iOS `CYLContactTagServer`). The local cache, A, is the store's; the
 * server's data, B, is a second preference file that stands for the server shared by the user's devices. Every request
 * waits `latency` (5 s, or the launch parameter) and shows CYLTableViewPlaceHolder's HUD:
 * - uploading copies A's sections to B ("Uploading…", then "Upload finished");
 * - downloading reads B as network data ("Downloading…");
 * - "Sync" simulates an edit on another device (a random new tag, the first two tags swapped, written to B), then
 *   downloads it ("Syncing from other devices…").
 */
export class CYLContactTagServer {
  private context: common.Context;
  private storage: CYLContactTagPreferences;
  private timers: number[] = [];
  /** The HUD status of the next download ("Downloading…" by default; "Syncing from other devices…" for a sync). */
  private nextFetchStatus: string | undefined = undefined;

  constructor(context: common.Context, uiContext: UIContext) {
    this.context = context;
    this.storage = new CYLContactTagPreferences(context, CYL_CONTACT_TAGS_SERVER);
    // The HUD covers this window (iOS `containerView`).
    CYLPlaceholderSharedHUD().containerView = uiContext;
  }

  /** Forgets B (the demo's reset). */
  static reset(context: common.Context): void {
    new CYLContactTagPreferences(context, CYL_CONTACT_TAGS_SERVER).clear();
  }

  private get latency(): number {
    return (AppStorage.get<number>(CYL_CONTACT_TAGS_LATENCY_KEY) ?? 5) * 1000;
  }

  private later(action: () => void): void {
    this.timers.push(setTimeout(action, this.latency));
  }

  /** Downloads B's sections with `keys` after the latency, with a HUD; a key B does not have is left out. */
  fetch(keys: string[], completion: (sections: Map<string, CYLContactTag[]>) => void): void {
    const status = this.nextFetchStatus ?? cylContactTagsText(this.context, 'downloading');
    const finished = cylContactTagsText(this.context, this.nextFetchStatus === undefined ? 'downloaded' : 'synced');
    this.nextFetchStatus = undefined;
    CYLPlaceholderSharedHUD().showWithStatus(status);
    this.later(() => {
      const stored = this.storage.read();
      const sections = new Map<string, CYLContactTag[]>();
      keys.forEach((key: string) => {
        const items = stored.get(key);
        if (items !== undefined) {
          sections.set(key, items);
        }
      });
      CYLPlaceholderSharedHUD().showSuccessWithStatus(finished);
      completion(sections);
    });
  }

  /** Uploads `sections` (cache A's, after editing): copies them to B after the latency, with a HUD. */
  upload(sections: Map<string, CYLContactTag[]>): void {
    CYLPlaceholderSharedHUD().showWithStatus(cylContactTagsText(this.context, 'uploading'));
    this.later(() => {
      const stored = this.storage.read();
      sections.forEach((items: CYLContactTag[], key: string) => {
        stored.set(key, items);
      });
      this.storage.write(stored);
      CYLPlaceholderSharedHUD().showSuccessWithStatus(cylContactTagsText(this.context, 'uploaded'));
    });
  }

  /**
   * Simulates an edit on another device, written to B: a random new tag (a new id) at the end of "My Tags" and its
   * first two tags swapped. `localItems` stands in when B has nothing yet. Returns the title added.
   */
  simulateOtherDeviceEdit(localItems: CYLContactTag[]): string {
    const stored = this.storage.read();
    const tags = (stored.get(CYL_CONTACT_TAGS_MINE) ?? localItems).slice();
    const titles = new Set<string>(tags.map((tag: CYLContactTag) => tag.title));
    const pool = cylContactTagsText(this.context, 'otherDeviceTags').split(',').filter((title: string) => !titles.has(title));
    const added = pool.length > 0 ? pool[Math.floor(Math.random() * pool.length)] :
      `${cylContactTagsText(this.context, 'otherDeviceTags')} ${tags.length}`;
    tags.push(new CYLContactTag('o-' + util.generateRandomUUID(false).slice(0, 8), added));
    if (tags.length > 1) {
      const first = tags[0];
      tags[0] = tags[1];
      tags[1] = first;
    }
    stored.set(CYL_CONTACT_TAGS_MINE, tags);
    this.storage.write(stored);
    this.nextFetchStatus = cylContactTagsText(this.context, 'syncing');
    return added;
  }

  /** Stops the requests still waiting (the page went away). */
  cancel(): void {
    this.timers.forEach((timer: number) => clearTimeout(timer));
    this.timers = [];
  }
}
