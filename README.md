# Amber Protocol

A twelve-minute cognitive warm-up for the hour when you are too drowsy to code
but not ready to stop.

Relaxing games make drowsiness worse — a soothing puzzle at three in the
afternoon puts you to sleep. What actually clears sleep inertia is *effortful*
thinking wrapped in a calm nervous system. So a session alternates: a block of
hard cognitive work, then box breathing to bring arousal back down before the
next one. That is the whole design.

Single HTML file, no build step, no dependencies beyond two Google Fonts.

## The tasks

Instruments from the psychometric canon rather than invented puzzles. Each one
states its rule with a worked example before the first trial, and every task
adapts to your accuracy so it sits just past comfortable.

| Block | Task | Faculty |
| --- | --- | --- |
| 02 | **Stroop** | Inhibitory control — name the ink, suppress the word |
| 03 | **Corsi span** | Visuospatial memory — cells flash, repeat the order |
| 05 | **Mental rotation** | Spatial reasoning — the same figure turned, or its mirror? |
| 06 | **N-back** | Working memory — press on a match N places back |
| 07 | **Operator chain** | Numeric fluency — hold a running total under load |

Blocks 01, 04 and 08 are **Downshift**: 4-4-4-4 box breathing, the only
cool-hued screen in the app.

Speeded tasks show a countdown bar for the trial and open at a deliberate pace
(Stroop at 4 s, rotation at 11 s), tightening only after a run of correct
answers. Mental rotation figures are generated as self-avoiding lattice walks
and checked for genuine chirality, so a mirrored pair is never solvable by
recognising a silhouette.

## Keys

`1`–`4` Stroop colours · `J`/`K` same or mirrored · `Space` n-back match and
skip a rule card · digits + `Enter` operator chain · `Esc` pause. Switching tabs
pauses automatically.

## What the debrief tells you

Every correct response is timed. At the end the console compares your opening
median against your closing median: if reaction time dropped, you genuinely woke
up, and the advice is to go straight at the hardest thing while it lasts. If it
rose, that is sleep pressure rather than lack of effort, and a walk will beat a
second session.

## Running it

Open `amber-protocol.html` in a browser, or build the macOS launcher:

```sh
./tools/make-app.sh              # -> ~/Desktop/Amber Protocol.app
./tools/make-app.sh /Applications
```

The launcher hands the file straight to your default browser and exits — no
local server, no dependencies, nothing left running. An earlier version served
the page on a loopback port to give `localStorage` a stable origin, but that
made macOS prompt about `python3` accepting network connections, which is a
poor trade for a relaxation app.

The consequence is that a locally-opened copy stores progress under a `file://`
origin, and some browsers drop those writes. The page probes storage on load and
says so on the opening screen if nothing will persist — use the hosted link if
you want a streak that builds.

`tools/make-icon.py` renders the icon (slate panel, amber clock ring) from
signed distance fields into hand-written PNGs, then `iconutil` assembles the
`.icns`; it is pure stdlib.

The app holds its **own copy** of the HTML, so re-run `make-app.sh` after
editing the page.

## Changing the protocol

`PROTOCOL` near the top of the script sets the block order and how the session
is divided — each entry's `f` is its fraction of the total, and the fractions
sum to 1. Session length is chosen in the UI (8, 12 or 18 minutes) and the
fractions scale to it.

Per-task difficulty lives in each `task*` function: opening deadlines, how fast
they tighten, and the floors and ceilings.

## Progress

Published as a Claude Artifact, the page stores sessions in the artifact's `db`
so progress follows you across devices. Anywhere else it falls back to
`localStorage`. Both paths are wrapped, so the page works with neither.
