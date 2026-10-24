# Tests and measurements (changelog)

[日本語](changelog.ja.md)

The tests and measurements done for the versions of this fork, moved unchanged from [CHANGELOG.md](../../CHANGELOG.md). What changed in each version is in [CHANGELOG.md](../../CHANGELOG.md).

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
