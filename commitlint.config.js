/**
 * FILE_NAME: commitlint.config.js
 * DESCRIPTION: Custom commitlint configuration with a regex engine for ticket-based commit messages.
 * VERSION: 1.1.0
 * AUTHORS: Vyom Platform Team
 */

// [T-01] Defining the custom regex for commit message validation.
// Matches pattern -> TICKET: type() message OR TICKET: type(scope) message
// The trailing colon after the type/scope block is completely removed

module.exports = {
  extends: ['@commitlint/config-conventional'],
  parserPreset: {
    parserOpts: {
      // Matches pattern -> TICKET: type() message OR TICKET: type(scope) message
      headerPattern: /^(INC|SCTASK|DCDT)[0-9]+:\s*(\w+)\((.*)\)\s+(.*)$/,
      headerCorrespondence: ['ticket', 'type', 'scope', 'subject']
    }
  },
  rules: {
    'header-match-team-pattern': [2, 'always'],
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'chore', 'docs', 'style', 'refactor', 'perf', 'test', 'ci', 'build']
    ],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never']
  },
  plugins: [
    {
      rules: {
        'header-match-team-pattern': (parsed) => {
          const { ticket, type, subject } = parsed;
          if (!ticket || !type || !subject) {
            return [
              false, 
              "CRITICAL: Commit message structure must match one of these formats:\n" +
              "  1. <TICKET>: <type>() <message>\n" +
              "  2. <TICKET>: <type>(<scope>) <message>\n\n" +
              "Examples:\n" +
              "  SCTASK98765: feat() added validation logic\n" +
              "  INC12345: fix(api) resolved timeout error\n\n" +
              "Allowed Ticket Prefixes: INC, SCTASK, DCDT"
            ];
          }
          return [true];
        }
      }
    }
  ]
};
