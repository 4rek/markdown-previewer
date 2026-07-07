# Security Policy

## Reporting a vulnerability

Please report security issues privately by emailing **a.p.juszczyk@gmail.com**
rather than opening a public issue. Include steps to reproduce and, if possible,
a sample file. You'll get a response as soon as reasonably possible.

## Security model

- The **preview extension** — the component that reads and renders untrusted file
  content — runs fully inside the macOS **App Sandbox**.
- Previews perform **no network requests** for local content; rendering is done
  from the file's bytes only.
- The extension hands rendered **HTML to Quick Look**, which displays it in its
  own sandboxed preview surface.

The small container app runs outside the sandbox so it can maintain Quick Look
(refresh the cache, prune duplicate registrations). It performs no network
activity and handles no untrusted input.
