import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { blaqformDarkTheme } from './src/styles/blaqform-dark-theme.mjs';

export default defineConfig({
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
        github: 'https://github.com/your-org/blaq_form',
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
            { label: 'Introduction', link: '/getting-started/' },
            { label: 'Installation', link: '/installation/' },
            { label: 'Quick Start', link: '/quick-start/' },
          ],
        },
        {
          label: 'Guides',
          items: [
            { label: 'BfFormBuilder', link: '/guides/form-builder/' },
            { label: 'Multi-Step Wizard', link: '/guides/wizard/' },
            { label: 'Validation', link: '/guides/validation/' },
            { label: 'Theming', link: '/guides/theming/' },
            { label: 'Field Widgets', link: '/guides/fields/' },
            { label: 'Indicators & UX', link: '/guides/indicators/' },
            { label: 'Persistence', link: '/guides/persistence/' },
            { label: 'Logging', link: '/guides/logging/' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'All Validators', link: '/reference/validators/' },
            { label: 'All Field Types', link: '/reference/fields/' },
            { label: 'Field Key Constants', link: '/reference/field-keys/' },
          ],
        },
      ],
    }),
  ],
});
