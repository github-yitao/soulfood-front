---
name: ui-decomposer
description: 将 UI 截图拆解为语义化 HTML 和 Tailwind CSS 代码。Use when the user uploads or references a UI screenshot and asks to 拆解图, convert UI to HTML, analyze a screenshot, or produce responsive HTML/Tailwind from an interface image.
---

# UI Decomposer

## Workflow

When a user provides a UI screenshot, execute all phases in order. Do not skip phases, even when the request only asks for code.

## Phase 1: Visual Audit

1. Identify the visible color palette as HEX or RGBA values. If exact sampling is unavailable, provide the closest estimated values and label them as estimates.
2. Identify the visible font sizes. Use pixel values and group repeated sizes when possible.
3. Identify repeated components such as buttons, cards, nav items, list rows, badges, input fields, and icon buttons.
4. Determine the main container layout model. State whether each major region is best represented with Flexbox or CSS Grid, and explain the alignment briefly.

## Phase 2: DOM Tree Abstraction

1. Output a style-free HTML skeleton before writing styled code.
2. Use semantic HTML5 elements where appropriate, including `header`, `main`, `section`, `nav`, `article`, `aside`, `footer`, `button`, `form`, and `ul`/`li`.
3. Keep the skeleton focused on structure and content hierarchy. Do not include Tailwind classes, inline `style` attributes, or `style` tags in this phase.

## Phase 3: Style Implementation

1. Implement responsive styling with Tailwind CSS utility classes.
2. Keep spacing on a 4px step scale. Prefer Tailwind spacing tokens that map to 4px increments, such as `p-1`, `p-2`, `p-3`, `p-4`, `gap-2`, `gap-4`, `mt-6`, and `px-8`.
3. Use SVG for icons first. Prefer inline semantic SVG elements or existing SVG icon assets when available.
4. Do not use inline `style` attributes or `style` tags. Express styling through Tailwind classes.
5. Preserve visual hierarchy, alignment, spacing, component repetition, and responsive behavior from the screenshot.

## Output Format

Return the result in this order:

1. Visual audit: colors, font sizes, repeated components, and layout model.
2. Style-free semantic HTML skeleton.
3. Final Tailwind CSS implementation.
4. Short implementation notes only when useful, such as assumptions about estimated colors or missing assets.
