/**
 * The corner radius that draws a capsule (a corner as round as the height allows; the platform limits a radius to half
 * the height). 0 is square and no other value is special: pass this constant by name, never the literal 1000.
 *
 * Repo-local until CollectionViewClassifyMenu ships its own capsule constant (item 8b of
 * docs/animated-icon-component.md); then this one is replaced by it.
 */
export const CYL_CORNER_RADIUS_CAPSULE: number = 1000;
