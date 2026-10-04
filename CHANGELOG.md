# 5.3.0+nikque.3

The tag is `v5.3.0-nikque.3`.

- libedax and `config.ini` of [Edax 4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9): the bugs found by a final audit of Edax 4.5.5 nikque.8 are fixed. (see its release notes)
  - fix of the search with several threads: a move could be left unsearched in a node (rare wrong results; a bug of the original Edax 4.5.5). The search with one thread is unchanged.
  - fix: a line of `learning_list.txt` longer than 255 bytes because of spaces between its moves could be learned as a shorter game.
  - fix: a book file which couldn't be read at startup (damaged, or opened by another program) was overwritten after learning. Now it is kept as `book.dat.damaged`.
  - when the memory for the searches done at the same time isn't available, edax goes on with fewer searches instead of terminating.
- edax doesn't save the book to `data/book.dat.store` after each learning any more (the new setting `book-store-auto-save` of Edax 4.5.5 nikque.9, which edax_runner turns off): edax_runner saves `book.dat` itself right after, so the whole book was written twice. `data/book.dat.store` is no longer created.

- fix: a failure of saving `book.dat` (e.g. another program opens `book.dat`) wasn't noticed, and the learned lines were removed from `learning_list.txt`. If edax_runner ended after that, they weren't in `book.dat`.
  - Now edax saves the book to another file (`data/book.dat.saving`), and `book.dat` is replaced with it after checking that it has been saved (with `edax_book_save_checked`, a new function of libedax which tells it, and by looking at the file). Saving is retried every second, up to 30 times; if the book still can't be saved, edax_runner stops without changing `learning_list.txt`.
- fix: when several games are learned at the same time (`book-store-tasks` >= 2), a line whose `book-randomness` is 128 or more (e.g. `200,F5F6`) wasn't learned, and was recorded as `skipped (illegal move)`. Now such a line is learned with the other games. (libedax of Edax 4.5.5 nikque.9 has no limit; with an older libedax, such a line is learned alone, as with `book-store-tasks = 1`)
- if edax can't add the positions of the games learned at the same time to the book (not enough memory), edax_runner stops without changing `learning_list.txt`. (libedax of Edax 4.5.5 nikque.9 tells it; before, the lines were removed as learned) The same when a game learned alone, `[relativeError absoluteError]` or `fix` can't add a position. (`edax_book_failed`, a new function of libedax)
- fix: a number larger than 2147483647 in `[relativeError absoluteError]` was passed to edax as another number. (e.g. 4294967296 as 0) Now the line is skipped as `too large number`.
- fix: when the last byte of a skipped line was 0x85 or 0xA0 (e.g. a character of Shift_JIS), the byte was lost in `learned_log.txt`.
- `scripts/build_edax_runner.sh` stops if a command fails. (it went on and ended successfully even if the libraries couldn't be copied)
- `Create Release` stops if the tag of the version already exists. (run again with the same version, it replaced the files of the published release)
- remove the workflow which labels pull requests (`labeling_pr.yaml`, `.github/labeler.yml`): it's not used in this fork.
- add tests: `learning_list.txt` edited while learning. (the same lines, lines inserted, moved or removed)

# 5.3.0+nikque.2

The tag is `v5.3.0-nikque.2`.

- libedax and `config.ini` of [Edax 4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8).
  - fix: with `book-store-tasks = auto` (the default), learning was slower than with `1` when few positions had to be searched or at a high level: a single game at level 24 took 26 seconds instead of 13, at level 21 6.4 seconds instead of 4.2. The threads are now shared between the searches done at the same time: 6 to 11 seconds at level 24, 2.0 seconds at level 21, and 30 single games at level 18 took 18 seconds instead of 29 (35 with `1`). (measured with the commands of edax)
  - 128 games at level 18 (32 logical CPUs): 37 to 39 seconds before, 35 to 36 seconds now.

# 5.3.0+nikque.1

The first release of this fork ([Nikque/edax_runner](https://github.com/Nikque/edax_runner)), from 5.3.0 of [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner). The tag is `v5.3.0-nikque.1`.

- edax is [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) instead of Edax 4.4. (libedax has the same functions as the original one)
- libedax is built for several levels of CPU (any x86-64, AVX2, AVX-512), and edax_runner uses the fastest one which the CPU can run. (Windows, Linux)
- the settings are in `config.ini` of Edax 4.5.5 (nikque) instead of `edax.ini`. (`edax.ini` is still read, but `config.ini` is prioritized)
- learn several games at the same time with `book-store-tasks` of `config.ini`. (`auto` by default: as many games as `n-tasks`; `1`: a game after the other, as before)
  - the next lines of edax vs edax (up to `book-store-tasks`) are played at the same time, then their positions are searched at the same time and stored. (`edax_book_store_games` of libedax, called with `dart:ffi`)
  - `learning_list.txt` and `learned_log.txt` are updated once for these lines.
- fix: a blank line in `learning_list.txt` stopped edax_runner. Now it's ignored.
- fix: a line which can't be learned (unknown format, illegal move) was removed as if it had been learned. Now it's skipped with a warning, and recorded in `learned_log.txt` as a comment.
  - edax ignores an illegal move and the following ones, so a game was learned from an unintended position.
- fix: edax_runner crashed if `learning_list.txt` had a comment which isn't UTF-8 (e.g. Shift_JIS).
- fix: the line terminators (CRLF) of `learning_list.txt` were replaced by LF.
- fix: if `learning_list.txt` was edited while learning, another line was removed instead of the learned one.
- fix: the book wasn't saved right after `fix`.
- fix: `exit` wasn't removed from `learning_list.txt`, so edax_runner couldn't be restarted without editing it.
- fix: `book.dat` and `learning_list.txt` could be broken if edax_runner was killed while saving them. Now they are replaced after saving to another file. (`book.dat`: by edax)
- accept `[0 0]F5F6`, `[ 0 0 ] F5F6`, `2, F5F6`.
- use the directory of the executable if `learning_list.txt` isn't in the current directory.
- handle `learning_list.txt` faster with less memory, by handling it as bytes and reading it once per line to learn.

# 5.3.0

upgrade dependencies.

# 5.2.0

upgrade dependencies.

# 5.1.0

upgrade dependencies.

# 5.0.1

upgrade dependencies.

# 5.0.0

drop the support for macos with intel silicon.

# 4.7.1

fix release workflow.

# 4.7.0

upgrade dependencies.

# 4.6.0

upgrade dependencies.

# 4.5.0

improve the message on launching.

# 4.4.0

upgrade dependencies.

# 4.3.0

upgrade dependencies.

# 4.2.0

upgrade dependencies.

# 4.1.0

upgrade dependencies.

# 4.0.0

Up until now "[x y] moves" executes `book-fix` command implicitly, but from now on "[x y] moves" doesn't.  
When you want to execute `book-fix` command, you have to write text "fix" on learning_list.txt explicitly.

# 3.14.0

improve print messages.

# 3.13.2

fix release workflow

# 3.13.1

reupload release assets

# 3.13.0

upgrade dependencies.

# 3.12.0

upgrade dependencies.

# 3.11.0

upgrade dependencies.

# 3.10.0

upgrade dependencies.

# 3.9.0

upgrade dependencies.

# 3.8.0

upgrade dependencies.

# 3.7.0

fix deviate process

# 3.6.0

update logging message.

# 3.5.0

upgrade dependencies.

# 3.4.0

upgrade dependencies.

# 3.3.0

upgrade dependencies.

# 3.2.1

fix release workflow.

# 3.2.0

update release workflow.

# 3.1.3

upgrade dependencies.

# 3.1.2

update release workflow.

# 3.1.1

fix windows release workflow.

# 3.1.0

upgrade dependencies.

# 3.0.2

fix release workflow.

# 3.0.1

[macos] fix release artifact.

# 3.0.0

support intel silicon mac, once again

# 2.34.0

upgrade dependencies.

# 2.33.0

upgrade dependencies.

# 2.32.0

upgrade dependencies.

# 2.31.0

upgrade dependencies.

# 2.30.0

upgrade dependencies.

# 2.29.0

upgrade dependencies.

# 2.28.1

upgrade dependencies.

# 2.28.0

upgrade dependencies.

# 2.27.0

upgrade dependencies.

# 2.26.0

upgrade dependencies.

# 2.25.0

upgrade dependencies.

# 2.24.0

upgrade dependencies.

# 2.23.1

upgrade dependencies.

# 2.23.0

upgrade dependencies.

# 2.22.0

upgrade dependencies.

# 2.21.0

upgrade dependencies.

# 2.20.0

upgrade dependencies.

# 2.19.0

upgrade dependencies.

# 2.18.0

upgrade dependencies.

# 2.17.0

upgrade dependencies.

# 2.16.0

upgrade dependencies.

# 2.15.0

upgrade dependencies.

# 2.14.0

upgrade dependencies.

# 2.13.0

upgrade dependencies.

# 2.12.0

add CHANGELOG.md
