# Design Concepts

UI mockups and design exploration for the head unit. These are visual
references — firmware UI code will live alongside other Ada sources in `src/`.

## Mockups

| File | Page | Notes |
|---|---|---|
| `head_unit_mockup_home.png` | Home / driving view | v1 — modern tactical aesthetic. Speed prominent, GPS coordinates, heading tape, vehicle diagnostics column. |
| `head_unit_mockup_alert.png` | Home, alert state (DTC raised) | v1 — left panel transforms to red theme, DTC code displayed prominently, speed retained, affected sensor highlighted in diagnostics column, "TAP TO ACKNOWLEDGE" action hint. Example: P0301 cylinder 1 misfire. |

## Design language (v1)

**Aesthetic:** Modern tactical / overland. Suited to the LX 450's expedition character.

**Color palette:**
- Background: `#0A0E13` (near-black charcoal) with `#13181F` topo contour overlay
- Primary text: `#EDE8DC` (warm off-white)
- Accent (nominal): `#C9A961` (military sand/amber) — active values, key data
- OK status: `#7B8B5C` (muted desert green)
- Alert (warning): `#D04545` (alert red) — used for DTC tile and fault indicators
- Alert (critical): `#FF6B5A` (bright red) — reserved for the DTC code itself, max attention
- Alert tint: `#15080A` (dark red panel background overlay)
- Dividers: `#1F2630`

**Typography:**
- Numerals: heavy geometric monospace (JetBrains Mono Bold feel — **reference only**; firmware uses a small bitmap font; see repo [**CREDITS.md**](../CREDITS.md))
- Labels: small sans-serif ALL CAPS with wide letterspacing

**Composition:**
- Bracket-corner panel marks (no heavy borders)
- Generous negative space
- Information dense but never cluttered
- High legibility from arm's length in motion
