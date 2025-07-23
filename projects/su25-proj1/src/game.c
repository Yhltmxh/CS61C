#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  unsigned int row = 18, col = 20;
  char **board = malloc(row * sizeof(char*));
  char wall[col + 2], space[col + 2];
  for (int i = 0; i < col; i ++) {
    wall[i] = '#';
    if (i == 0 || i == col - 1) {
      space[i] = '#';
    } else {
      space[i] = ' ';
    }
  }
  wall[col] = '\n', wall[col + 1] = '\0';
  space[col] = '\n'; space[col + 1] = '\0';
  for (int i = 0; i < row; i ++) {
    char *source = space; 
    if (i == 0 || i == row - 1) {
      source = wall;
    }
    *(board + i) = strcpy(malloc((col + 2) * sizeof(char)), source);
  }
  snake_t *snake = malloc(sizeof(snake_t));
  snake->tail_row = 2;
  snake->tail_col = 2;
  snake->head_row = 2;
  snake->head_col = 4;
  snake->live = true;

  board[2][9] = '*';
  board[2][2] = 'd', board[2][3] = '>', board[2][4] = 'D';

  game_t *res = malloc(sizeof(game_t));
  res->num_rows = row;
  res->num_snakes = 1;
  res->snakes = snake;
  res->board = board;
  return res;
}

/* Task 2 */
void free_game(game_t *game) {
  if (!game) return;
  char **board = game->board;
  unsigned int row = game->num_rows;
  if (board) {
    for (unsigned int i = 0; i < row; i ++) {
      free(*(board + i));
    }
    free(board);
  }
  if (game->snakes) {
    free(game->snakes);
  }
  free(game);
  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  char **board = game->board;
  unsigned int row = game->num_rows;
  for (int i = 0; i < row; i ++) {
    fprintf(fp, "%s", *(board + i));
  }
  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  char *set = "wasd";
  for (int i = 0; i < 4; i ++) {
    if (set[i] == c) {
      return true;
    }
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  char *set = "WASDx";
  for (int i = 0; i < 5; i ++) {
    if (set[i] == c) {
      return true;
    }
  }
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  char *set = "wasd^<v>WASDx";
  for (int i = 0; i < 14; i ++) {
    if (set[i] == c) {
      return true;
    }
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  char *body = "^<v>", *tail = "wasd";
  for (int i = 0; i < 5; i ++) {
    if (body[i] == c) {
      return tail[i];
    }
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  char *body = "^<v>", *head = "WASD";
  for (int i = 0; i < 5; i ++) {
    if (head[i] == c) {
      return body[i];
    }
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  } else if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  char **board = game->board;
  snake_t snake = (game->snakes)[snum];
  unsigned int row = snake.head_row, col = snake.head_col;
  char head = get_board_at(game, row, col);
  return board[get_next_row(row, head)][get_next_col(col, head)];
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  char **board = game->board;
  snake_t *snake = (game->snakes) + snum;
  unsigned int row = snake->head_row, col = snake->head_col;
  char head = get_board_at(game, row, col);
  unsigned int next_row = get_next_row(row, head), next_col = get_next_col(col, head);
  board[next_row][next_col] = head;
  board[row][col] = head_to_body(head);
  snake->head_row = next_row;
  snake->head_col = next_col;
  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  char **board = game->board;
  snake_t *snake = (game->snakes) + snum;
  unsigned int row = snake->tail_row, col = snake->tail_col;
  char tail = get_board_at(game, row, col);
  unsigned int next_row = get_next_row(row, tail), next_col = get_next_col(col, tail);
  board[next_row][next_col] = body_to_tail(board[next_row][next_col]);
  board[row][col] = ' ';
  snake->tail_row = next_row;
  snake->tail_col = next_col;
  return;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  char **board = game->board;
  snake_t *snakes = game->snakes;
  unsigned int n = game->num_snakes;
  for (unsigned int i = 0; i < n; i ++) {
    snake_t *snake = snakes + i;
    unsigned int row = snake->head_row, col = snake->head_col;
    char next = next_square(game, i);
    if (is_snake(next) || next == '#') {
      board[row][col] = 'x';
      snake->live = false;
    } else if (next == '*') {
      update_head(game, i);
      add_food(game);
    } else {
      update_head(game, i);
      update_tail(game, i);
    }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  unsigned int cap = 24;
  char *res = malloc(cap * sizeof(char));
  if (!res) return NULL;
  size_t offset = 0;
  while (fgets(res + offset, (int) (cap - offset), fp)) {
    size_t len = strlen(res);
    if (strchr(res, '\n')) {
      return res;
    }
    cap *= 2;
    char *tmp = realloc(res, cap * sizeof(char));
    if (!tmp) {
      free(res);
      return NULL;
    }
    res = tmp;
    offset = len;
  }
  if (offset > 0) {
      return res;
  }
  free(res);
  return NULL;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  unsigned int cap = 24;
  char **board = malloc(cap * sizeof(char*));
  char *t = read_line(fp);
  unsigned int row = 0;
  while(t != NULL) {
    if (row == cap) {
      cap *= 2;
      board = realloc(board, cap * sizeof(char*));
    }
    *(board + row) = t;
    t = read_line(fp);
    row ++;
  }
  board = realloc(board, row * sizeof(char*));
  game_t *res = malloc(sizeof(game_t));
  res->num_rows = row;
  res->num_snakes = 0;
  res->snakes = NULL;
  res->board = board;
  return res;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  snake_t *snake = (game->snakes) + snum;
  unsigned int row = snake->tail_row, col = snake->tail_col;
  char c = get_board_at(game, row, col);
  while (!is_head(c)) {
    row = get_next_row(row, c);
    col = get_next_col(col, c);
    c = get_board_at(game, row, col);
  }
  snake->head_row = row;
  snake->head_col = col;
  return;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  char **board = game->board;
  unsigned int row = game->num_rows;
  unsigned int cap = 24;
  snake_t *snakes = malloc(cap * sizeof(snake_t));
  game->snakes = snakes;
  unsigned int cnt = 0;
  for (unsigned int i = 0; i < row; i ++) {
    for (unsigned int j = 0; j < strlen(board[i]); j ++) {
      if (is_tail(board[i][j])) {
        if (cnt == cap) {
          cap *= 2;
          snakes = realloc(snakes, cap * sizeof(snake_t));
        }
        snakes[cnt].tail_row = i;
        snakes[cnt].tail_col = j;
        find_head(game, cnt);
        snakes[cnt].live = true;
        cnt ++;
      }
    }
  }
  game->num_snakes = cnt;
  if (cnt == 0) {
    snakes = NULL;
  } else {
    snakes = realloc(snakes, cnt * sizeof(snake_t));
  }
  return game;
}
