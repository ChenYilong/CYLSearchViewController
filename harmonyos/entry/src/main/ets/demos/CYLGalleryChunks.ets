/**
 * The Placeholder styles page has 42 sections (168 glass tags). Building them all in one go blocks the ArkTS main
 * thread for more than 6 seconds on the emulator (appfreeze THREAD_BLOCK_6S, "App died"), so the page builds its tag
 * lists in chunks of a few sections and adds the next chunk when the scroll reaches the end.
 */

// MARK: - Pure logic (begin)

/**
 * The sections of one chunk: [first, count] of the chunk's sections, or an empty range past the last section.
 */
function cylGalleryChunkRange(chunk: number, chunkSize: number, total: number): number[] {
  const first: number = Math.min(chunk * chunkSize, total);
  const end: number = Math.min(first + chunkSize, total);
  return [first, end - first];
}

/**
 * The number of chunks to show after the scroll reached the end: one more, never more than the chunks that exist.
 */
function cylGalleryChunksAfterReachEnd(shown: number, chunkSize: number, total: number): number {
  const all: number = Math.ceil(total / chunkSize);
  return Math.min(shown + 1, all);
}

// MARK: - Pure logic (end)

export const CYL_GALLERY_CHUNK_SIZE: number = 6;

export function cylGalleryRange(chunk: number, total: number): number[] {
  return cylGalleryChunkRange(chunk, CYL_GALLERY_CHUNK_SIZE, total);
}

export function cylGalleryNextChunkCount(shown: number, total: number): number {
  return cylGalleryChunksAfterReachEnd(shown, CYL_GALLERY_CHUNK_SIZE, total);
}
