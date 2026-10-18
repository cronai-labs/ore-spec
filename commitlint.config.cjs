// Conventional Commits. The PR title becomes the squash subject and the
// changelog entry; CI lints both the title and the branch commits.
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "scope-enum": [1, "always", ["spec", "examples", "readme", "ci", "release", "deps"]],
  },
};
