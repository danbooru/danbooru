const js = require("@eslint/js");
const globals = require("globals");
const ignoreErb = require("eslint-plugin-ignore-erb");
const { browser, es2017 } = globals;
const erbProcessor = ignoreErb.processors[".erb"];

// Trim whitespace from global variable names to avoid errors caused by globals that have leading or trailing spaces (e.g. `AudioWorkletGlobalScope `)
function normalizeGlobals(...globalSets) {
  return Object.fromEntries(
    globalSets.flatMap((globalSet) =>
      Object.entries(globalSet).map(([name, value]) => [name.trim(), value]),
    ),
  );
}

function preprocessErb(text) {
  return [
    text
      .replace(/<%=([\s\S]*?)%>/g, "null")
      .replace(/<%([\s\S]*?)%>/g, "/* Ignored ERB */"),
  ];
}

module.exports = [
  js.configs.recommended,
  {
    files: ["**/*.js", "**/*.js.erb"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...normalizeGlobals(browser, es2017),
        $: "readonly",
        Alpine: "readonly",
        Danbooru: "readonly",
        jQuery: "readonly",
        require: "readonly",
      },
    },
    rules: {
      "array-callback-return": "error",
      "block-scoped-var": "error",
      "consistent-return": "error",
      "default-case": "error",
      "dot-notation": "error",
      "eqeqeq": "error",
      "init-declarations": "error",
      "no-caller": "error",
      "no-empty-function": "error",
      "no-eval": "error",
      "no-extend-native": "error",
      "no-implicit-coercion": "error",
      "no-lone-blocks": "error",
      "no-lonely-if": "error",
      "no-mixed-operators": "error",
      "no-new-wrappers": "error",
      "no-return-assign": "error",
      "no-self-compare": "error",
      "no-sequences": "error",
      "no-shadow": "error",
      "no-shadow-restricted-names": "error",
      "no-unused-expressions": "error",
      "no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          args: "none",
          caughtErrors: "none",
        },
      ],
      "no-use-before-define": "error",
      "no-useless-call": "error",
      "no-useless-concat": "error",
      "no-useless-return": "error",
      "array-bracket-spacing": "warn",
      "block-spacing": "warn",
      "brace-style": ["warn", "1tbs", { allowSingleLine: true }],
      "comma-spacing": "warn",
      "curly": "warn",
      "dot-location": ["warn", "property"],
      "eol-last": "warn",
      "func-call-spacing": "warn",
      "indent": ["warn", 2],
      "linebreak-style": ["warn", "unix"],
      "key-spacing": "warn",
      "keyword-spacing": "warn",
      "no-multi-spaces": "warn",
      "no-multiple-empty-lines": "warn",
      "no-tabs": "warn",
      "no-trailing-spaces": "warn",
      "no-whitespace-before-property": "warn",
      "space-before-blocks": "warn",
      "space-in-parens": "warn",
      "space-infix-ops": "warn",
      "space-unary-ops": "warn",
      "spaced-comment": "warn",
    },
  },
  {
    files: ["**/*.js.erb"],
    rules: {
      indent: "off",
    },
    processor: {
      meta: {
        name: "eslint-plugin-ignore-erb",
        version: "0.1.1",
      },
      preprocess: preprocessErb,
      postprocess: erbProcessor.postprocess,
    },
  },
];
