/**
 * BlaqForm Dark — Creative Blaq "Dev" syntax theme
 * Based on One Dark palette mapped to brand identity.
 *
 * Brand refs:
 *   bg        #080808   keywords  #C678DD
 *   fg        #F5F5F5   functions #61AFEF
 *   strings   #98C379   numbers   #D19A66
 *   types     #E5C07B   comments  #5C6370
 *   operators #ABB2BF   accent    #FF6B00
 */

/** @type {import('@shikijs/types').ThemeRegistration} */
export const blaqformDarkTheme = {
  name: 'blaqform-dark',
  type: 'dark',

  colors: {
    /* Editor chrome */
    'editor.background':              '#080808',
    'editor.foreground':              '#F5F5F5',
    'editor.lineHighlightBackground': '#0D0D0D',
    'editor.selectionBackground':     '#1f1005',
    'editorCursor.foreground':        '#FF6B00',

    /* Gutter / line numbers */
    'editorLineNumber.foreground':        '#333333',
    'editorLineNumber.activeForeground':  '#555555',

    /* Bracket pairs */
    'editorBracketMatch.background': '#1A1A1A',
    'editorBracketMatch.border':     '#FF6B00',
  },

  tokenColors: [
    /* ── Base ────────────────────────────────── */
    {
      scope: [''],
      settings: { foreground: '#F5F5F5' },
    },

    /* ── Comments ────────────────────────────── */
    {
      scope: ['comment', 'punctuation.definition.comment'],
      settings: { foreground: '#5C6370', fontStyle: 'italic' },
    },

    /* ── Keywords ────────────────────────────── */
    {
      scope: [
        'keyword',
        'keyword.control',
        'keyword.operator.new',
        'keyword.other.import',
        'storage.type',
        'storage.modifier',
        'variable.language.this',
        'variable.language.super',
      ],
      settings: { foreground: '#C678DD' },
    },

    /* ── Types / Classes ─────────────────────── */
    {
      scope: [
        'entity.name.type',
        'entity.name.class',
        'support.class',
        'support.type',
        'meta.class entity.name.class',
        'entity.other.inherited-class',
      ],
      settings: { foreground: '#E5C07B' },
    },

    /* ── Functions ───────────────────────────── */
    {
      scope: [
        'entity.name.function',
        'support.function',
        'meta.function-call',
        'meta.method-call entity.name.function',
        'variable.function',
      ],
      settings: { foreground: '#61AFEF' },
    },

    /* ── Strings ─────────────────────────────── */
    {
      scope: [
        'string',
        'string.quoted',
        'string.template',
        'punctuation.definition.string',
      ],
      settings: { foreground: '#98C379' },
    },

    /* ── Numbers & constants ─────────────────── */
    {
      scope: [
        'constant.numeric',
        'constant.language',
        'constant.character',
      ],
      settings: { foreground: '#D19A66' },
    },

    /* ── Operators & punctuation ─────────────── */
    {
      scope: [
        'keyword.operator',
        'punctuation.accessor',
        'punctuation.separator',
        'punctuation.terminator',
        'punctuation.definition.parameters',
        'meta.brace',
      ],
      settings: { foreground: '#ABB2BF' },
    },

    /* ── Variables & parameters ──────────────── */
    {
      scope: [
        'variable',
        'variable.other',
        'variable.parameter',
        'meta.definition.variable',
      ],
      settings: { foreground: '#F5F5F5' },
    },

    /* ── Tags (HTML/XML/JSX) ─────────────────── */
    {
      scope: ['entity.name.tag', 'meta.tag'],
      settings: { foreground: '#E06070' },
    },

    /* ── Attributes ──────────────────────────── */
    {
      scope: ['entity.other.attribute-name'],
      settings: { foreground: '#D19A66' },
    },

    /* ── Dart / Flutter specifics ────────────── */
    {
      scope: [
        'keyword.declaration.class.dart',
        'keyword.declaration.function.dart',
        'keyword.control.dart',
      ],
      settings: { foreground: '#C678DD' },
    },
    {
      scope: ['support.class.dart', 'entity.name.type.dart'],
      settings: { foreground: '#E5C07B' },
    },
    {
      scope: ['variable.other.dart', 'variable.parameter.dart'],
      settings: { foreground: '#F5F5F5' },
    },
    {
      scope: ['entity.name.function.dart', 'support.function.dart'],
      settings: { foreground: '#61AFEF' },
    },

    /* ── Imports / decorators ────────────────── */
    {
      scope: ['meta.import', 'keyword.other.import'],
      settings: { foreground: '#C678DD' },
    },
    {
      scope: ['entity.name.function.decorator', 'meta.decorator'],
      settings: { foreground: '#FF6B00' },
    },

    /* ── Bash / shell ────────────────────────── */
    {
      scope: ['support.function.builtin.shell', 'entity.name.command.shell'],
      settings: { foreground: '#61AFEF' },
    },
    {
      scope: ['variable.other.normal.shell'],
      settings: { foreground: '#F5F5F5' },
    },

    /* ── YAML / TOML ─────────────────────────── */
    {
      scope: ['entity.name.tag.yaml', 'support.type.property-name.toml'],
      settings: { foreground: '#E5C07B' },
    },
  ],
};
