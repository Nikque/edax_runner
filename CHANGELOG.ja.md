# 変更履歴（この fork の版）

[English](CHANGELOG.md)

この fork（[Nikque/edax_runner](https://github.com/Nikque/edax_runner)）の版だけを日本語で載せています。元の edax_runner の履歴（5.3.0 以前）は [CHANGELOG.md](CHANGELOG.md) にあります。

## 5.3.0+nikque.2

タグは `v5.3.0-nikque.2` です。

- libedax と `config.ini` を [Edax 4.5.5 nikque.8](https://github.com/Nikque/edax-reversi-AVX/releases/tag/v4.5.5-nikque.8) のものにしました。
  - 修正：`book-store-tasks = auto`（既定）のとき、探索する局面が少ない場合や level が高い場合に、`1` より遅くなっていました（1局の学習が、level 24 で13秒のところ26秒、level 21 で4.2秒のところ6.4秒）。同時に行う探索の間でスレッドを分け合うようにし、level 24 で6〜11秒、level 21 で2.0秒になりました。level 18 で1局ずつ30局の学習は、29秒から18秒になりました（`1` では35秒）。（edax のコマンドで測った値です）
  - level 18 の棋譜128本（論理 CPU 32）：37〜39秒 → 35〜36秒。

## 5.3.0+nikque.1

この fork の最初の版です（元は [sensuikan1973/edax_runner](https://github.com/sensuikan1973/edax_runner) の 5.3.0）。タグは `v5.3.0-nikque.1` です。

- edax を、Edax 4.4 から [Edax 4.5.5 (nikque)](https://github.com/Nikque/edax-reversi-AVX) に替えました（libedax の関数は元のものと同じです）。
- libedax を CPU の世代ごと（x86-64 共通、AVX2、AVX-512）にビルドし、edax_runner が、CPU が動かせる中で最も速いものを使うようにしました（Windows、Linux）。
- 設定を、`edax.ini` から Edax 4.5.5 (nikque) の `config.ini` に替えました（`edax.ini` も読みますが、`config.ini` が優先です）。
- `config.ini` の `book-store-tasks` で、複数の棋譜を同時に学習するようにしました（既定の `auto` は `n-tasks` と同じ数。`1` は従来どおり1局ずつ）。
  - `learning_list.txt` の次の「Edax 対 Edax」の行を `book-store-tasks` の数まで同時に対局し、その局面を同時に探索して book に入れます（libedax の `edax_book_store_games` を `dart:ffi` で呼びます）。
  - `learning_list.txt` と `learned_log.txt` は、その組につき1回更新します。
- 修正：`learning_list.txt` に空行があると edax_runner が止まっていました。無視するようにしました。
- 修正：学習できない行（書式が違う、打てない手がある）が、学習済みとして消されていました。警告を出して飛ばし、`learned_log.txt` にコメントとして記録するようにしました。
  - edax は打てない手とその後の手を無視するので、意図しない局面から学習していました。
- 修正：`learning_list.txt` に UTF-8 でないコメント（Shift_JIS など）があると、edax_runner が異常終了していました。
- 修正：`learning_list.txt` の改行コード（CRLF）が LF に書き換えられていました。
- 修正：学習中に `learning_list.txt` を書き換えると、学習した行ではない別の行が消されていました。
- 修正：`fix` の直後に book が保存されていませんでした。
- 修正：`exit` が `learning_list.txt` から消えないので、書き換えないと edax_runner を再開できませんでした。
- 修正：保存中に edax_runner を強制終了すると、`book.dat` や `learning_list.txt` が壊れることがありました。別のファイルに保存してから置き換えるようにしました（`book.dat` は edax が行います）。
- `[0 0]F5F6`、`[ 0 0 ] F5F6`、`2, F5F6` のような書き方を受け付けるようにしました。
- `learning_list.txt` が作業フォルダにないときは、実行ファイルのあるフォルダを使うようにしました。
- `learning_list.txt` の処理を速くし、メモリも少なくしました（バイト列のまま扱い、1行学習するごとに1回だけ読みます）。
