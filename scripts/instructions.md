# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep release and validation scripts non-interactive unless a publishing
  command is explicitly selected. Never publish as part of validation.
- `latest-cyl-commit.sh` prints the newest CYLTabBarController commit on any
  branch; run it before every build that depends on CYLTabBarController.
