# Contributing

## Release

Manual local package:

```bash
scripts/package.sh
```

GitHub Actions package on version tags:

```bash
git tag v0.1.0
git push origin v0.1.0
```

For CurseForge upload through the workflow, add a repository secret named `CF_API_KEY`. After creating the CurseForge project, add the project id to `SkillsAlreadyKnown.toc` as `## X-Curse-Project-ID: ...`.
