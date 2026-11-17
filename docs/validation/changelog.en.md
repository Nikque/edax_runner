# Tests and measurements (changelog)

[日本語](changelog.ja.md)

The tests and measurements done for the versions of this fork, moved unchanged from [CHANGELOG.md](../../CHANGELOG.md). What changed in each version is in [CHANGELOG.md](../../CHANGELOG.md).

## 5.3.0+nikque.16

- The seven libraries match the published nikque.29 ZIP (taken again from the release and checked against its digest and SHA256SUMS); before the change, each was that of the nikque.27 ZIP. No build folder names were found. Sizes: the Windows DLLs +512 bytes each, the Linux libraries 0 to +4,096 bytes, the macOS library +48 bytes. `bin/config.ini` is the same in nikque.27 and nikque.29, and `resources/data/eval.dat` is the `bin/data/eval.dat` of nikque.29.
- On Windows (logical CPUs 28 to 31), Dart format and analysis passed and 38 tests passed. `edax_runner.exe` was built from this source with `dart compile exe`, as in the CI.
- Against the published 5.3.0+nikque.15 (its executable, libraries and configuration), with the new executable, the Windows libraries of nikque.29 and the same `config.ini`: the 10 runs (5 lists, 1 thread and 2 threads) all exited 0 with the same learning lists and logs, and the same books except one 2-thread run (`games`, `book-store-tasks auto`); its book changes from run to run with either version (run again, the old book of the first run was the same as the new book of the second).
- Small test data, at most two logical CPUs for each run. Linux and macOS execution, speed and memory were not tested.

## 5.3.0+nikque.15

- The seven libraries match the published nikque.27 ZIP (taken again from the release and checked against its digest and SHA256SUMS). No build folder names were found. Sizes: the Windows DLLs +1,536 to +3,584 bytes, the Linux libraries 0 to +8,192 bytes, the macOS library +480 bytes. `bin/config.ini` of Edax is the same as in nikque.26, and `resources/data/eval.dat` is the same as `bin/data/eval.dat` of nikque.27.
- On Windows (logical CPUs 16 to 19), Dart format and analysis passed and 38 tests passed. `edax_runner.exe` was built from this source with `dart compile exe`, as in the CI.
- Against the published 5.3.0+nikque.14 (its executable, libraries and configuration), with the new executable, the Windows libraries of nikque.27 and the same `config.ini`: all 10 old/new comparisons exited 0, and had identical learning lists and logs and the same numbers of errors, warnings and book saves in the output; eight books matched. The other two (the lists `base` and BOM/CRLF, each with a line of `book-randomness` 4, one thread) differ by the random choice: with `book-seed` fixed to 1 to 6, the canonical books of old and new matched for all six seeds of both lists (12 pairs).
- A truncated book (a test book cut at 40,000 bytes) was kept as `data/book.dat.damaged` (the same bytes) and the learned book saved; a concurrent second startup was rejected (exit 1) while the first learned 24 lines; startup after normal and forced termination succeeded.
- A test book held without sharing for the first 5 seconds of the startup: edax_runner stopped with an error (exit 1) without learning; `book.dat` and `learning_list.txt` were unchanged, with no `.damaged`. Held for 1 second (libedax waited and opened it again) or not held: it learned as usual, and the canonical books were the same. The same with `libedax-x64.dll` only and with the three Windows DLLs (`-v4` chosen). For reference, the published 5.3.0+nikque.14 executable with the libedax of nikque.27 and the book held 5 seconds kept the book and the list, but learned, could not save the book and ended with exit 255 after 31 seconds, leaving `data/book.dat.saving`.
- A list with CR-only line ends (two lines, `exit`, one line): the two lines were learned and edax_runner stopped at `exit`, leaving the last line in the list; 5.3.0+nikque.14 skipped the whole list as one line of unknown format.
- Small test data, levels 1 to 8, and at most two logical CPUs for each run. Linux and macOS execution, speed and memory were not tested. An edit of `learning_list.txt` saved while it is rewritten was tested by the Dart tests only; the first line taken after the book is loaded and the book not saved after a group with no game learned were not tried end to end.

## 5.3.0+nikque.14

- The seven libraries match the published nikque.26 ZIP (taken again after the release and checked against its SHA256SUMS). No build folder names were found. Sizes: the Windows DLLs +17,920 to +19,456 bytes, the Linux libraries +8,192 to +12,288 bytes, the macOS library +33,024 bytes (the code of the export).
- On Windows (logical CPUs 16 to 19), Dart format and analysis passed and 27 tests passed. With the published 5.3.0+nikque.13 executable and configuration, all 10 old/new comparisons exited 0 and had identical learning lists and logs; nine books matched. The tenth (the BOM/CRLF list with a line of `book-randomness` 4, one thread) differs by the random choice: with `book-seed` fixed to 1 to 6, the canonical books of old and new matched for all six seeds, and for the list `base` too (12 pairs).
- A truncated book was kept as `data/book.dat.damaged` (the same bytes) and the learned book saved; a concurrent second startup was rejected (exit 1) while the first learned 24 lines; startup after normal and forced termination succeeded. Small test data and at most two logical CPUs.
- Linux and macOS execution, speed and memory were not tested. `edax_book_deviate_export` itself was tested in the API checks of Edax (218 checks of the libraries), not through edax_runner.

## 5.3.0+nikque.13

- The seven libraries match the published nikque.25 ZIP. No build source paths were found. Windows DLL and macOS library sizes are unchanged; the Linux libraries grew by 4,096 bytes each.
- On Windows, Dart format and analysis passed and 27 tests passed. With the published 5.3.0+nikque.12 executable and configuration, all 10 old/new comparisons exited 0 and had identical learning lists and logs. Seven books matched. For two single-thread lists with random choices, all six fixed seeds produced identical canonical books. For a two-thread game list, scheduling can affect the learned book; in three runs per version with seed 1, the six canonical books matched.
- A truncated book was preserved, concurrent second startup was rejected, and startup after normal and forced termination succeeded. The comparison used small test data and at most two CPUs.
- Linux and macOS execution, speed and memory were not tested.
## 5.3.0+nikque.12

- The search and the books are the same as with nikque.22 (the checks of Edax: the results, node counts and lines of fforum-20-39, 204 API checks of the libraries).
- The libraries: the 3 Windows DLLs are 512 bytes larger, the 3 Linux ones 8,192 bytes, the macOS one has the same size (not the same bytes).

Checks (Windows, one or two logical CPUs):

- The same five lists as for 5.3.0+nikque.11, at level 6, with 1 thread / one game at a time and 2 threads / `book-store-tasks = auto`, against 5.3.0+nikque.11 as published, with the same executable and `config.ini` and the DLLs of this version: every exit code 0, the same books, `learning_list.txt` and `learned_log.txt` in 8 of 10 pairs; `learning_list.txt` and `learned_log.txt` are the same in all 10.
  - With 1 thread, the list `base` (with a line of `book-randomness` 4): with `book-seed` set to 1 to 6, the books of both are the same for the 6 seeds.
  - With 2 threads, the list of 30 games: 5.3.0+nikque.11 as published gave 3 books in 3 runs by itself, and the books still varied with `book-seed` fixed (the order of the 2 games learned at once); both gave some of the same books. With 1 thread, the books of this list are the same.
- A truncated `data/book.dat` and one line to learn: it is kept as `data/book.dat.damaged` (the same bytes) and the learned book is saved. A second edax_runner stops in 0.2 seconds (exit 1) and the first one learns 24 lines. After the first one ended, and after it was killed, the next one starts and learns.
- The 7 bundled libraries are those of Edax 4.5.5 nikque.23 byte for byte and hold no build folder.
- `dart format`, `dart analyze --fatal-infos --fatal-warnings`, `dart test` (27 tests).
- The speed and the memory were not measured. Not tried on Linux and macOS.

## 5.3.0+nikque.11

- The search and the books are the same as with nikque.18 (the checks of Edax: the results, node counts and lines of fforum-20-39, 204 API checks of the libraries).
- The libraries: the 3 Windows DLLs are 1,024 to 1,536 bytes larger, the 3 Linux ones 98,336 to 110,656 bytes, the macOS one 165,120 bytes (the code of the analysis commands).

Checks (Windows, one or two logical CPUs):

- The same five lists as for 5.3.0+nikque.10, at level 6, with 1 thread / one game at a time and 2 threads / `book-store-tasks = auto`, against 5.3.0+nikque.10 as published, with the same executable and `config.ini` and the DLLs of this version: every exit code 0, the same books, `learning_list.txt` and `learned_log.txt` in 9 of 10 pairs. In the 10th (a list with a line of `book-randomness` 4), with `book-seed` set to 1 to 6, the books are the same for the 6 seeds (and for another list with the same line).
- A truncated `data/book.dat` and one line to learn: it is kept as `data/book.dat.damaged` (the same bytes) and the learned book is saved. A second edax_runner stops in 0.2 seconds (exit 1) and the first one learns 24 lines. After the first one ended, and after it was killed, the next one starts and learns.
- The 7 bundled libraries are those of Edax 4.5.5 nikque.22 byte for byte and hold no build folder.
- `dart format`, `dart analyze --fatal-infos --fatal-warnings`, `dart test` (27 tests).
- The speed and the memory were not measured. Not tried on Linux and macOS.

## 5.3.0+nikque.10

Checks (Windows, one or two logical CPUs):

- A truncated `data/book.dat` (100,000 bytes) and one line to learn: 5.3.0+nikque.9 replaced it (exit 0, no `.damaged`); this version keeps it as `data/book.dat.damaged` (the same bytes) and saves the learned book.
- A second edax_runner started while the first learns 24 lines in the same folder: with the change, it stops in 0.2 seconds (exit 1) and the first one learns the 24 lines; without it, both learned (35 lines in `learned_log.txt`). After the first one ended, and after it was killed, the next one starts and learns.
- The same five lists as for 5.3.0+nikque.9, at level 6, with 1 thread / one game at a time and 2 threads / `book-store-tasks = auto`, against 5.3.0+nikque.9 as published: every exit code 0, the same books, `learning_list.txt` and `learned_log.txt` in 9 of 10 pairs. In the 10th (a list with a line of `book-randomness` 4), three runs of each version gave the same three books (the random choice of the line).
- Speed (Windows, 32 logical CPUs, 128 games learned at level 18 into a book of 270,000 positions, alternating with 5.3.0+nikque.9): `book-store-tasks = auto` (the default) 32.6 to 32.7 seconds (ratio 0.995, 4 rounds). `book-store-tasks = 1` about 117 to 119 seconds: the ratio is 1.009 over 4 rounds (all 4 slower), but one run differs from the next by about ±3 % with the same version, and without the first run of each round the ratio is 1.001; with one thread (4 games, CPU cycles, 6 rounds) it is 1.000. Whether it became slower is not settled yet. The same peak memory (728 and 293 MiB).
- `dart format`, `dart analyze --fatal-infos --fatal-warnings`, `dart test` (27 tests).

## 5.3.0+nikque.9

- **Post-release checks (2026-10-15)**: the same 5.3.0+nikque.9 executable with nikque.14/15 DLLs, five identical lists, with 1 thread / one game at a time and 4 threads / auto (10 pairs). Every exit code was 0; remaining lists and learned logs matched byte for byte in every pair. Canonical books matched in all six pairs using 30 games, error limits or an empty list. Two of four pairs using the bundled list or its BOM/CRLF form matched; two differed. Repeating the BOM/CRLF list three times with the same new DLL also changed the book (292/292/290 positions). Exact book equality was not established for lists with random-play lines; the cause of those differences was not fully isolated from version changes.
- In test-only copies of the learned-line removal function, an edit was injected after reading the list and writing the saving file: the old code lost the added line; the new code reread the list, kept it and wrote one learned-log entry. No test hook was added to distributed source or binaries.
