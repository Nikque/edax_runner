#include "libedax.h"
#include <stdio.h>

int main(void)
{
    char *args[] = {"train", "-book-file", "synthetic-book.dat", "-level", "10", "-n-tasks", "1"};
    LibedaxBenchResult result = {0};
    libedax_initialize(7, args);
    edax_bench(&result, 20);
    if (result.positions != 20 || !result.n_nodes) return 1;
    edax_book_off();
    for (int game = 0; game < 2; ++game) {
        LibedaxBoard board;
        edax_new();
        for (int turn = 0; turn < 124; ++turn) {
            edax_get_board(&board);
            if (!get_moves(board.player, board.opponent) && !get_moves(board.opponent, board.player)) break;
            if (turn % 12 == 0) {
                LibedaxHintList hints;
                edax_hint(2, &hints);
            }
            edax_go();
        }
        edax_get_board(&board);
        if (get_moves(board.player, board.opponent) || get_moves(board.opponent, board.player)) return 2;
        printf("Game %d completed with %d discs\n", game + 1, bit_count(board.player | board.opponent));
    }
    libedax_terminate();
    return 0;
}
