---
name: Civic Trust
colors:
  surface: '#FFFFFF'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#3d4947'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#6d7a77'
  outline-variant: '#bcc9c6'
  surface-tint: '#006a61'
  primary: '#00685f'
  on-primary: '#ffffff'
  primary-container: '#008378'
  on-primary-container: '#f4fffc'
  inverse-primary: '#6bd8cb'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#006b2c'
  on-tertiary: '#ffffff'
  tertiary-container: '#00873a'
  on-tertiary-container: '#f7fff2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#89f5e7'
  primary-fixed-dim: '#6bd8cb'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
  app-bg: '#F8FAFC'
  text-muted: '#64748B'
  warning: '#D97706'
  danger: '#DC2626'
typography:
  headline-lg:
    fontFamily: manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-md:
    fontFamily: manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: inter
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 16px
  caption:
    fontFamily: inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 16px
  safe-area-top: 24px
  gap-sm: 8px
  gap-md: 12px
  gap-lg: 16px
  gap-xl: 24px
  touch-target: 48px
---

## Brand & Style

The design system is engineered for a **P2P Neighborhood Sharing & Services Platform**, where trust, safety, and accountability are the primary design drivers. The brand personality is **secure, institutional, and transparent**, moving away from casual "social" aesthetics toward a more dependable, service-oriented experience. 

The visual style follows a **Corporate / Modern** movement. It utilizes high-quality typography and a disciplined grid to evoke the feeling of a reliable utility rather than a marketplace. The interface relies on clear visual milestones and verification gates to ensure a sense of physical-world safety. Interaction is guided by "handshake" moments—deliberate steps that signify mutual agreement and legal clarity between neighbors.

## Colors

The palette is rooted in **Teal** and **Slate**, a combination chosen to project professionalism and calm. 

- **Primary (Teal):** Reserved for brand-critical actions, primary CTA buttons, and focus indicators. It represents movement and progress.
- **Secondary (Deep Slate):** Used for structural elements like headers and navigation, providing a grounded, authoritative frame.
- **Success (Green):** Integrated into the tertiary slot to highlight verified statuses and completed milestones.
- **Warning & Danger:** These are functional status colors used sparingly for pending verifications or disputed agreements.

The system uses a **light mode** default with `ColorBgDark` (#F8FAFC) as the canvas to provide a subtle "cool" contrast against white `ColorSurface` (#FFFFFF) cards.

## Typography

This design system uses a dual-font approach to balance character with functionality. **Manrope** is used for headings to provide a refined, modern, and trustworthy look. **Inter** is used for all body, label, and functional text due to its exceptional legibility and systematic feel.

Hierarchy is strictly enforced through weight. Bold weights are reserved for structural headings and primary button labels, while Medium weights are utilized for metadata and timestamps to ensure they remain legible but secondary.

## Layout & Spacing

The layout is built on a **fixed grid rhythm of 8dp**. All margins, paddings, and gaps must be multiples of this base unit.

- **Mobile Constraints:** Screens utilize a 16px side margin. Sections are separated by 24px (XL) gaps to maintain a clean, airy feel that prevents information overload.
- **Vertical Rhythm:** Small 8px gaps are used for grouped elements (like OTP inputs or timeline nodes), while 12px and 16px gaps are used for item lists and form fields respectively.
- **Interactive Areas:** All touch targets must maintain a minimum size of 48x48px to ensure accessibility and ease of use during real-world interactions.

## Elevation & Depth

Hierarchy is established through **tonal layering** and **subtle surface separation** rather than aggressive shadows. 

- **Surface Tiers:** Pure white surfaces (`#FFFFFF`) are placed atop a cool slate background (`#F8FAFC`). This provides a clear "Card" metaphor for content containers.
- **Overlays:** Modal bottom sheets are the primary method for ephemeral tasks (filters, code entry). They should use a soft backdrop dimming to focus attention.
- **Dividers:** Thin, low-contrast slate dividers are used to separate repeating items in lists, maintaining a clean look without the bulk of shadows.

## Shapes

The shape language is **Rounded**, striking a balance between the friendliness of a neighborhood app and the precision of a service platform. 

- **Standard Radius:** 8px (0.5rem) is the default for buttons, cards, and input fields.
- **Container Radius:** Larger components like bottom sheets and full-width cards use 16px (1rem) to soften the UI.
- **Sheet Indicators:** Bottom sheets feature a distinct "drag indicator capsule" (36x4px) with fully rounded (pill) ends to signal vertical mobility.

## Components

- **Buttons:** Primary buttons are 52px in height, full-width, with a 8px corner radius. They use `ColorPrimary` with white text. Muted or disabled buttons use `ColorTextMuted` to indicate logic gates are not yet met.
- **Input Fields:** Text inputs use a 8px radius with a subtle border. On focus, the border transitions to `ColorPrimary` (Teal). For error states, the border switches to `ColorDanger`.
- **Verification Cells:** OTP inputs use 48x48px or 44x52px containers, centered, with high-contrast text to ensure visibility during the "handshake" process.
- **Cards:** Cards are the primary container for services and items. They feature a white background, no border, and are separated by 12px or 16px gaps.
- **Status Pills:** Small, rounded badges used to indicate "Verified," "Pending," or "Completed." They use low-saturation background tints of their respective status colors with high-contrast text.
- **Avatars:** Large profile avatars are 100px; medium worker/provider avatars are 72px. All avatars are circular.