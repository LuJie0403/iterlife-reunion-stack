# @iterlife/theme-dark-universe

Shared dark-universe theme foundation package for IterLife frontends.

## Installation

```bash
pnpm add @iterlife/theme-dark-universe
```

## Usage

Import the theme entry from the application bootstrap:

```ts
import '@iterlife/theme-dark-universe'
```

Enable the theme on the document root:

```ts
document.documentElement.setAttribute('data-theme', 'dark-universe')
```

Nuxt applications can register the shared CSS in `nuxt.config.ts`:

```ts
export default defineNuxtConfig({
  css: ['@iterlife/theme-dark-universe'],
})
```

For pre-release local integration across sibling repositories, consumers may
temporarily use a `file:` dependency pointing to this package directory. After
the first npm release, switch consumers back to a normal registry version.

## Package contents

- `dist/index.css`
- `dist/tokens.css`
- `dist/background.css`

## License

Apache-2.0
