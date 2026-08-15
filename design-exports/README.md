# Movo — SVG design exports

Vector exports of the Movo character rig, mood faces, accent colors, and app
logo, generated directly from the geometry and color math in the live
SwiftUI app (`Movo/Views/Character/CharacterShapeView.swift`,
`Movo/Models/Stage.swift`, `Movo/Models/Mood.swift`,
`Movo/Models/AppSettings.swift`, `Movo/Models/CharacterProfile.swift`,
`Movo/Views/Shared/Components.swift`).

**This folder is standalone.** It is not part of the Xcode target, isn't
referenced by the app, and nothing in `Movo/` was changed to produce it.

## What's here

```
stages/   5 files — Egg, Hatchling, Rookie, Athlete, Champion
          (lime accent, happy mood, each stage's full unlocked gear set
          shown at once — same "showcase" mode the design PDF's stage-card
          art uses, i.e. Champion wears headband + tank top + gold band +
          crown + cape simultaneously, not the single-item-per-slot rule
          the live wardrobe enforces)

moods/    5 files — Happy, Fired up, Wrecked, Annoyed, Sulking
          (all on the Rookie rig / lime accent, so only the face — and for
          Sulking, the desaturated body — changes between files)

colors/   5 files — Lime, Amber, Blue, Pink, Cream
          (all on the Rookie rig / happy mood, one per AccentOption; shows
          exactly how a single accent hex re-skins the whole rig via the
          app's lighter/darker HSB derivation, not flat recolors)

logo/     movo-icon.svg          — in-app icon mark (MovoEggMark), lime
          movo-icon-amber.svg    — same mark, amber variant
          app-icon-1024.svg      — matches the shipped AppIcon-1024.png
                                    (App Store icon; slightly different
                                    proportions/gradient than movo-icon.svg
                                    — see note below)
          movo-wordmark.svg      — icon + "movo" text lockup, white text
                                    (designed for dark backgrounds)

generate_svgs.py   the generator — re-run any time the app's rig/colors
                    change, to keep these exports in sync by hand-editing
                    the transcribed constants at the top of the file.
```

## Important notes for whoever uses these

- **Two different "app icon" files exist on purpose.** `logo/movo-icon.svg`
  matches the `MovoEggMark` SwiftUI component used *inside* the app
  (header wordmark, etc). `logo/app-icon-1024.svg` matches the actual
  shipped App Store icon asset (`Movo/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`),
  which was generated separately and has a slightly different corner
  radius / gradient / crack-mark placement. Use `app-icon-1024.svg` for
  anything that needs to match the real app icon pixel-for-pixel; use
  `movo-icon.svg` for in-product UI mockups.
- **Colors are derived, not flat.** Every accent is one base hex
  (`colors/`), and the torso/head/tank-top/cape/crack-mark shades you see
  are all computed from it via HSB shifts (see `darker()`/`lighter()`/
  `desaturated()` in `generate_svgs.py`, transcribed from
  `CharacterProfile.swift`). If your teammate needs a 6th accent color,
  the cleanest path is adding one hex to `ACCENTS` in the script and
  re-running it — not hand-picking shades.
- **`movo-wordmark.svg` has white text** (`fill="#FFFFFF"`) — it's meant
  to sit on the app's dark canvas background (`#141712`), so it will look
  blank on a white artboard. The "movo" text is set in a generic
  sans-serif fallback stack, not the real Space Grotesk font (not bundled
  in the app either) — swap the `font-family` if the real font file is
  available.
- **Fixed (non-accent) colors** used across every stage/mood file:
  headband `#FFB13D`, gold band/crown `#E8B84B`, eyebrows `#E2472B`,
  tears/sweat `#57B4FF`, shoes `#F3F4F0`.
- **Stage canvases are padded uniformly** (extra headroom on top) so the
  5 stage files line up as a consistent filmstrip even though only
  Champion's crown actually needs the extra space — don't be surprised by
  the empty margin on the smaller stages.
- Every shape is grouped with an `id` (`head`, `torso`, `arms`, `legs`,
  `headband`, `tank_top`, `gold_band`, `crown`, `cape`, `face`, `egg`,
  `cracks`, `bg`) so these are editable/toggleable in Figma, Illustrator,
  or any SVG-aware tool, not flat shape dumps.

## Regenerating

```bash
cd design-exports
python3 generate_svgs.py
```

Requires only the Python 3 standard library (`colorsys`, `math`, `os`).
Verified visually during export using `rsvg-convert` (librsvg) — not a
project dependency, just how these were sanity-checked before handoff.
