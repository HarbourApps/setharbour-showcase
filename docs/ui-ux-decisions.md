# UI / UX decisions

The design choices behind the SetHarbour portfolio edition, and the reasoning
for each.

## The dashboard prioritises "Start a workout"

Logging a workout is the app's core job, so the *Start a workout* button is the
highest-emphasis control on the home screen: full width, a bright accent
gradient and a leading arrow. Everything else on the dashboard is informational;
this is the one action we want to be unmissable, so a returning user can begin
in a single tap.

## Empty states instead of blank charts

When there is no history, the dashboard shows a friendly empty state with a
clear next step, not a chart full of zeros. A zeroed bar chart looks broken and
tells a first-time user nothing; an empty state explains what will appear and
invites the first action. `DashboardSummary.isEmpty` drives this switch.

## Plans support both folder and list views

Different users organise differently. Some think in **folders** (Push Pull Legs,
5×5, Upper/Lower); others prefer to **scan and filter a flat list** by category
and difficulty. Rather than force one mental model, the browser offers both — and
because they are two presentations of the same collection, neither view can get
out of sync with the other. The preferred view is remembered.

## The LED ticker shares compact dashboard space

The dashboard has a lot to show in a small space. The ticker packs several
rotating contextual messages ("20 workout plans set up and ready", "4 workouts
logged this week", "your latest backup is ready to export") into a single
compact panel, so we surface timely context without adding several separate
cards and pushing the primary action below the fold.

## The rotating gold glow supports the SetHarbour identity

SetHarbour's palette is a deep navy background with a cyan accent and a signature
gold highlight. The ticker's slowly-rotating gold border glow is a small,
premium-feeling motion detail that reinforces that identity and draws the eye to
the day's message without being distracting. It degrades to a static panel under
reduced-motion settings.

## Validation happens immediately

Numeric input is validated on every keypress, not on submit. In a gym you enter
numbers quickly and glance away; catching an over-long value the instant it is
typed (and refusing the extra digit) is far less error-prone than letting a bad
value sit and rejecting it later.

## Invalid values are not silently truncated

If a rule is broken, the app **rejects the keystroke and keeps the previous
value intact** — it never quietly trims "1500" down to "150". Silent truncation
would put a *wrong* number into your workout history without you noticing, which
is worse than a visible, momentary rejection.

## The Superman message was intentionally retained

The three-digit limit is enforced with a deliberately friendly line:

> This app is not made for Superman — only 3 digits maximum 🦸

It is part of SetHarbour's product personality — a hard rule delivered with a
light touch. It is finished, on-brand copy, preserved verbatim here (see
[`validation-and-error-handling.md`](validation-and-error-handling.md)); it is
not a placeholder to be "professionalised".

## Progress is presented as understandable summaries

Raw numbers are computed, but the history screen leads with a plain-English
sentence and a classification badge ("Controlled session", "Demanding timed
workout") before the detailed set breakdown. Most people want to know *how the
session went* at a glance; the numbers are there for those who want them.

## Consistent card layouts and navigation

Every screen uses the same `SurfaceCard` surface, the same `SectionHeader`
labels, the same rounded-corner language and the same six-tab bottom navigation.
Consistency makes the app feel like one product and means a control learned on
one screen behaves the same everywhere.
