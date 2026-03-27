import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  integrations: [
    starlight({
      title: 'BlaqForm',
      description: 'A composable, extensible Flutter forms package.',
      social: {
        github: 'https://github.com/your-org/blaq_form',
      },
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
