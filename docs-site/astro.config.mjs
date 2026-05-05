import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { blaqformDarkTheme } from './src/styles/blaqform-dark-theme.mjs';

// Deploy target switches site/base. Defaults to GitHub Pages.
//   DEPLOY_TARGET=github-pages  → https://creative-blaq-studios.github.io/BlaqForm
//   DEPLOY_TARGET=coolify       → set SITE_URL to your custom domain
const target = process.env.DEPLOY_TARGET ?? 'github-pages';
const site = target === 'coolify'
  ? (process.env.SITE_URL ?? 'https://docs.blaqform.dev')
  : 'https://creative-blaq-studios.github.io';
const base = target === 'github-pages' ? '/BlaqForm' : undefined;

export default defineConfig({
  site,
  base,
  integrations: [
    starlight({
      expressiveCode: {
        themes: [blaqformDarkTheme, 'github-light'],
        styleOverrides: {
          borderRadius: '0px',
          frames: {
            frameBoxShadowCssValue: 'none',
          },
        },
      },
      title: 'BlaqForm',
      description: 'A composable, extensible Flutter forms package.',
      logo: {
        src: './src/assets/blaqform-logo.svg',
        alt: 'BlaqForm',
      },
      social: {
        github: 'https://github.com/Creative-Blaq-Studios/BlaqForm',
      },
      head: [
        {
          tag: 'link',
          attrs: {
            rel: 'preconnect',
            href: 'https://fonts.googleapis.com',
          },
        },
        {
          tag: 'link',
          attrs: {
            rel: 'preconnect',
            href: 'https://fonts.gstatic.com',
            crossorigin: true,
          },
        },
        {
          tag: 'link',
          attrs: {
            rel: 'stylesheet',
            href: 'https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@300;400;500;600;700&display=swap',
          },
        },
      ],
      customCss: ['./src/styles/custom.css'],
      sidebar: [
        {
          label: 'Getting Started',
          items: [
            { label: 'Introduction', slug: 'getting-started' },
            { label: 'Installation', slug: 'installation' },
            { label: 'Quick Start', slug: 'quick-start' },
          ],
        },
        {
          label: 'Guides',
          items: [
            { label: 'BfFormBuilder', slug: 'guides/form-builder' },
            { label: 'Multi-Step Wizard', slug: 'guides/wizard' },
            { label: 'Validation', slug: 'guides/validation' },
            { label: 'Theming', slug: 'guides/theming' },
            { label: 'Field Widgets', slug: 'guides/fields' },
            { label: 'Indicators & UX', slug: 'guides/indicators' },
            { label: 'Persistence', slug: 'guides/persistence' },
            { label: 'Logging', slug: 'guides/logging' },
            { label: 'Testing', slug: 'guides/testing' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'All Validators', slug: 'reference/validators' },
            { label: 'All Field Types', slug: 'reference/fields' },
            { label: 'Field Key Constants', slug: 'reference/field-keys' },
          ],
        },
      ],
    }),
  ],
});
