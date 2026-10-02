# edax_runner

![Dart CI](https://github.com/sensuikan1973/edax_runner/workflows/Dart%20CI/badge.svg)

<p align="center">
<img src="https://github.com/sensuikan1973/edax_runner/blob/main/resources/logo.png?raw=true" alt="edax-runner" />
</p>

tiny tool for [edax-reversi](https://github.com/sensuikan1973/edax-reversi) **auto** learning.

- you can write learning list as simple format txt.
  - you can also check the logs.
- Mac, Windows, Linux are supported.

This is a fork of [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) which learns with [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX). See [About this fork](#about-this-fork).

![demo](https://github.com/sensuikan1973/edax_runner/blob/main/resources/demo.gif)

## Usage

1. download the Asset from the [latest Release](https://github.com/sensuikan1973/edax_runner/releases/latest).
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

There are **only 5 rules**. Example is [here](https://github.com/sensuikan1973/edax_runner/blob/main/resources/learning_list.txt).

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
  - You can edit `learning_list.txt` while edax_runner is running. edax_runner reads it again whenever it has finished learning a line. For example, you can stop edax_runner after the current line by adding `exit` to the head.
  - The comments can be written in any encoding except UTF-16.

## About this fork

- edax is [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) instead of Edax 4.4. Its `libedax` has the same functions as [the original one](https://github.com/sensuikan1973/edax-reversi), so [libedax4dart](https://pub.dev/packages/libedax4dart) is used as it is.
  - It searches faster with less memory, and the scores can differ from Edax 4.4 at the same level.
  - The book file is compatible. (Edax 4.4 can also read the book saved by this version)
- libedax is built for several levels of CPU, and edax_runner uses the fastest one which your CPU can run. (Windows, Linux)

  | CPU                  | Windows              | Linux           |
  | :------------------- | :------------------- | :-------------- |
  | any x86-64           | `libedax-x64.dll`    | `libedax.so`    |
  | x86-64-v3 (AVX2)     | `libedax-x64-v3.dll` | `libedax-v3.so` |
  | x86-64-v4 (AVX-512)  | `libedax-x64-v4.dll` | `libedax-v4.so` |

- The settings are in `config.ini`, which is the one of Edax 4.5.5 (nikque). See the comments in it.
  - By default, the level is 18, all the logical CPUs are used (`n-tasks = auto`), and the depth of the book is the one of your `book.dat` (`book-depth = auto`).
  - `edax.ini` is still read if it exists, but `config.ini` is prioritized.
  - If you run several edax_runner at the same time, set `n-tasks` so that they don't use more threads than your CPU has. (A search of a line of 30 moves or more is short, and more than 8 threads don't make it faster.)
- Several games can be learned at the same time with `book-store-tasks` of `config.ini`. (`1` by default: a game after the other, as before)
  - With `book-store-tasks = auto` (or a number), edax_runner takes the next lines of edax vs edax (up to that number) from `learning_list.txt`, and libedax plays them at the same time, then searches the positions of all these games at the same time and stores them. The book is linked, negamaxed and saved once for these games.
  - One edax_runner uses all the CPUs, so there is no need to run several edax_runner and merge their books. 128 games at level 18 on a PC with 32 logical CPUs took 39 to 42 seconds with `book-store-tasks = auto`, against 113 seconds with `1` (and 134 seconds with `1` and `n-tasks = 8`). It is about the speed of several edax_runner at the same time (41 seconds with 8 of them and `n-tasks = 4`, 35 seconds with 16 and `n-tasks = 2`, without the time to merge the books). See [the README of Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/README-NIKQUE.en.md) for the measured speed and for how much the book differs from the one learned with `book-store-tasks = 1`.
  - The games of a group are played with the book as it was before the group, and the moves of each game aren't printed.
  - `book deviate`, `fix` and a single line of edax vs edax are learned as before.
- `book.dat` and `learning_list.txt` are replaced after saving to another file, so they aren't broken even if edax_runner is killed while saving.

## References

- [edax-reversi](https://github.com/abulmo/edax-reversi)
  - [code/releases archive](https://code.google.com/archive/p/edax-reversi/downloads)
  - [website archive](https://archive.is/KshiN)
  - [document](https://sensuikan1973.github.io/edax-reversi/)
- [libedax4dart](https://pub.dev/packages/libedax4dart)
- [Edax_AutoLearning_Tool](https://github.com/sensuikan1973/Edax_AutoLearning_Tool): original tool. See **[issues/1](https://github.com/sensuikan1973/Edax_AutoLearning_Tool/issues/1)**.
- [Choirokoitia | Edax](https://choi.lavox.net/edax/start): great edax documents (Japanese)
