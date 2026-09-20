# QR code rendering

How `Prawn::QRCode::Renderer` turns a QR code into PDF drawing operations, what was
optimized, and where the approach stops.

## How it works

A QR code is a square matrix of dark and light modules. The renderer walks the matrix
row by row, combines horizontally adjacent dark modules into a single rectangle, and
paints each row with one `fill` operation. Light modules are never drawn — the page
background shows through.

Coordinates are relative to a `bounding_box` placed at `:pos`, sized `:extent` square.
A margin of `:margin` modules (default 4, the quiet zone required by the QR spec)
surrounds the matrix.

## Optimizations

The renderer previously called `move_to` once per module. Since rectangles are painted
via `fill { rectangle(...) }`, which begins its own subpath, each of those calls emitted
a PDF `m` operator that created a degenerate subpath painting nothing. For a version 40
code that is 31329 dead operators against 8063 real rectangles — about 80% of the emitted
path operators.

Current approach:

- No `move_to`; only rectangles that are actually painted reach the content stream.
- Module rows are read directly rather than through `qr_code.checked?(row, col)`, which
  costs a method call and bounds checks per module.
- One `fill` per row instead of one per horizontal run.
- The memoized `dot` accessor is hoisted into a local before the loop.

Measured effect:

| QR version | render time | content stream |
|------------|-------------|----------------|
| 3  | 4.21 → 1.27 ms | 17.5 → 5.3 KB |
| 10 | 15.77 → 4.61 ms | 66.8 → 19.7 KB |
| 20 | 45.02 → 12.80 ms | 196 → 57 KB |
| 40 | 150.04 → 42.39 ms | 666 → 191 KB |

Reproduce with `rake benchmark` (override the sample count with `REPETITIONS`).

## Limits and boundaries

**QR version ceiling.** QR codes stop at version 40, a 177×177 matrix. `min_qrcode`
raises `RQRCodeCore::QRCodeRunTimeError` for content that does not fit at the requested
error correction level.

**Work scales with the matrix, not the payload.** Every module is visited, so the scan is
O(n²) in the matrix edge length; the number of emitted rectangles follows the number of
horizontal dark runs (8063 at version 40).

**Path size is bounded per row, deliberately.** Painting the whole code in one `fill` is
equally fast and marginally smaller, but yields a single path of ~8000 subpaths. Older PDF
implementations documented limits in that range, so rows are flushed individually. At
version 40 a row holds at most 83 rectangles.

**Runs are merged horizontally only.** Merging identical runs across rows into taller
rectangles shrinks version 40 output by a further ~10% (161 KB vs 191 KB) but renders ~4%
slower and needs materially more bookkeeping. It was measured and rejected.

**Coordinate precision.** Prawn writes coordinates with five decimal places, so dot sizes
below roughly 1e-5 pt lose precision. Adjacent rectangles within a row belong to one path
and tile seamlessly; row boundaries are separate fill operations.

**Graphics state is not restored.** Rendering leaves the document's fill color set to the
QR code's colors rather than restoring the previous value, and advances the cursor by
`:extent`. Set colors explicitly after rendering if the surrounding document depends on
them.

**`:stroke_color` does not currently work.** It is applied with `fill_color`, so it tints
the fill state instead of the stroke around the code; the bounding box is always stroked
in the document's current stroke color.

## Verifying changes to the renderer

`test_rendered_output_covers_exactly_the_dark_modules` maps the rectangles in the content
stream back to module coordinates and compares them against the QR matrix, so a change
that shifts, drops, or duplicates modules fails the suite regardless of how the rectangles
are batched.
