# AGENTS.md

Org-roam notes published as a Hugo digital garden (https://garden.desmondrivet.com).

## Source of truth

- `org-roam/` — hand-written org notes. **Never edit `content/`**: its markdown is generated and gitignored (`content/**/*.md`).
- `pages/` — org pages exported as body-only HTML (not Hugo markdown).
- `content/`, `assets/data/backlinks.yaml`, `public/` — generated artifacts, not committed.

## Build

`make all` runs the full pipeline: `orgfiles` → `backlinks` → `build`.

- `make orgfiles` — batch Emacs (`export.el`) org-publish: `org-roam/*.org` → `content/*.md`, and syncs `org-roam/.org-roam.db` (must run before `make backlinks`).
- `make backlinks` — `backlinks.go` reads the sqlite DB → `assets/data/backlinks.yaml`, then seds `_index`→`index`.
- `make build` / `make serve` — Hugo. Binaries are non-default paths: `~/bin/hugo`, `~/go/bin/go`.
- `make clean` — wipes generated `content/*.md|html`, `content/{daily,reference}`, `.org-timestamps/`.
- `lastmodified.sh` — refreshes `#+hugo_lastmod` stamps in org files from `git log` (not part of `make`).

Local check: `make all` && `make serve` (server runs with `-D`, drafts included).

## Deploy

- `deploy.sh` — `make cleanout && make all && rsync -a public /var/www/garden.desmondrivet.com/`.
- Pushing to `main` triggers `.github/workflows/deploy.yml`: SSH to prod, `git reset --hard origin/main`, runs `deploy.sh`. No local deploy step needed.

## Conventions

- Note filenames: `YYYYMMDDHHMMSS-slug.org`.
- Each note has a `:PROPERTIES:` drawer with `:ID:` (org-roam UUID); backlinks use `[[id:<UUID>][Title]]` org IDs (e.g. recipes link to the Recipes index note).
- `hugo.yaml`: `uglyURLs: true` (URLs end `.html`), goldmark `unsafe: true`.