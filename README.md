# github-readme-streak-stats

Self-hosted GitHub contribution streak card, serving the streak widget on my
profile README.

Runs on my own infrastructure at `gh-streak.m1k.cloud` instead of the public
instance, so the card is rendered with my own GitHub token and is not subject to
shared rate limits.

## Deployment

Tagging `v*.*.*` builds and publishes
`ghcr.io/ironashram/github-readme-streak-stats`. The container is deployed by the
[commstack](https://github.com/ironashram/commstack) Ansible playbook and expects
a GitHub PAT in `TOKEN`.

## Credits

Original work by [Jonah Lawrence](https://github.com/DenverCoder1) and the
[github-readme-streak-stats](https://github.com/DenverCoder1/github-readme-streak-stats)
contributors. Licensed under MIT - see [LICENSE](LICENSE).

Usage and customization options are documented in the upstream README.
