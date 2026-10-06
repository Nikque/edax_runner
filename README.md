# edax_runner

[日本語](README.ja.md) · [Releases](https://github.com/Nikque/edax_runner/releases) · [Changelog](CHANGELOG.md)

![Dart CI](https://github.com/Nikque/edax_runner/workflows/Dart%20CI/badge.svg)

<p align="center">
<img src="https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/logo.png?raw=true" alt="edax-runner" />
</p>

tiny tool for [edax-reversi](https://github.com/Nikque/edax-reversi-AVX) **auto** learning.

- you can write learning list as simple format txt.
  - you can also check the logs.
- Mac, Windows, Linux are supported.

This is a fork of [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) which learns with [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX). See [What this fork changes](#what-this-fork-changes).

![demo](https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/demo.gif)

## Usage

1. download the Asset from the [latest Release](https://github.com/Nikque/edax_runner/releases/latest).
2. edit `learning_list.txt` which you want to let edax learn.
3. edit `config.ini` which you like.
4. [optional] add your `book.dat` to `data/book.dat`.
5. run edax_runner.
6. you can check what runner has already learned by checking `learned_log.txt`.

<details><summary>Mac</summary>

```sh
./edax_runner
```

</details>

<details><summary>Windows</summary>

```sh
start ./edax_runner.exe
```

</details>

<details><summary>Linux</summary>

```sh
./edax_runner
```

</details>

### How to write learning_list.txt ?

There are **only 5 rules**. Example is [here](https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/learning_list.txt).

| purpose                        | format                                 | example                |
| :----------------------------- | :------------------------------------- | :--------------------- |
| learn one game of edax vs edax | `{book-randomness},{move}`             | `2,F5F6F7F8`           |
| `book deviate` command         | `[relativeError absoluteError] {move}` | `[1 1] F5F6F7F8`       |
| comment                        | `// {your comment}`                    | `// I like Brightwell` |
| `book fix` command             | `fix`                                  | `fix`                  |
| stop edax_runner               | `exit`                                 | `exit`                 |

- NOTE
  - The default value of `book-randomness` is `0`. So, you can also write `F5F6F7` which is equal to `0,F5F6F7`.
  - What's `book deviate` ?: See [edax document](https://sensuikan1973.github.io/edax-reversi/book_8c.html#ae9ee489a468274fd83808c53da0418c9), [Choirokoitia document](https://choi.lavox.net/edax/start)
  - Blank lines are ignored.
  - A line which can't be learned (unknown format, illegal move) is skipped. It's recorded in `learned_log.txt` as a comment like `// [edax_runner] skipped (illegal move): F5F5`.
  - You can edit `learning_list.txt` while edax_runner is running. edax_runner reads it again whenever it has finished learning a line (or a group of games learned at the same time). For example, you can stop edax_runner after the current line (or group) by adding `exit` to the head.
  - The comments can be written in any encoding except UTF-16.

## What this fork changes

Compared with the original edax_runner 5.3.0:

| | Original edax_runner 5.3.0 | This fork |
| :-- | :-- | :-- |
| [Edax](#1-edax-455-nikque-instead-of-edax-44) | Edax 4.4 | Edax 4.5.5 (nikque): faster searches, less memory |
| [libedax](#2-a-library-for-each-level-of-cpu) | one library per OS | the fastest one which your CPU can run (any x86-64, AVX2, AVX-512); all the functions of the original libedax, usable by other programs too |
| [Settings](#3-settings-in-configini) | `edax.ini` | `config.ini` of Edax 4.5.5 (nikque) (`edax.ini` is still read) |
| [Learning](#4-several-games-are-learned-at-the-same-time) | a game after the other | several games at the same time: about 3 times faster with 32 logical CPUs |
| [`learning_list.txt`](#5-fixes-of-learning_listtxt-and-of-saving) | 8 bugs (below) | fixed |
| [Saving](#5-fixes-of-learning_listtxt-and-of-saving) | files are overwritten | files are replaced after saving to another file |

The way to use it and the format of `learning_list.txt` are the same.

### 1. Edax 4.5.5 (nikque) instead of Edax 4.4

- edax is [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX). Its `libedax` has the same functions as [the original one](https://github.com/sensuikan1973/edax-reversi), so [libedax4dart](https://pub.dev/packages/libedax4dart) is used as it is.
- It searches faster with less memory, and the scores can differ from Edax 4.4 at the same level.
- The book file is compatible. (Edax 4.4 can also read the book saved by this version)

### 2. A library for each level of CPU

`resources/dll/` (and the Release archives) hold the libedax of [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX): **all the 93 functions of the original libedax are available**, with the same names, arguments and data layout, and 5 more (`edax_book_deviate2`, `edax_book_deviate3`, `edax_book_store_games`, `edax_book_store_tasks`, `libedax_cpu_level`). edax_runner itself only uses a few of them.

libedax is built for several levels of CPU, and edax_runner uses the fastest one which your CPU can run. (Windows, Linux; on Mac, `libedax.universal.dylib` is for Apple silicon and Intel)

| CPU                  | Windows              | Linux           |
| :------------------- | :------------------- | :-------------- |
| any x86-64           | `libedax-x64.dll`    | `libedax.so`    |
| x86-64-v3 (AVX2)     | `libedax-x64-v3.dll` | `libedax-v3.so` |
| x86-64-v4 (AVX-512)  | `libedax-x64-v4.dll` | `libedax-v4.so` |

edax_runner prints the one which it uses, like `[edax_runner] use "libedax-x64-v4.dll".`

**Using these libraries in another program**: they are not tied to edax_runner. Any program written for libedax (with [libedax4dart](https://pub.dev/packages/libedax4dart), or calling the functions of `libedax.h` from C, Python, C#, ...) can use them: put the library and `data/eval.dat` next to the program. The header (`src/libedax.h`), a short example (`tests/libedax_example.c`), the differences from the original libedax and the libraries for Android are in [the README of Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/README-NIKQUE.en.md) ("libedax: Edax as a library"); the libraries are also in the ZIP of its [Releases](https://github.com/Nikque/edax-reversi-AVX/releases).

### 3. Settings in config.ini

- The settings are in `config.ini`, which is the one of Edax 4.5.5 (nikque). See the comments in it.
- By default, the level is 18, all the logical CPUs are used (`n-tasks = auto`), and the depth of the book is the one of your `book.dat` (`book-depth = auto`).
- `edax.ini` is still read if it exists, but `config.ini` is prioritized.

### 4. Several games are learned at the same time

Several games are learned at the same time, with `book-store-tasks` of `config.ini`. (`auto` by default: as many games as `n-tasks`)

- edax_runner takes the next lines of edax vs edax (up to that number) from `learning_list.txt`, and libedax plays them at the same time, then searches the positions of all these games at the same time and stores them. The book is linked, negamaxed and saved once for these games.
- With `book-store-tasks = 1`, a game is learned after the other, as the original edax_runner does.
- One edax_runner uses all the CPUs, so there is no need to run several edax_runner and merge their books. Measured with 128 games at level 18 on a PC with 32 logical CPUs:

  | | time |
  | :-- | :-- |
  | `book-store-tasks = auto` (default) | 35 to 36 seconds |
  | `book-store-tasks = 1` | 113 seconds (134 seconds with `n-tasks = 8`) |
  | 8 edax_runner at the same time, `n-tasks = 4`, then merging their books | 42 + 2 seconds |
  | 16 edax_runner at the same time, `n-tasks = 2`, then merging their books | 35 + 3 seconds |

- The book is not exactly the same as the one learned with `book-store-tasks = 1`: see [the README of Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/README-NIKQUE.en.md) for how much it differs, and for the measurements.
- The games of a group are played with the book as it was before the group, and the moves of each game aren't printed.
- `book deviate`, `fix` and a single line of edax vs edax are learned one by one. (the positions of a single game are still searched at the same time: 30 single games at level 18 took 18 seconds, against 35 seconds with `book-store-tasks = 1`, with the same commands typed in edax)
- If you still run several edax_runner at the same time, set `n-tasks` so that they don't use more threads than your CPU has.

### 5. Fixes of learning_list.txt and of saving

| | Original edax_runner 5.3.0 | This fork |
| :-- | :-- | :-- |
| a blank line | edax_runner stopped | ignored |
| a line which can't be learned (unknown format, illegal move) | removed as if it had been learned (edax ignores an illegal move and the following ones, so a game was learned from an unintended position) | skipped with a warning, and recorded in `learned_log.txt` as a comment |
| a comment which isn't UTF-8 (e.g. Shift_JIS) | edax_runner crashed | accepted (any encoding except UTF-16) |
| line terminators (CRLF) | replaced by LF | kept |
| `learning_list.txt` edited while learning | another line was removed instead of the learned one | the learned line is removed |
| `fix` | the book wasn't saved right after it | saved |
| `exit` | wasn't removed from `learning_list.txt`, so edax_runner couldn't be restarted without editing it | removed |
| edax_runner killed while saving | `book.dat` and `learning_list.txt` could be broken | they are replaced after saving to another file |

Other changes:

- `[0 0]F5F6`, `[ 0 0 ] F5F6` and `2, F5F6` are accepted.
- The directory of the executable is used if `learning_list.txt` isn't in the current directory.
- `learning_list.txt` is handled faster with less memory (it's handled as bytes, and read once per line to learn).
- If `book.dat` can't be saved (e.g. another program opens `book.dat`), saving is retried every second, up to 30 times. If it still can't be saved, edax_runner stops without changing `learning_list.txt`. (since 5.3.0+nikque.3; before, the lines were removed as learned even if the book wasn't saved)
- `book.dat`, `learning_list.txt` and `learned_log.txt` aren't broken even if edax_runner is killed. The line being learned (or the group of games being learned at the same time) is learned from the beginning at the next run. If edax_runner is killed right after saving the book (before rewriting `learning_list.txt`), the line (or group) is learned once more, and can be recorded twice in `learned_log.txt`.

### Where the changes are

| file | change |
| :-- | :-- |
| `bin/edax_runner.dart` | choice of the library, `config.ini`, learning several games at the same time, the fixes above |
| `lib/learning_list.dart` (new) | reading and rewriting `learning_list.txt` as bytes |
| `test/learning_list_test.dart` (new) | tests of the above |
| `resources/dll/` | libedax of Edax 4.5.5 (nikque): 3 for Windows, 3 for Linux, 1 for Mac |
| `resources/config.ini` (new), `resources/edax.ini` (removed) | settings |
| `scripts/build_edax_runner.sh`, `.github/workflows/` | the libraries of each OS are bundled; the release is created by hand (`Create Release`) |

### Versions

| edax_runner | Edax | |
| :-- | :-- | :-- |
| [5.3.0+nikque.4](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.4) | [4.5.5 nikque.10](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.10) | faster `fix` on a large book, faster expansion of `[relativeError absoluteError]` (rounds with many positions; the book differs a little) |
| [5.3.0+nikque.3](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.3) | [4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9) | bug fixes found by a final audit (a book that wasn't saved is noticed, the search with several threads, long lines, a book file that can't be read) |
| [5.3.0+nikque.2](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.2) | [4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) | faster when few positions are searched or at a high level (a single game at level 24: 26 seconds before, 6 to 11 seconds now) |
| [5.3.0+nikque.1](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.1) | [4.5.5 nikque.7](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.7) | the first version of this fork |

## References

- [edax-reversi](https://github.com/abulmo/edax-reversi)
  - [code/releases archive](https://code.google.com/archive/p/edax-reversi/downloads)
  - [website archive](https://archive.is/KshiN)
  - [document](https://sensuikan1973.github.io/edax-reversi/)
- [libedax4dart](https://pub.dev/packages/libedax4dart)
- [Edax_AutoLearning_Tool](https://github.com/sensuikan1973/Edax_AutoLearning_Tool): original tool. See **[issues/1](https://github.com/sensuikan1973/Edax_AutoLearning_Tool/issues/1)**.
- [Choirokoitia | Edax](https://choi.lavox.net/edax/start): great edax documents (Japanese)
