# Changelog

[日本語](CHANGELOG.ja.md)

Versions of this fork. The history of the original edax_runner (5.3.0 and earlier) follows below. The tests and measurements are in [docs/validation/changelog.en.md](docs/validation/changelog.en.md).

## 5.3.0+nikque.13

Updates the bundled libedax to Edax 4.5.5 nikque.25. Between nikque.23 and nikque.25, the changed engine source is the book analysis implementation. The libedax API and runner source are unchanged. See [validation](docs/validation/changelog.en.md#530nikque13).

---
## 5.3.0+nikque.12

This version updates the bundled libedax to Edax 4.5.5 nikque.23. What edax_runner does and the books it learns are unchanged. Tag `v5.3.0-nikque.12`; libedax: [Edax 4.5.5 nikque.23](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.23).

**Changes**

- libedax is now that of Edax 4.5.5 nikque.23 (Edax release notes: [nikque.23](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque23)).
- nikque.23 changes the text command `book moveinfo` of Edax (its precision stages are taken over from the answers of the positions before and after) and the warning after a book command typed without `book` (it adds a hint). edax_runner does not use them.
- Documents: this changelog was rewritten and the test and measurement records moved to `docs/validation/`. The first comment lines of `config.ini` point to chapter 4 of the Edax manual (the settings are the same).

**Compatibility**

- The libedax functions that edax_runner uses and what they do, and `eval.dat`, are the same as in nikque.22 (5.3.0+nikque.11). The settings of `config.ini` are the same too (only its first comment lines differ).
- The search and the books are the same as with nikque.22.

**Not checked**: speed and memory; running on real Linux and macOS machines.

[Tests and measurements](docs/validation/changelog.en.md#530nikque12)

---

## 5.3.0+nikque.11

This version updates the bundled libedax to Edax 4.5.5 nikque.22. What edax_runner does and the books it learns are unchanged. Tag `v5.3.0-nikque.11`; libedax: [Edax 4.5.5 nikque.22](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.22).

**Changes**

- libedax is now that of Edax 4.5.5 nikque.22, which includes the changes of nikque.19 to 21 (Edax release notes: [nikque.19](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque19), [nikque.20](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque20), [nikque.21](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque21), [nikque.22](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque22)).
- nikque.19 to 22 add text commands to Edax (the book analysis commands, `book findline`, `book reduce` and `book reducecount` with the settings `book-reduce-*`). edax_runner does not use them.

**Compatibility**

- The libedax functions that edax_runner uses and what they do, `config.ini` and `eval.dat` are the same as in nikque.18 (5.3.0+nikque.10).
- The search and the books are the same as with nikque.18.
- The new settings use their default values without a line in `config.ini`. You do not need to change `config.ini`.

**Not checked**: speed and memory; running on real Linux and macOS machines.

[Tests and measurements](docs/validation/changelog.en.md#530nikque11)

---

## 5.3.0+nikque.10

A `data/book.dat` that cannot be read at startup is now kept instead of being replaced, and two edax_runner can no longer run in the same folder at once. Tag `v5.3.0-nikque.10`; libedax: [Edax 4.5.5 nikque.18](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.18).

**Changes**

- A second edax_runner started in the same folder stops without doing anything (exit code 1). Before, the two learned the same lines into the same book and replaced each other's saved book.
- While it runs, edax_runner locks the file `edax_runner.lock` in the folder. The system releases the lock when edax_runner ends, also when it is killed. The file stays in the folder.
- libedax and `config.ini` are now those of Edax 4.5.5 nikque.18, which includes the changes of nikque.16 and 17 (Edax release notes: [nikque.16](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque16), [nikque.17](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque17), [nikque.18](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque18)). What matters for edax_runner:
  - nikque.16: the fixes from a second cross-check (damaged game files and boards are refused, and others), and the function `edax_book_keep_unread_file`.
  - nikque.17: the settings `book-seed` and `book-reproducible` (in `config.ini`).
  - nikque.18: the libraries no longer contain the folder they were built in (error messages show the file name only).
- The Windows ZIPs of the earlier releases: the build folders were removed from the bundled libraries in the same way (nothing else changed).

**Fixes**

- A `data/book.dat` that could not be read at startup (damaged, truncated) was replaced by the book learned from nothing (since 5.3.0+nikque.3, which saves the book to `data/book.dat.saving` and renames it to `data/book.dat`). → It is now kept as `data/book.dat.damaged` before the rename (`edax_book_keep_unread_file`, a libedax function since Edax 4.5.5 nikque.16). If it cannot be kept, `book.dat` is not replaced, and edax_runner stops without changing `learning_list.txt`.

**Compatibility**

- The default behaviour of `book-seed` and `book-reproducible` is unchanged.
- Two edax_runner can no longer run in the same folder at the same time.

**Not checked**: whether `book-store-tasks = 1` became slower than 5.3.0+nikque.9 (not settled within the measurement noise).

[Tests and measurements](docs/validation/changelog.en.md#530nikque10)

---

## 5.3.0+nikque.9

Fixes a bug that could lose an edit of the learning list saved during learning, and updates libedax. Tag `v5.3.0-nikque.9`; libedax: [Edax 4.5.5 nikque.15](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.15) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque15)).

**Changes**

- When learning keeps adding positions to a large book, memory no longer used (the former places in the pool of the loaded book) is released between learning steps (libedax).
- The unused part of the pool is released on Linux and macOS too (libedax).

**Fixes**

- An edit of the learning list saved by the user while edax_runner took the learned lines out of it could be lost (from the original edax_runner). → Just before the list is replaced, its size and modification time are compared with those when it was read; if they changed, it is read again and the step is redone (5 times at most).
- A damaged book file was loaded and could crash later (libedax). → It is not loaded.

**Compatibility**

- On a correct book, learning, `fix` and `[relativeError absoluteError]` make the same book.

**Not checked**: whether lists with random-play lines give exactly the same book as with the nikque.14 libedax (the cause of the differences seen in the post-release checks was not isolated).

[Tests and measurements](docs/validation/changelog.en.md#530nikque9)

---

## 5.3.0+nikque.8

An update to keep the libraries at the same version as Edax itself. edax_runner itself (the Dart code) is unchanged. Tag `v5.3.0-nikque.8`; libedax: [Edax 4.5.5 nikque.14](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.14) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque14)).

**Changes**

- libedax and `config.ini` are now those of Edax 4.5.5 nikque.14. In Edax, this version adds the book commands `book fill2` and `book leaf expand`, a range for `book fill`, and renames `book leaf-recalculate` to `book leaf recalculate`.
- `config.ini`: the comment of `book-leaf-recalculate-rounds` names the new command `book leaf recalculate` (the settings are the same).

**Compatibility**

- What edax_runner uses (learning games, `fix`, `[relativeError absoluteError]`) is unchanged.

---

## 5.3.0+nikque.7

Fixes lines of more than 80 plies (moves + passes) not being learned. Tag `v5.3.0-nikque.7`; libedax: [Edax 4.5.5 nikque.13](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.13) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque13)).

**Changes**

- libedax and `config.ini` are now those of Edax 4.5.5 nikque.13, which fixes the bugs found by an audit of the changes of Edax 4.5.5 nikque.10 to 12.
- `config.ini` has the comment and the line of the new Edax setting `book-leaf-recalculate-rounds` (edax_runner doesn't use it).

**Fixes**

- A line of more than 80 plies (moves + passes) was skipped as an "illegal move". It only happens with 21 passes or more (such a game exists from the usual initial position: 60 moves and 22 passes = 82 plies), so a usual learning list is not affected.
  - Games learned at the same time (`book-store-tasks` is `auto`, or 2 or more): the game record inside libedax still had 80 entries. → Fixed in Edax 4.5.5 nikque.13.
  - Games learned one by one (`book-store-tasks = 1`, lines with `[relativeError absoluteError]`): edax_runner reads the played moves back from libedax and compares them with the line, but only 80 plies can be read back. → The line is now accepted when the moves read back are the beginning of the line and the board has 4 discs plus one for each move of the line. Nothing changes for a line of 80 plies or less.
- The search of a position without a legal move (a pass) could rarely crash. → Fixed (libedax; the search results don't change).

**Compatibility**

- The books are the same as with 5.3.0+nikque.6, except `[relativeError absoluteError]` with `hash-table-size` set to 19 or less (see the [Edax release notes for nikque.13](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque13)).

---

## 5.3.0+nikque.6

An update to keep the libraries at the same version as Edax itself. edax_runner itself (the Dart code) is unchanged. Tag `v5.3.0-nikque.6`; libedax: [Edax 4.5.5 nikque.12](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.12) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque12)).

**Changes**

- libedax is now that of Edax 4.5.5 nikque.12. In Edax, this version adds the command `book leaf-recalculate` (searching the leaves of the book again), makes the commands that cut a book down (`book subtree`, `book prune`) faster, and accepts capitals in the word after `book`.

**Compatibility**

- What edax_runner uses (learning games, `fix`, `[relativeError absoluteError]`) is unchanged.
- `config.ini` is the same.

---

## 5.3.0+nikque.5

An update to keep the libraries at the same version as Edax itself. edax_runner itself (the Dart code) is unchanged. Tag `v5.3.0-nikque.5`; libedax: [Edax 4.5.5 nikque.11](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.11) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque11)).

**Changes**

- libedax is now that of Edax 4.5.5 nikque.11. In Edax, this version changes the commands that cut a book down (`book subtree`, `book prune`), `book correct` and `book enhance`.

**Compatibility**

- What edax_runner uses (learning games, `fix`, `[relativeError absoluteError]`) is unchanged.
- `config.ini` is the same.

---

## 5.3.0+nikque.4

`fix` on a large book and the expansion of `[relativeError absoluteError]` are faster. edax_runner itself (the Dart code) is unchanged. Tag `v5.3.0-nikque.4`; libedax: [Edax 4.5.5 nikque.10](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.10) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque10)).

**Changes**

- libedax and `config.ini` are now those of Edax 4.5.5 nikque.10.
- `fix` (`book fix`): the linking step is faster on a large book (a book of 661.62 million positions with 32 threads: 153.7 seconds → 136.3 seconds, measured with Edax itself).
- `[relativeError absoluteError]` (`book deviate`): up to level 18, a round with many positions to expand (at least 32 times `n-tasks`: 1,024 with 32 threads) runs `n-tasks` single-thread searches at the same time (before, half as many 2-thread searches). With a book of 6.49 million positions and 32 threads, about 1.25 times as many positions are expanded in 60 seconds (measured with Edax itself). Rounds with fewer positions are unchanged.

**Fixes**

- Bugs of libedax were fixed. They don't affect the learning of edax_runner.
  - A game of more than 80 plies (moves + passes) wrote outside its record.
  - The previous string wasn't released when a string setting was set again.
  - `edax_stop` during `edax_bench` didn't end the benchmark.

**Compatibility**

- `fix` makes the same book.
- `[relativeError absoluteError]` makes a book slightly different from the one of `book-expand-tasks = auto` before (see the [Edax release notes for nikque.10](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque10)). For the previous rule, write `book-expand-tasks = 16` (half of `n-tasks`) in `config.ini`.

---

## 5.3.0+nikque.3

Lines that were not learned are no longer removed from the learning list when saving the book fails or memory runs out. Also fixes the bugs found by a final audit of Edax 4.5.5 nikque.8. Tag `v5.3.0-nikque.3`; libedax: [Edax 4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque9)).

**Changes**

- libedax and `config.ini` are now those of Edax 4.5.5 nikque.9.
- Learning many games at the same time is a little faster: the threads of games that ended early are given to the games still being played (128 games at level 18 with 32 threads: 33.6 seconds → 30.3 seconds, measured with Edax itself; same memory).
- When memory for the searches done at the same time isn't available, edax goes on with fewer searches instead of terminating.
- edax no longer saves the book to `data/book.dat.store` after each learning step (the new setting `book-store-auto-save` of Edax 4.5.5 nikque.9, which edax_runner turns off). edax_runner saves `book.dat` itself right after, so the whole book was written twice.
- Development and release:
  - `scripts/build_edax_runner.sh` stops if a command fails (it went on and ended successfully even if the libraries couldn't be copied).
  - `Create Release` stops if the tag of the version already exists (run again with the same version, it replaced the files of the published release).
  - The workflow that labels pull requests (`labeling_pr.yaml`, `.github/labeler.yml`) was removed: it's not used in this fork.
  - Tests were added: `learning_list.txt` edited while learning (the same lines, lines inserted, moved or removed).

**Fixes**

- A failure to save `book.dat` (e.g. another program has `book.dat` open) wasn't noticed, and the learned lines were removed from `learning_list.txt`. If edax_runner ended after that, they weren't in `book.dat`. → edax now saves the book to another file (`data/book.dat.saving`), and `book.dat` is replaced with it after checking that it has been saved (with `edax_book_save_checked`, a new libedax function that reports the result, and by looking at the file). Saving is retried every second, up to 30 times; if the book still can't be saved, edax_runner stops without changing `learning_list.txt`.
- When edax couldn't add the positions of the games learned at the same time to the book (not enough memory), the lines were also removed as learned. → edax_runner stops without changing `learning_list.txt` (the libedax of Edax 4.5.5 nikque.9 reports the failure). The same applies when a game learned alone, `[relativeError absoluteError]` or `fix` can't add a position (`edax_book_failed`, a new libedax function).
- The search with several threads could leave a move unsearched in a node (rarely giving wrong results; a bug of the original Edax 4.5.5).
- A line of `learning_list.txt` longer than 255 bytes because of spaces between its moves could be learned as a shorter game.
- A book file that couldn't be read at startup (damaged, or opened by another program) was overwritten after learning. → It is kept as `book.dat.damaged`.
- When several games are learned at the same time (`book-store-tasks` >= 2), a line whose `book-randomness` is 128 or more (e.g. `200,F5F6`) wasn't learned and was recorded as `skipped (illegal move)`. → Such a line is learned with the other games.
- A number larger than 2147483647 in `[relativeError absoluteError]` was passed to edax as another number (e.g. 4294967296 as 0). → The line is skipped as `too large number`.
- When the last byte of a skipped line was 0x85 or 0xA0 (e.g. a character of Shift_JIS), the byte was lost in `learned_log.txt`.

**Compatibility**

- The search with one thread is unchanged.
- When games are learned together, the moves of the last games of a group can change from one run to the next.
- `data/book.dat.store` is no longer created.
- Lines with `book-randomness` 128 or more: the libedax of Edax 4.5.5 nikque.9 has no limit. With an older libedax, such a line is learned alone, as with `book-store-tasks = 1`.

**Note**: from this version to 5.3.0+nikque.9, a `data/book.dat` that could not be read at startup was replaced by the learned book (because `data/book.dat.saving` is renamed to it). This was fixed in 5.3.0+nikque.10.

---

## 5.3.0+nikque.2

Fixes the default `book-store-tasks = auto` being slower than `1` in some cases. Tag `v5.3.0-nikque.2`; libedax: [Edax 4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) ([release notes](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque8)).

**Changes**

- libedax and `config.ini` are now those of Edax 4.5.5 nikque.8.
- 128 games at level 18 (32 logical CPUs): 37 to 39 seconds → 35 to 36 seconds.

**Fixes**

- With `book-store-tasks = auto` (the default), learning was slower than with `1` when few positions had to be searched or at a high level: a single game at level 24 took 26 seconds instead of 13, at level 21 6.4 seconds instead of 4.2. → The threads are now shared between the searches done at the same time: 6 to 11 seconds at level 24, 2.0 seconds at level 21, and 30 single games at level 18 took 18 seconds instead of 29 (35 with `1`). (Measured with the commands of edax.)

**Compatibility**: not stated in the records of this version. For Edax itself, see the [Edax release notes for nikque.8](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/RELEASE-NOTES.md#v455-nikque8).

---

## 5.3.0+nikque.1

The first release of this fork ([Nikque/edax_runner](https://github.com/Nikque/edax_runner)), from 5.3.0 of [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner). It switches edax to Edax 4.5.5 (nikque), learns several games at the same time, and fixes the handling of the learning list. Tag `v5.3.0-nikque.1`; libedax: [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX).

**Changes**

- edax is Edax 4.5.5 (nikque) instead of Edax 4.4.
- libedax is built for several levels of CPU (any x86-64, AVX2, AVX-512), and edax_runner uses the fastest one the CPU can run (Windows, Linux).
- The settings are in `config.ini` of Edax 4.5.5 (nikque) instead of `edax.ini`.
- Several games are learned at the same time with `book-store-tasks` of `config.ini` (`auto` by default: as many games as `n-tasks`; `1`: one game after another, as before).
  - The next lines of edax vs edax (up to `book-store-tasks`) are played at the same time, then their positions are searched at the same time and stored (`edax_book_store_games` of libedax, called with `dart:ffi`).
  - `learning_list.txt` and `learned_log.txt` are updated once for these lines.
- Lines such as `[0 0]F5F6`, `[ 0 0 ] F5F6`, `2, F5F6` are accepted.
- The directory of the executable is used if `learning_list.txt` isn't in the current directory.
- `learning_list.txt` is handled faster with less memory, by handling it as bytes and reading it once per line to learn.

**Fixes**

- A blank line in `learning_list.txt` stopped edax_runner. → It's ignored.
- A line that can't be learned (unknown format, illegal move) was removed as if it had been learned. edax ignores an illegal move and the following ones, so a game was learned from an unintended position. → It's skipped with a warning, and recorded in `learned_log.txt` as a comment.
- edax_runner crashed if `learning_list.txt` had a comment that isn't UTF-8 (e.g. Shift_JIS).
- The line terminators (CRLF) of `learning_list.txt` were replaced by LF.
- If `learning_list.txt` was edited while learning, another line was removed instead of the learned one.
- The book wasn't saved right after `fix`.
- `exit` wasn't removed from `learning_list.txt`, so edax_runner couldn't be restarted without editing it.
- `book.dat` and `learning_list.txt` could be broken if edax_runner was killed while saving them. → They are replaced after saving to another file (`book.dat`: by edax).

**Compatibility**

- libedax has the same functions as the original one.
- `edax.ini` is still read, but `config.ini` takes priority.
- With the default `book-store-tasks = auto`, several games are learned at the same time. To learn one game at a time as before, set it to `1`.

---

# Original edax_runner (sensuikan1973)

## 5.3.0

upgrade dependencies.

## 5.2.0

upgrade dependencies.

## 5.1.0

upgrade dependencies.

## 5.0.1

upgrade dependencies.

## 5.0.0

drop the support for macos with intel silicon.

## 4.7.1

fix release workflow.

## 4.7.0

upgrade dependencies.

## 4.6.0

upgrade dependencies.

## 4.5.0

improve the message on launching.

## 4.4.0

upgrade dependencies.

## 4.3.0

upgrade dependencies.

## 4.2.0

upgrade dependencies.

## 4.1.0

upgrade dependencies.

## 4.0.0

Up until now "[x y] moves" executes `book-fix` command implicitly, but from now on "[x y] moves" doesn't.  
When you want to execute `book-fix` command, you have to write text "fix" on learning_list.txt explicitly.

## 3.14.0

improve print messages.

## 3.13.2

fix release workflow

## 3.13.1

reupload release assets

## 3.13.0

upgrade dependencies.

## 3.12.0

upgrade dependencies.

## 3.11.0

upgrade dependencies.

## 3.10.0

upgrade dependencies.

## 3.9.0

upgrade dependencies.

## 3.8.0

upgrade dependencies.

## 3.7.0

fix deviate process

## 3.6.0

update logging message.

## 3.5.0

upgrade dependencies.

## 3.4.0

upgrade dependencies.

## 3.3.0

upgrade dependencies.

## 3.2.1

fix release workflow.

## 3.2.0

update release workflow.

## 3.1.3

upgrade dependencies.

## 3.1.2

update release workflow.

## 3.1.1

fix windows release workflow.

## 3.1.0

upgrade dependencies.

## 3.0.2

fix release workflow.

## 3.0.1

[macos] fix release artifact.

## 3.0.0

support intel silicon mac, once again

## 2.34.0

upgrade dependencies.

## 2.33.0

upgrade dependencies.

## 2.32.0

upgrade dependencies.

## 2.31.0

upgrade dependencies.

## 2.30.0

upgrade dependencies.

## 2.29.0

upgrade dependencies.

## 2.28.1

upgrade dependencies.

## 2.28.0

upgrade dependencies.

## 2.27.0

upgrade dependencies.

## 2.26.0

upgrade dependencies.

## 2.25.0

upgrade dependencies.

## 2.24.0

upgrade dependencies.

## 2.23.1

upgrade dependencies.

## 2.23.0

upgrade dependencies.

## 2.22.0

upgrade dependencies.

## 2.21.0

upgrade dependencies.

## 2.20.0

upgrade dependencies.

## 2.19.0

upgrade dependencies.

## 2.18.0

upgrade dependencies.

## 2.17.0

upgrade dependencies.

## 2.16.0

upgrade dependencies.

## 2.15.0

upgrade dependencies.

## 2.14.0

upgrade dependencies.

## 2.13.0

upgrade dependencies.

## 2.12.0

add CHANGELOG.md
