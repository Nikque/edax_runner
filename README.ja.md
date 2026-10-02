# edax_runner

[English](README.md) · [Releases](https://github.com/Nikque/edax_runner/releases) · [変更履歴](CHANGELOG.ja.md)

![Dart CI](https://github.com/Nikque/edax_runner/workflows/Dart%20CI/badge.svg)

<p align="center">
<img src="https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/logo.png?raw=true" alt="edax-runner" />
</p>

[edax-reversi](https://github.com/Nikque/edax-reversi-AVX) に**自動で**学習させる小さなツールです。

- 学習させたい内容を、簡単な書式のテキストファイルに書きます。
  - 学習が済んだ内容は、ログで確認できます。
- Mac、Windows、Linux で動きます。

これは [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) の fork で、[Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) で学習します。元の edax_runner との違いは、[この fork で変えたこと](#この-fork-で変えたこと)を見てください。

![demo](https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/demo.gif)

## 使い方

1. [最新の Release](https://github.com/Nikque/edax_runner/releases/latest) から、お使いの OS 用のファイルをダウンロードします。
2. `learning_list.txt` に、学習させたい内容を書きます。
3. `config.ini` を、好みの設定に書き換えます。
4. （必要なら）自分の `book.dat` を `data/book.dat` に置きます。
5. edax_runner を実行します。
6. 学習が済んだ内容は `learned_log.txt` で確認できます。

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

### learning_list.txt の書き方

規則は**5つだけ**です。例は[こちら](https://github.com/Nikque/edax_runner/blob/nikque-fixes/resources/learning_list.txt)。

| 目的                           | 書式                                   | 例                     |
| :----------------------------- | :------------------------------------- | :--------------------- |
| Edax 対 Edax を1局学習する     | `{book-randomness},{手順}`             | `2,F5F6F7F8`           |
| `book deviate` コマンド        | `[relativeError absoluteError] {手順}` | `[1 1] F5F6F7F8`       |
| コメント                       | `// {コメント}`                        | `// I like Brightwell` |
| `book fix` コマンド            | `fix`                                  | `fix`                  |
| edax_runner を止める           | `exit`                                 | `exit`                 |

- 補足
  - `book-randomness` の既定値は `0` です。`F5F6F7` と書くと `0,F5F6F7` と同じです。
  - `book deviate` については、[edax のドキュメント](https://sensuikan1973.github.io/edax-reversi/book_8c.html#ae9ee489a468274fd83808c53da0418c9)と [Choirokoitia のドキュメント](https://choi.lavox.net/edax/start)を見てください。
  - 空行は無視します。
  - 学習できない行（書式が違う、打てない手がある）は飛ばします。`learned_log.txt` には `// [edax_runner] skipped (illegal move): F5F5` のようなコメントとして記録します。
  - edax_runner の実行中に `learning_list.txt` を書き換えてもかまいません。edax_runner は、1行の学習が終わるたびに読み直します。たとえば先頭に `exit` を足すと、いまの行の学習が終わったところで止まります。
  - コメントの文字コードは、UTF-16 以外なら何でもかまいません。

## この fork で変えたこと

元の edax_runner 5.3.0 との違いです。

| | 元の edax_runner 5.3.0 | この fork |
| :-- | :-- | :-- |
| [Edax](#1-edax-44-の代わりに-edax-455-nikque) | Edax 4.4 | Edax 4.5.5 (nikque)：探索が速く、メモリが少ない |
| [libedax](#2-cpu-に合わせたライブラリ) | OS ごとに1つ | CPU が動かせる中で最も速いもの（x86-64 共通、AVX2、AVX-512） |
| [設定](#3-設定は-configini) | `edax.ini` | Edax 4.5.5 (nikque) の `config.ini`（`edax.ini` も読みます） |
| [学習](#4-複数の棋譜を同時に学習) | 1局ずつ | 複数の棋譜を同時に：論理CPU 32 で約3倍の速さ |
| [`learning_list.txt`](#5-learning_listtxt-と保存の修正) | 不具合が8件（下記） | 修正 |
| [保存](#5-learning_listtxt-と保存の修正) | ファイルを直接上書き | 別のファイルに保存してから置き換える |

使い方と `learning_list.txt` の書式は同じです。

### 1. Edax 4.4 の代わりに Edax 4.5.5 (nikque)

- edax は [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) です。その `libedax` は[元の libedax](https://github.com/sensuikan1973/edax-reversi) と同じ関数を持つので、[libedax4dart](https://pub.dev/packages/libedax4dart) はそのまま使っています。
- 探索が速く、メモリが少なくなります。同じ level でも、評価値が Edax 4.4 と違うことがあります。
- book のファイルは互換です（この版が保存した book を、Edax 4.4 も読めます）。

### 2. CPU に合わせたライブラリ

libedax を CPU の世代ごとにビルドしてあり、edax_runner は、お使いの CPU が動かせる中で最も速いものを使います（Windows と Linux。Mac の `libedax.universal.dylib` は、Apple silicon と Intel の両用です）。

| CPU                  | Windows              | Linux           |
| :------------------- | :------------------- | :-------------- |
| x86-64 のどの CPU でも | `libedax-x64.dll`    | `libedax.so`    |
| x86-64-v3（AVX2）    | `libedax-x64-v3.dll` | `libedax-v3.so` |
| x86-64-v4（AVX-512） | `libedax-x64-v4.dll` | `libedax-v4.so` |

どれを使っているかは、`[edax_runner] use "libedax-x64-v4.dll".` のように表示します。

### 3. 設定は config.ini

- 設定は `config.ini` に書きます。Edax 4.5.5 (nikque) の `config.ini` と同じものです。項目の説明は、ファイルの中のコメントにあります。
- 既定では、level は18、論理 CPU を全部使い（`n-tasks = auto`）、book の深さは `book.dat` の値のままです（`book-depth = auto`）。
- `edax.ini` があればそれも読みますが、`config.ini` の設定が優先です。

### 4. 複数の棋譜を同時に学習

`config.ini` の `book-store-tasks` の数だけ、棋譜を同時に学習します（既定は `auto`＝`n-tasks` と同じ数）。

- edax_runner は、`learning_list.txt` から「Edax 対 Edax」の行をその数まで取り出し、libedax がそれらを同時に対局し、全部の棋譜の局面を同時に探索して book に入れます。book の Link の張り直し・negamax・保存は、その組につき1回です。
- `book-store-tasks = 1` にすると、元の edax_runner と同じく1局ずつ学習します。
- edax_runner 1本で全部の CPU を使うので、edax_runner を何本も起動して後で book を merge する必要がなくなりました。論理 CPU 32 の PC で、棋譜128本を level 18 で学習した実測：

  | | 時間 |
  | :-- | :-- |
  | `book-store-tasks = auto`（既定） | 35〜36秒 |
  | `book-store-tasks = 1` | 113秒（`n-tasks = 8` では134秒） |
  | edax_runner を8本同時（`n-tasks = 4`）＋ book の merge | 42秒＋2秒 |
  | edax_runner を16本同時（`n-tasks = 2`）＋ book の merge | 35秒＋3秒 |

- できる book は、`book-store-tasks = 1` で学習した book とまったく同じにはなりません。違いの大きさと実測の詳細は、[Edax 4.5.5 (nikque) の README](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/README-NIKQUE.ja.md) を見てください。
- 同じ組の棋譜は、その組を始める前の book を使って対局します。1局ごとの手順は表示しません。
- `book deviate`、`fix`、1行だけの「Edax 対 Edax」は、1つずつ学習します（1局だけの場合も、その局面の探索は同時に行います。level 18 で1局ずつ30局の学習は18秒で、`book-store-tasks = 1` では35秒でした。edax に同じコマンドを入力して測った値です）。
- それでも edax_runner を何本も同時に起動する場合は、合計のスレッド数が CPU の数を超えないように `n-tasks` を設定してください。

### 5. learning_list.txt と保存の修正

| | 元の edax_runner 5.3.0 | この fork |
| :-- | :-- | :-- |
| 空行 | edax_runner が止まる | 無視する |
| 学習できない行（書式が違う、打てない手がある） | 学習済みとして消される（edax は打てない手とその後の手を無視するので、意図しない局面から学習していた） | 警告を出して飛ばし、`learned_log.txt` にコメントとして記録する |
| UTF-8 でないコメント（Shift_JIS など） | edax_runner が異常終了する | そのまま扱える（UTF-16 以外） |
| 改行コード（CRLF） | LF に書き換えられる | そのまま |
| 学習中に `learning_list.txt` を書き換えた | 学習した行ではない別の行が消される | 学習した行が消される |
| `fix` | 直後に book が保存されない | 保存する |
| `exit` | `learning_list.txt` から消えないので、書き換えないと再開できない | 消す |
| 保存中に edax_runner を強制終了した | `book.dat` や `learning_list.txt` が壊れることがある | 別のファイルに保存してから置き換える |

そのほかの変更：

- `[0 0]F5F6`、`[ 0 0 ] F5F6`、`2, F5F6` のような書き方も受け付けます。
- `learning_list.txt` が作業フォルダにないときは、実行ファイルのあるフォルダを使います。
- `learning_list.txt` の処理を速くし、メモリも少なくしました（バイト列のまま扱い、1行学習するごとに1回だけ読みます）。

### 変更したファイル

| ファイル | 変更 |
| :-- | :-- |
| `bin/edax_runner.dart` | ライブラリの選択、`config.ini`、複数の棋譜の同時学習、上の修正 |
| `lib/learning_list.dart`（新規） | `learning_list.txt` をバイト列のまま読み書きする処理 |
| `test/learning_list_test.dart`（新規） | その試験 |
| `resources/dll/` | Edax 4.5.5 (nikque) の libedax：Windows 3個、Linux 3個、Mac 1個 |
| `resources/config.ini`（新規）、`resources/edax.ini`（削除） | 設定 |
| `scripts/build_edax_runner.sh`、`.github/workflows/` | OS ごとのライブラリを全部同梱する。Release は手動で作る（`Create Release`） |

### 版

| edax_runner | Edax | |
| :-- | :-- | :-- |
| [5.3.0+nikque.2](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.2) | [4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) | 探索する局面が少ないときや level が高いときに速く（level 24 の1局：26秒 → 6〜11秒） |
| [5.3.0+nikque.1](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.1) | [4.5.5 nikque.7](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.7) | この fork の最初の版 |

## 参考

- [edax-reversi](https://github.com/abulmo/edax-reversi)
  - [コードと配布物のアーカイブ](https://code.google.com/archive/p/edax-reversi/downloads)
  - [Web サイトのアーカイブ](https://archive.is/KshiN)
  - [ドキュメント](https://sensuikan1973.github.io/edax-reversi/)
- [libedax4dart](https://pub.dev/packages/libedax4dart)
- [Edax_AutoLearning_Tool](https://github.com/sensuikan1973/Edax_AutoLearning_Tool)：元になったツール。**[issues/1](https://github.com/sensuikan1973/Edax_AutoLearning_Tool/issues/1)** を参照。
- [Choirokoitia | Edax](https://choi.lavox.net/edax/start)：edax の詳しい解説（日本語）
