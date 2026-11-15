// The inline fold of a tag list (CollectionViewClassifyMenu CYLMenuFoldControlPositionInline): the tags of the first
// rows, then the chevron after the last visible tag. Used by cyl-search (suggestionStyle "tags") and the example's
// Discover page; pure, tested with Node.

/**
 * How many tags fit in `rows` rows of width `available` when the fold chevron must follow the last visible tag
 * (CollectionViewClassifyMenu CYLMenuFoldControlPositionInline): `{ visibleCount, needsFold }`. Without a fold the
 * chevron is not drawn; folded, the tags of the first rows are kept and the chevron takes the place after them.
 */
function cylFoldTags(widths, available, spacing, chevronWidth, rows) {
  const place = (count, extra) => {
    let row = 1;
    let x = 0;
    const all = widths.slice(0, count).concat(extra ? [extra] : []);
    for (const width of all) {
      const needed = x === 0 ? width : x + spacing + width;
      if (needed > available && x > 0) {
        row += 1;
        x = width;
      } else {
        x = needed;
      }
    }
    return row;
  };
  if (widths.length === 0) return { visibleCount: 0, needsFold: false };
  if (place(widths.length, 0) <= rows) return { visibleCount: widths.length, needsFold: false };
  let count = widths.length;
  while (count > 0 && place(count, chevronWidth) > rows) count -= 1;
  return { visibleCount: count, needsFold: true };
}

module.exports = { cylFoldTags };
