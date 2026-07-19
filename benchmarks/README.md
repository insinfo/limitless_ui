# benchmarks

Benchmark app used to compare limitless_ui rendering performance between the
2.x `dart:html` line (branch `ngx8`) and the 3.x `package:web` line (branch
`ngx9`). The app renders a 2,500-row `li-datatable` without virtualization, a
`li-dropdown-menu` with 60 items and a `li-select` with 300 options, and is
driven from the outside by a Puppeteer script — the component code has no
instrumentation, so the exact same sources compile against both lines.

## Results (2026-07-19, dart2js release, Chrome headless, 2 alternated rounds)

| Metric (warm medians)             | ngx8 / dart:html | ngx9 / package:web |
| --------------------------------- | ---------------- | ------------------ |
| Render 2,500-row datatable        | 1,016 ms         | 1,065 ms           |
| Open dropdown (60 items)          | 43.8 ms          | 46.0 ms            |
| Open select (300 options)         | 45.4 ms          | 46.6 ms            |
| Release `main.dart.js` size       | 550 KB           | **472 KB (-14%)**  |

Runtime differences are within measurement noise (the p10-p90 ranges overlap
almost entirely; overlay deltas are smaller than one 16 ms frame). The real,
reproducible win of the migration is the 14% smaller bundle, which improves
download and parse time on startup. Both `dart:html` and `package:web` are
near-zero-cost layers over the same DOM objects, so DOM-bound scenarios are
expected to tie.

## How to run

1. Build and serve this app in release mode:

   ```bash
   cd benchmarks
   dart pub get
   dart run build_runner build --release --output build --delete-conflicting-outputs
   cd build/web && python -m http.server 8090 --bind 127.0.0.1
   ```

2. Run the driver (from `benchmarks/`):

   ```bash
   CHROME_EXECUTABLE="C:\Program Files\Google\Chrome\Application\chrome.exe" \
     dart run tool/bench.dart http://127.0.0.1:8090 ngx9-package-web
   ```

   Progress goes to stderr; the last stdout line is a JSON document with all
   samples plus cold/median/warm-median aggregates per metric.

3. To measure the old line, create a worktree of `ngx8`, copy this directory
   into it, change `ngx_dart` to `^8.0.1` in the copy's `pubspec.yaml`
   (`limitless_ui` resolves to 2.0.0 via the `path: ..` dependency), then
   repeat steps 1-2 on another port:

   ```bash
   git worktree add ../limitless_ui_ngx8 ngx8
   cp -r benchmarks ../limitless_ui_ngx8/benchmarks
   ```

Run the two variants alternately and prefer warm medians: the first samples
carry JIT warm-up and machine noise.
