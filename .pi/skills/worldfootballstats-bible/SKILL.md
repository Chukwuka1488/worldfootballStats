---
name: worldfootballstats-bible
description: "worldfootballStats repo engineering rules (the 'bible'). Use when writing or reviewing R code, scrapers, tests, roxygen docs or commit messages in this repo. Encodes dev-docs/clean_code.md plus the scraper, data-source, testing and copy rules for this fork of worldfootballR. Load the referenced docs for full text."
---

# worldfootballStats Bible - Repo Rules

The authoritative rules for this repository. This is a maintained fork of the
archived `JaseZiv/worldfootballR` R package. It extracts football data from
Understat, Transfermarkt and (blocked, see below) FBref. Read the referenced
docs for full text; the summary below is the working checklist.

## Where the rules live

- `dev-docs/clean_code.md` - engineering rules (SOLID, small files, comments, tests)
- `.pre-commit-config.yaml` - the checks every commit must pass
- `.pi/skills/asd-ste100/` - Simplified Technical English, for error messages and docs
- `NEWS.md` - record every user-visible change here

## Engineering rules (dev-docs/clean_code.md)

- Files max ~250 lines; split otherwise.
- SOLID, KISS, DRY, YAGNI. One responsibility per function.
- One expectation per test. Tests readable, fast, independent, repeatable.
- No dead code and no commented-out code. Boy scout rule.
- **Comments: do not use em dashes; use proper punctuation.**
- Comments explain intent, not mechanics. Add a comment when you fix a bug
  caused by a site change (say what the site did and when).
- No flag arguments; split functions. Descriptive, searchable names.
- Security is a top priority.

## R package conventions

- Every exported function has roxygen2 docs. Run `devtools::document()` and
  commit the regenerated `man/` and `NAMESPACE`. Never edit those by hand.
- `README.md` is generated from `README.Rmd`. Edit the `.Rmd`, then render.
- Internal helpers start with a dot and carry `@noRd` (see `R/internals.R`).
- Declare every package you call in `DESCRIPTION` Imports. Use `pkg::fn()`
  or `@importFrom`, never `library()` inside the package.
- Use the pipe style already in the file you edit. Match the surrounding
  code: naming, comment density and idiom.
- Do not leave `browser()`, `debug()` or `print()` debugging in committed code.
- Do not change a function's output columns or column names without a
  `NEWS.md` entry. Users depend on them.

## Scraper rules

- Prefer the site's own JSON endpoint over parsing HTML. Understat serves
  data from `getLeagueData`, `getTeamData`, `getMatchData` and
  `getPlayerData`; use those through `.understat_api()`.
- A parser failure must not crash a multi-item run. Wrap per-item work in
  `purrr::possibly()` and return an empty data frame.
- Be polite. Sleep between requests (`Sys.sleep()` with a random 1 to 3 s
  jitter in loops). Never add parallel or burst requests.
- Do not bypass bot protection. FBref sits behind a Cloudflare challenge
  (HTTP 403). Do not add challenge solvers, fingerprint spoofing or proxy
  rotation. If a site blocks us, say so in the docs and use another source.
- Respect each site's terms of use. Keep the "please acknowledge the data
  source" wording in user-facing messages.
- Never log or commit cookies, tokens or API keys. Keep secrets in env vars.
- Do not hard-code the current season. Derive it from the date
  (`.tm_comp_seasons()` shows how).

## Data-source status (re-check before relying on it)

- **Understat:** works through the JSON endpoints.
- **Transfermarkt:** works. The competition lookup table upstream is no
  longer updated; `.tm_comp_seasons()` extends it to the current season.
- **FBref:** blocked by Cloudflare. `fb_*` functions fail with HTTP 403.
  Do not claim they work.

## Testing

- Tests live in `tests/testthat/`. Name the file after the function.
- Tests that hit a live site must call `skip_on_cran()` and
  `skip_if_offline()`. Keep one small, fast request per test.
- For parsers, test against a saved JSON or HTML fixture so the test does
  not depend on the site being up.
- Assert on column names and types, not on exact live values. Live values
  change every match day.
- Before you open a PR, run the changed functions against the live site and
  note the result in the PR description.

## Writing rules (code comments, docs, errors, commit messages)

- Plain, informative statements. Apply the `asd-ste100` skill to error
  messages and roxygen text: short sentences, one meaning per word.
- **Em-dash overuse** is an AI cadence tell. Use proper punctuation.
- Avoid marketing buzzwords (streamline, empower, seamless, enterprise-grade).
- Say a thing once. Do not repeat it in the title, the details and the notes.
- Error messages say what failed, why, and what the user can do next.

## Commits and PRs

- One topic per branch and per PR. Short imperative subject line.
- Commit messages carry no AI attribution (`Co-Authored-By`, "Claude Code",
  claude.ai links). The `no-ai-attribution` commit-msg hook rejects them.
- Never commit secrets. The `gitleaks` hook scans staged files.
- Do not commit generated site output by hand. `docs/` is pkgdown output.
