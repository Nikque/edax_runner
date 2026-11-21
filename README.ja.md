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
  - edax_runner の実行中に `learning_list.txt` を書き換えてもかまいません。
    - edax_runner は、1 行の学習が終わるたびに `learning_list.txt` を読み直します。同時に学習する棋譜は、その 1 組の学習が終わるたびです。
    - たとえば先頭に `exit` を足すと、いまの行（組）の学習が終わったところで止まります。
  - edax_runner が学習した行を消して `learning_list.txt` を書き換える間に、`learning_list.txt` が保存されることがあります。そのときは読み直して、保存された中身から行を消します。
    - 1 分ほど保存が続いて落ち着かないときは、`learning_list.txt` を書き換えずに止まります。
    - 学習した行は `learned_log.txt` に記録してあり、次の起動でもう一度学習します。
  - コメントの文字コードは、UTF-16 以外なら何でもかまいません。

## この fork で変えたこと

元の edax_runner 5.3.0 との違いです。

| | 元の edax_runner 5.3.0 | この fork |
| :-- | :-- | :-- |
| [Edax](#1-edax-44-の代わりに-edax-455-nikque) | Edax 4.4 | Edax 4.5.5 (nikque)：探索が速く、メモリが少ない |
| [libedax](#2-cpu-に合わせたライブラリ) | OS ごとに1つ | CPU が動かせる中で最も速いもの（x86-64 共通、AVX2、AVX-512）。元の libedax の全関数が使え、ほかのソフトからも利用可 |
| [設定](#3-設定は-configini) | `edax.ini` | Edax 4.5.5 (nikque) の `config.ini`（`edax.ini` も読みます） |
| [学習](#4-複数の棋譜を同時に学習) | 1局ずつ | 複数の棋譜を同時に：論理CPU 32 で約3倍の速さ |
| [`learning_list.txt`](#5-learning_listtxt-と保存の修正) | 不具合が8件（下記） | 修正 |
| [保存](#5-learning_listtxt-と保存の修正) | ファイルを直接上書き | 別のファイルに保存してから置き換える |

使い方と `learning_list.txt` の書式は同じです。

### 1. Edax 4.4 の代わりに Edax 4.5.5 (nikque)

- edax は [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) です。
- その `libedax` は[元の libedax](https://github.com/sensuikan1973/edax-reversi) と同じ関数を持ちます。そのため、[libedax4dart](https://pub.dev/packages/libedax4dart) はそのまま使っています。
- 探索が速く、メモリが少なくなります。
- 同じ level でも、評価値が Edax 4.4 と違うことがあります。
- book のファイルは互換です。この版が保存した book を、Edax 4.4 も読めます。

### 2. CPU に合わせたライブラリ

`resources/dll/` と Release の ZIP に入っているのは、[Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) の libedax です。

- 元の libedax の 93 個の関数が、すべて使えます。名前・引数・データの並びも同じです。
- さらに、`edax_book_deviate2`・`edax_book_deviate3`・`edax_book_store_games`・`edax_book_store_tasks`・`libedax_cpu_level` などの関数を追加しています。
- Edax 4.5.5 nikque.26（5.3.0+nikque.14）からは、`edax_book_deviate_export` も使えます。`book deviate`・`deviate2`・`deviate3` がたどる進行を、book を広げずにテキストファイルに書き出します。
- nikque.27（5.3.0+nikque.15）からは、`edax_book_file_status` も使えます。起動のときに book のファイルを読めたか・開けたかを返します。edax_runner も使います。
- 追加した関数の一覧は [Edax のマニュアルの 12 章](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/manual/ja/12-integration.md) にあります。edax_runner 自身が使うのは、そのうちの一部だけです。

libedax は、CPU の世代ごとにビルドしてあります。Windows と Linux では、edax_runner は、お使いの CPU が動かせる中で最も速いものを使います。Mac の `libedax.universal.dylib` は、Apple silicon と Intel の両用です。

| CPU                  | Windows              | Linux           |
| :------------------- | :------------------- | :-------------- |
| x86-64 のどの CPU でも | `libedax-x64.dll`    | `libedax.so`    |
| x86-64-v3（AVX2）    | `libedax-x64-v3.dll` | `libedax-v3.so` |
| x86-64-v4（AVX-512） | `libedax-x64-v4.dll` | `libedax-v4.so` |

どれを使っているかは、`[edax_runner] use "libedax-x64-v4.dll".` のように表示します。

**このライブラリをほかのソフトで使う場合**

- ライブラリは edax_runner 専用ではありません。
- libedax 用に書かれたプログラムなら、ライブラリと `data/eval.dat` をプログラムと同じフォルダーに置けば使えます。[libedax4dart](https://pub.dev/packages/libedax4dart) を使うプログラムや、C・Python・C# などから `libedax.h` の関数を呼ぶプログラムです。
- ヘッダー（`src/libedax.h`）、短い使用例（`tests/libedax_example.c`）、元の libedax との違い、Android 用のライブラリについては、[Edax 4.5.5 (nikque) のマニュアル 12.2「ライブラリ（libedax）」](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/manual/ja/12-integration.md)を見てください。
- ライブラリは、Edax 4.5.5 (nikque) の [Releases](https://github.com/Nikque/edax-reversi-AVX/releases) の ZIP にも入っています。

### 3. 設定は config.ini

- 設定は `config.ini` に書きます。Edax 4.5.5 (nikque) の `config.ini` と同じものです。項目の説明は、ファイルの中のコメントにあります。
- 既定の設定は次のとおりです。
  - level は 18 です。
  - 論理 CPU を全部使います（`n-tasks = auto`）。
  - book の深さは `book.dat` の値のままです（`book-depth = auto`）。
- `edax.ini` があればそれも読みますが、`config.ini` の設定が優先です。

### 4. 複数の棋譜を同時に学習

`config.ini` の `book-store-tasks` の数だけ、棋譜を同時に学習します。既定は `auto` で、`n-tasks` と同じ数です。

学習は次の順に進みます。

1. edax_runner は、`learning_list.txt` から「Edax 対 Edax」の行を、その数まで取り出します。
2. libedax がそれらを同時に対局します。
3. libedax が全部の棋譜の局面を同時に探索して、book に入れます。
4. book の Link の張り直し・negamax・保存を、その組につき 1 回行います。

- `book-store-tasks = 1` にすると、元の edax_runner と同じく 1 局ずつ学習します。
- edax_runner 1 本で全部の CPU を使います。edax_runner を何本も起動して、後で book を merge する必要はなくなりました。論理 CPU 32 の PC で、棋譜 128 本を level 18 で学習した実測です。

  | | 時間 |
  | :-- | :-- |
  | `book-store-tasks = auto`（既定） | 35〜36秒 |
  | `book-store-tasks = 1` | 113秒（`n-tasks = 8` では134秒） |
  | edax_runner を8本同時（`n-tasks = 4`）＋ book の merge | 42秒＋2秒 |
  | edax_runner を16本同時（`n-tasks = 2`）＋ book の merge | 35秒＋3秒 |

- できる book は、`book-store-tasks = 1` で学習した book とまったく同じにはなりません。
  - 違いの大きさは、[Edax 4.5.5 (nikque) のマニュアル 7.2「棋譜の学習を同時に行う：book-store-tasks」](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/manual/ja/07-book-learning.md)にあります。
  - 実測の詳細は、[Edax のテストと実測の記録（nikque.7）](https://github.com/Nikque/edax-reversi-AVX/blob/edax-4.5.5-fixes/docs/validation/nikque.ja.md#v455-nikque7)にあります。
- 同じ組の棋譜は、その組を始める前の book を使って対局します。
- 1 局ごとの手順は表示しません。
- `book deviate`、`fix`、1 行だけの「Edax 対 Edax」は、1 つずつ学習します。
  - 1 局だけの場合も、その局面の探索は同時に行います。
  - level 18 で 1 局ずつ 30 局を学習すると、18 秒でした。`book-store-tasks = 1` では 35 秒でした。edax に同じコマンドを入力して測った値です。
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
- `learning_list.txt` が作業フォルダーにないときは、実行ファイルのあるフォルダーを使います。
- `learning_list.txt` の処理を速くし、メモリも少なくしました。
  - `learning_list.txt` は、バイト列のまま扱います。
  - 1 行学習するごとに 2 回読みます。行を取り出すときと、書き換える前に変わっていないかを確かめるときです。
- `book.dat` を保存できないときは、1 秒おきに 30 回まで保存をやり直します。たとえば、ほかのプログラムが `book.dat` を開いているときです。
  - それでも保存できなければ、`learning_list.txt` を変えずに止まります。
  - 5.3.0+nikque.3 からです。それまでは、保存できていなくても、学習済みとして行を消していました。
- 起動のときに `book.dat` を読めなかった（壊れている・途中で切れている）ときは、学習した book で置き換える前に、`data/book.dat.damaged` として残します。
  - 残せなければ、`learning_list.txt` を変えずに止まります。
  - 5.3.0+nikque.10 からです。Edax 4.5.5 nikque.16 以降の libedax を使う場合です。
- 起動のときに `book.dat` を開けなかった（ほかのプログラムが共有なしで開いていた、など）ときは、libedax が 2 秒ほど待って開き直します。
  - それでも開けなければ、edax_runner は学習を始めずに止まります。`book.dat` と `learning_list.txt` は変えません。時間をおいて起動し直してください。
  - 5.3.0+nikque.15 からです。関数 `edax_book_file_status` を持つ、Edax 4.5.5 nikque.27 以降の libedax を使う場合です。
  - それより前の libedax では、開けなかった book は、壊れた book と同じに扱われていました。edax_runner は空の book に学習を始め、元の `book.dat` を `.damaged` に移していました。
- 同じフォルダーで 2 つ目の edax_runner を起動すると、何もせずに止まります。5.3.0+nikque.10 からです。
  - edax_runner は、動いている間、フォルダーの `edax_runner.lock` をロックします。
- edax_runner を強制終了しても、`book.dat`・`learning_list.txt`・`learned_log.txt` は壊れません。
  - 学習の途中だった行は、次に起動したときに最初から学習します。同時に学習していた棋譜は、その 1 組を最初から学習します。
  - book を保存した直後、`learning_list.txt` を書き換える前に止めた場合は、その行（組）をもう一度学習します。そのため、`learned_log.txt` に 2 回載ることがあります。

### 版

| edax_runner | Edax | |
| :-- | :-- | :-- |
| [5.3.0+nikque.19](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.19) | [4.5.5 nikque.32](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.32) | 終盤の完全読みを速くした libedax の更新 |
| [5.3.0+nikque.18](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.18) | [4.5.5 nikque.31](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.31) | Windows・Linux・macOS 用の libedax を更新 |
| [5.3.0+nikque.17](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.17) | [4.5.5 nikque.30](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.30) | 完全読みの不具合を修正した libedax の更新 |
| [5.3.0+nikque.16](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.16) | [4.5.5 nikque.29](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.29) | libedax の更新（完全読みの直し、book のコマンドを途中から続けられる） |
| [5.3.0+nikque.15](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.15) | [4.5.5 nikque.27](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.27) | 不具合の直し（起動のときに開けない book、学習リスト）と libedax の更新（`edax_book_file_status`） |
| [5.3.0+nikque.14](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.14) | [4.5.5 nikque.26](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.26) | libedax の更新（新しい関数 `edax_book_deviate_export`） |
| [5.3.0+nikque.13](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.13) | [4.5.5 nikque.25](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.25) | libedax の更新 |
| [5.3.0+nikque.12](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.12) | [4.5.5 nikque.23](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.23) | libedax の更新だけ（edax_runner が使う機能の処理は同じ） |
| [5.3.0+nikque.11](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.11) | [4.5.5 nikque.22](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.22) | libedax の更新だけ（edax_runner が使う機能の処理は同じ） |
| [5.3.0+nikque.10](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.10) | [4.5.5 nikque.18](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.18) | 読めなかった book のファイルが置き換えられていた不具合の修正、同じフォルダーの 2 つ目の edax_runner は止まる |
| [5.3.0+nikque.9](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.9) | [4.5.5 nikque.15](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.15) | 学習リストの編集が消えることがあった不具合の修正、学習中のメモリ（Edax の修正） |
| [5.3.0+nikque.8](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.8) | [4.5.5 nikque.14](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.14) | libedax の更新だけ（edax_runner が使う機能の処理は同じ） |
| [5.3.0+nikque.7](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.7) | [4.5.5 nikque.13](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.13) | 80手を超える行を学習できるように（Edax の点検で見つかった不具合の修正） |
| [5.3.0+nikque.6](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.6) | [4.5.5 nikque.12](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.12) | libedax の更新だけ（edax_runner が使う機能の処理は同じ） |
| [5.3.0+nikque.5](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.5) | [4.5.5 nikque.11](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.11) | libedax の更新だけ（edax_runner が使う機能の処理は同じ） |
| [5.3.0+nikque.4](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.4) | [4.5.5 nikque.10](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.10) | 大きな book の `fix` を速く、`[relativeError absoluteError]` の展開を速く（対象の多い周。できる book が少し変わります） |
| [5.3.0+nikque.3](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.3) | [4.5.5 nikque.9](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.9) | 総点検で見つかった不具合の修正（book を保存できなかったことに気づく、複数スレッドの探索、長い行、読めなかった book ファイル） |
| [5.3.0+nikque.2](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.2) | [4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) | 探索する局面が少ないときや level が高いときに速く（level 24 の1局：26秒 → 6〜11秒） |
| [5.3.0+nikque.1](https://github.com/Nikque/edax_runner/releases/tag/v5.3.0-nikque.1) | [4.5.5 nikque.7](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.7) | この fork の最初の版 |

### ソースの変更（開発者向け）

| ファイル | 変更 |
| :-- | :-- |
| `bin/edax_runner.dart` | ライブラリの選択、`config.ini`、複数の棋譜の同時学習、上の修正 |
| `lib/learning_list.dart`（新規） | `learning_list.txt` をバイト列のまま読み書きする処理 |
| `test/learning_list_test.dart`（新規） | そのテスト |
| `resources/dll/` | Edax 4.5.5 (nikque) の libedax：Windows 3個、Linux 3個、Mac 1個 |
| `resources/config.ini`（新規）、`resources/edax.ini`（削除） | 設定 |
| `scripts/build_edax_runner.sh`、`.github/workflows/` | OS ごとのライブラリを全部同梱する。Release は手動で作る（`Create Release`） |

## 参考

- [edax-reversi](https://github.com/abulmo/edax-reversi)
  - [コードと配布物のアーカイブ](https://code.google.com/archive/p/edax-reversi/downloads)
  - [Web サイトのアーカイブ](https://archive.is/KshiN)
  - [ドキュメント](https://sensuikan1973.github.io/edax-reversi/)
- [libedax4dart](https://pub.dev/packages/libedax4dart)
- [Edax_AutoLearning_Tool](https://github.com/sensuikan1973/Edax_AutoLearning_Tool)：元になったツール。**[issues/1](https://github.com/sensuikan1973/Edax_AutoLearning_Tool/issues/1)** を参照。
- [Choirokoitia | Edax](https://choi.lavox.net/edax/start)：edax の詳しい解説（日本語）
