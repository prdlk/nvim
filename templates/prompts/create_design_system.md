# Create a CSS design system

Produce a CSS custom-property design system for the project or brand described in the notes.

## Steps

1. Inspect the project first: existing stylesheets, `tailwind.config.*`, theme files, and the framework in use. Reuse existing brand colors, fonts and naming; extend rather than duplicate. Only invent values when none exist, and say so.
2. Choose the output file: the path named in the notes, otherwise a sensible name such as `design-system.css` next to the existing styles. If the project uses Tailwind, map tokens into its theme instead of conflicting with it.
3. Check color pairs for contrast (WCAG AA: 4.5:1 for body text) in both modes.
4. Write the file; if there is no project, output it in a code block.

## Output

CSS with semantic names (`--bg-primary`, not `--dark-bg`), containing:

- Color tokens: brand, semantic status (success, warning, error, info), a neutral scale, and semantic surfaces, text and borders. Define light and dark values, using `prefers-color-scheme` plus a `[data-theme]` override if the project toggles themes.
- Type scale: font families, fluid sizes with `clamp()`, weights, line heights.
- Spacing scale on a 4px base unit.
- Radius, shadow and border tokens.
- Motion tokens: durations (under about 350ms) and easings, with a `prefers-reduced-motion` reset.
- Base components built only from tokens: button (variants and states), card, input, and others the project needs.
- A short usage note: use semantic tokens in components, never raw values.

## Notes

{{_cursor_}}
