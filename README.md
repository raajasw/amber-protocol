# Amber Protocol

A twelve-minute cognitive warm-up for the hour when you are too drowsy to code
but not ready to stop.

Relaxing games make drowsiness worse — a soothing puzzle at three in the
afternoon puts you to sleep. What actually clears sleep inertia is *effortful*
thinking wrapped in a calm nervous system. So a session alternates: a block of
hard cognitive work, then box breathing to bring arousal back down before the
next one. That is the whole design.

Single HTML file, no build step, no dependencies beyond two Google Fonts.

**Play it: https://raajasw.github.io/amber-protocol/**

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

Blocks 01, 04 and 08 are **Downshift**: paced breathing, four seconds in and
six out, the only cool-hued screen in the app. That ten-second cycle is six
breaths a minute, which is roughly where the slow-breathing literature centres;
box breathing at 4-4-4-4 is better known but a slower sixteen-second cycle with
less behind it.

Speeded tasks show a countdown bar for the trial and open at a deliberate pace
(Stroop at 4 s, rotation at 11 s), tightening only after a run of correct
answers. Mental rotation figures are generated as self-avoiding lattice walks
and checked for genuine chirality, so a mirrored pair is never solvable by
recognising a silhouette.

## Keys

`1`–`4` Stroop colours · `J`/`K` same or mirrored · `Space` n-back match and
skip a rule card · digits + `Enter` operator chain · `Esc` pause. Switching tabs
pauses automatically.

## What the evidence actually supports

Worth stating plainly, because the brain-training industry does not.

**Near transfer is real.** Practise these tasks and you will get better at them.
The adaptive ceilings — Corsi span, n-back level, chain length — will rise.

**Far transfer is not.** Improvement on trained tasks spreading to general
reasoning or day-to-day work has repeatedly failed to replicate:

- **Owen et al. (2010, _Nature_)** trained 11,430 people for six weeks. Gains on
  the trained tasks, no transfer to untrained ones.
- **Jaeggi et al. (2008, _PNAS_)** is the study that made n-back famous by
  claiming gains in fluid intelligence. **Redick et al. (2013)** and the
  meta-analysis of **Melby-Lervåg, Redick & Hulme (2016)**, both using proper
  active controls, found no convincing far transfer.
- **Simons et al. (2016, _Psychological Science in the Public Interest_)**
  reviewed the field and found the evidence for real-world benefit weak, with
  most positive results lacking active control groups.
- A 2014 consensus statement signed by ~70 cognitive scientists (Stanford Center
  on Longevity / Max Planck Institute) rejected industry claims. Lumosity settled
  with the FTC for $2M in 2016 over the same advertising.

So this is a **warm-up, not training**. A warm-up does not make an athlete
stronger; it makes them ready to perform in the next hour. That narrower claim
rests on firmer ground:

- **Sleep inertia** is well documented (Tassi & Muzet, 2000), and effortful
  cognitive engagement dissipates it faster than waiting it out.
- **Reaction time is a validated alertness marker** — the Psychomotor Vigilance
  Task (Dinges & Powell, 1985) is the standard instrument in sleep research. The
  open→close comparison here is a crude version of a legitimate measure.
- **Slow paced breathing** has reasonable support for shifting autonomic balance
  and lowering self-reported stress (Zaccaro et al., 2018, systematic review).

If drowsiness is the real problem, a **10–20 minute nap**, **bright light** and
**physical movement** all have better evidence than cognitive tasks. This is for
when you cannot do those.

The Progress screen is built around this distinction: it charts the alertness
delta, and labels the task ceilings as the near transfer they are.

## What the debrief tells you

Every correct response is timed. At the end the console compares your opening
median against your closing median: if reaction time dropped, you genuinely woke
up, and the advice is to go straight at the hardest thing while it lasts. If it
rose, that is sleep pressure rather than lack of effort, and a walk will beat a
second session.

## Running it

Play it at **https://raajasw.github.io/amber-protocol/** — served from this
repo by GitHub Pages, which gives the page a real origin, so your streak and
scores persist between visits.

Or open `index.html` locally, or build the macOS launcher:

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

Each finished session records its timestamp, length, composite score, trial
count, Stroop accuracy, best Corsi span, peak n-back level, longest chain, median
response time, and the opening/closing medians behind the alertness delta. The
last 40 are kept.

The Progress screen charts one bar per session against a zero line: below it you
finished faster than you opened, above it slower, and a flat tick means too few
responses to measure. An amber rolling median over five sessions runs across the
bars, because one session's delta moves with sleep, caffeine and time of day more
than it does with the protocol. Under five measured sessions the headline says so
rather than drawing a conclusion.

Published as a Claude Artifact, the page stores sessions in the artifact's `db`
so progress follows you across devices. Anywhere else it falls back to
`localStorage`. Both paths are wrapped, so the page works with neither.
