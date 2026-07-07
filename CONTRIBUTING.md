# Contributing

Thanks for your interest in improving Markdown Previewer!

## Development setup

Requirements: **Xcode** and **[XcodeGen](https://github.com/yonaskolb/XcodeGen)**
(`brew install xcodegen`).

The `.xcodeproj` is generated from [`project.yml`](project.yml) and is not
committed:

```sh
xcodegen generate
open MarkdownPreviewer.xcodeproj
```

Build and install locally in one step:

```sh
./scripts/install.sh
```

Run the renderer tests:

```sh
xcodebuild -project MarkdownPreviewer.xcodeproj -scheme RendererTests \
  -destination 'platform=macOS' test
```

## Guidelines

- Keep it focused: this project previews Markdown well and does little else.
- If you change rendering, add or update a case in `Tests/RendererTests.swift`.
- Match the existing code style and comment density.
- If you add or remove a file, remember the project is generated — no `.xcodeproj`
  changes to commit.

## Submitting changes

1. Fork and create a branch.
2. Make your change with a clear commit message.
3. Ensure `CI` passes (build + tests).
4. Open a pull request describing what and why.

## Reporting bugs

Open an issue with your macOS version, a sample `.md` file (or snippet) that
reproduces the problem, and what you expected versus what you saw.
