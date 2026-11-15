// Fills the formats of the core's strings, which keep the iOS and Android forms: %@, %d, %ld, %lu, %s and the
// positional %1$d / %1$lu ("Search %1$d of %2$d").
function cylFormatString(format, args) {
  let next = 0;
  return String(format).replace(/%(?:(\d+)\$)?(@|lu|ld|d|s|%)/g, (whole, position, kind) => {
    if (kind === '%') return '%';
    const index = position ? Number(position) - 1 : next++;
    return index < args.length ? String(args[index]) : whole;
  });
}

module.exports = { cylFormatString };
