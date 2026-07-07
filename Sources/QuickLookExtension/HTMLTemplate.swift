import Foundation

/// Wraps rendered Markdown body HTML in a full, self-contained page with styling
/// that adapts to light/dark appearance. All CSS is inline so the preview needs
/// no network access.
enum HTMLTemplate {
    static func page(body: String, title: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(escapedTitle(title))</title>
        <style>
        \(css)
        </style>
        </head>
        <body>
        <article class="markdown-body">
        \(body)
        </article>
        </body>
        </html>
        """
    }

    private static func escapedTitle(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private static let css = """
    :root {
        color-scheme: light dark;
        --fg: #1f2328;
        --muted: #59636e;
        --bg: #ffffff;
        --border: #d1d9e0;
        --code-bg: #f6f8fa;
        --accent: #0969da;
    }
    @media (prefers-color-scheme: dark) {
        :root {
            --fg: #e6edf3;
            --muted: #9198a1;
            --bg: #0d1117;
            --border: #3d444d;
            --code-bg: #161b22;
            --accent: #4493f8;
        }
    }
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; background: var(--bg); }
    body {
        color: var(--fg);
        font: 15px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
        -webkit-text-size-adjust: 100%;
    }
    .markdown-body {
        max-width: 900px;
        margin: 0 auto;
        padding: 28px 32px 60px;
        word-wrap: break-word;
    }
    .markdown-body > *:first-child { margin-top: 0; }
    h1, h2, h3, h4, h5, h6 {
        margin: 24px 0 16px;
        font-weight: 600;
        line-height: 1.25;
    }
    h1 { font-size: 1.9em; padding-bottom: .3em; border-bottom: 1px solid var(--border); }
    h2 { font-size: 1.5em; padding-bottom: .3em; border-bottom: 1px solid var(--border); }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    h5 { font-size: .9em; }
    h6 { font-size: .85em; color: var(--muted); }
    p { margin: 0 0 16px; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    img { max-width: 100%; height: auto; }
    hr { height: 1px; border: 0; background: var(--border); margin: 24px 0; }
    blockquote {
        margin: 0 0 16px;
        padding: 0 1em;
        color: var(--muted);
        border-left: .25em solid var(--border);
    }
    blockquote > *:last-child { margin-bottom: 0; }
    ul, ol { margin: 0 0 16px; padding-left: 2em; }
    li { margin: .25em 0; }
    li > p { margin: 0 0 8px; }
    .task-list-item { list-style: none; }
    .task-list-item input { margin: 0 .5em 0 -1.4em; vertical-align: middle; }
    code {
        font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
        font-size: 85%;
        background: var(--code-bg);
        padding: .2em .4em;
        border-radius: 6px;
    }
    pre {
        margin: 0 0 16px;
        padding: 16px;
        overflow: auto;
        background: var(--code-bg);
        border-radius: 8px;
        line-height: 1.45;
    }
    pre code {
        display: block;
        padding: 0;
        background: transparent;
        font-size: 85%;
        overflow: visible;
    }
    table {
        border-collapse: collapse;
        margin: 0 0 16px;
        display: block;
        width: max-content;
        max-width: 100%;
        overflow: auto;
    }
    th, td {
        padding: 6px 13px;
        border: 1px solid var(--border);
    }
    thead th { background: var(--code-bg); }
    tr:nth-child(2n) td { background: color-mix(in srgb, var(--code-bg) 45%, transparent); }
    """
}
