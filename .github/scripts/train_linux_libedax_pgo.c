#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "libedax.h"

static int test_endgames(const char *path)
{
    FILE *input = fopen(path, "r");
    if (!input) return 0;
    int checked = 0;
    char line[1024];
    while (fgets(line, sizeof line, input)) {
        char *board_end = strchr(line, ';');
        if (!board_end) break;
        *board_end = '\0';
        int scores[64], best_score = INT_MIN;
        for (int i = 0; i < 64; ++i) scores[i] = INT_MIN;
        for (char *token = strtok(board_end + 1, ";"); token; token = strtok(NULL, ";")) {
            char col = 0, row = 0;
            int score = 0;
            if (sscanf(token, " %c%c:%d", &col, &row, &score) != 3) continue;
            col = (char) toupper((unsigned char) col);
            if (col < 'A' || col > 'H' || row < '1' || row > '8') continue;
            scores[(row - '1') * 8 + col - 'A'] = score;
            if (score > best_score) best_score = score;
        }

        edax_setboard(line);
        LibedaxHintList result;
        edax_hint(1, &result);
        if (result.n_hints != 1) break;
        const LibedaxHint *hint = &result.hint[1];
        if (hint->move < 0 || hint->move >= 64 || hint->book_move ||
            best_score == INT_MIN || scores[hint->move] != best_score || hint->score != best_score) {
            fprintf(stderr, "Position %d: move %d, score %d, expected %d\n",
                    checked + 1, hint->move, hint->score, best_score);
            break;
        }
        ++checked;
    }
    fclose(input);
    return checked;
}

int main(int argc, char **argv)
{
    if (argc != 2) return EXIT_FAILURE;
    char *options[] = {"", "-n-tasks", "1", "-level", "60", "-book-file", "pgo-synthetic.dat"};
    libedax_initialize((int) (sizeof options / sizeof options[0]), options);
    edax_book_off();
    int checked = test_endgames(argv[1]);
    printf("FFI endgames: %d exact scores and best moves\n", checked);

    edax_set_option("level", "12");
    int finished = 0;
    for (int game = 0; game < 2; ++game) {
        edax_init();
        for (int turn = 0; turn < 130 && !edax_is_game_over(); ++turn) edax_go();
        finished += (edax_is_game_over() != 0);
    }
    printf("FFI self-play: %d complete games\n", finished);
    libedax_terminate();
    return checked == 19 && finished == 2 ? EXIT_SUCCESS : EXIT_FAILURE;
}
