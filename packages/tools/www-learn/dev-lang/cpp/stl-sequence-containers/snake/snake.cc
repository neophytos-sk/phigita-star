#include <iostream>
#include <string>
#include <deque>
#include <vector>
#include <fstream>
#include <ctime>
#include <cstdlib>

using namespace std;

/* Number of food pellets that must be eaten to win. */
const int kMaxFood = 20;

/* Constants for the different tile types. */
const char kEmptyTile = ' ';
const char kWallTile = '#';
const char kFoodTile = '$';
const char kSnakeTile = '*';

/* A struct encoding a point in a two-dimensional grid. */
struct pointT {
  int row,col;
};

/* A struct containing relevant game information. */
struct gameT {
  vector<string> world; // The playing field
  int numRows, numCols; // Size of the playing field

  deque<pointT> snake;  // The snake body
  int dx,dy;            // The snake direction

  int numEaten;         // How much food we've eaten.
};

string GetLine() {
  string result;
  getline(cin,result);
  return result;
}

pointT MakePoint(int row, int col) {
      pointT result;
      result.row = row;
      result.col = col;
      return result;
}



void LoadWorld (gameT& game, ifstream& input) {
  input >> game.numRows >> game.numCols;
  game.world.resize(game.numRows);

  input >> game.dx >> game.dy;

  // getline does not mix well with the stream extraction operator
  // the first call to getline after using the stream extration operator will
  // return the empty string because the newline character delimiting the data
  // is still waiting to be read. To prevent this from gumming up the rest of
  // our input operations, we'll call getline here on a dummy string to flush
  // out the remaining newline
  string dummy;
  getline(input, dummy);

  for (int row=0; row< game.numRows; ++row) {
    getline(input, game.world[row]);
    int col = game.world[row].find(kSnakeTile);
    if (col != string::npos) {
      game.snake.push_back(MakePoint(row,col));
    }
  }
  
  game.numEaten = 0;

}

void OpenUserFile(ifstream& input) {
  while(true) {
    cout << "Enter filename: ";
    string filename = GetLine();
    
    input.open(filename.c_str()); // See Chapter 3 for info on .c_str()
    if (input.is_open()) break;

    cout << "Sorry, I can't find the file " << filename << '\n';
    input.clear();
  }
} 

bool RandomChance(double probability) {
  return static_cast<double>(rand() / (RAND_MAX + 1.0)) < probability;
}

void InitializeGame(gameT& game) {

  /* Seed the randomizer. The static_cast converts the result of time(NULL)
   * from time_t to the unsigned int required by srand. This line is 
   * idiomatic C++.
   */
  srand(static_cast<unsigned int>(time(NULL)));

  ifstream input;
  OpenUserFile(input);
  LoadWorld(game,input);
}

/* Stops for a short period of time to make the game seem more fluid. */
const double kWaitTime = 0.1; // Pause 0.1 seconds between frames
void Pause() {
  // We use a busy loop, a while loop that does nothing until enough
  // time has elapsed. Busy loops are frowned upon in professional code
  // because the waste CPU power, but for our purposes are perfectly acceptable.
  
  clock_t startTime = clock(); // clock_t is a type which holds clock ticks.

  /* This loop does nothing except loop and check how much time is left.
   * Note that we have to typecast startTime from clock_t to double so
   * that the division is correct. The static_cast<double>(...) syntax
   * is the preferred C++ way of performing a typecast of this sort;
   * see the chapter on inheritance for more information.
   */

  while(static_cast<double>(clock() - startTime) / CLOCKS_PER_SEC < kWaitTime);
}


/* The string used to clear the display before printing the game board.
 * Windows systems should "CLS"; Mac OS X or Linux users should use
 * "clear" instead.
 */
const string kClearCommand = "clear";

void PrintWorld(gameT& game) {
  system(kClearCommand.c_str());
  for (int row = 0; row < game.numRows; ++row)
    cout << game.world[row] << '\n';
  cout << "Food eaten: " << game.numEaten << '\n';
}

// Called after the game has ended to report whether the computer won or lost.
void DisplayResult(gameT& game) {
  PrintWorld(game);
  if(game.numEaten == kMaxFood)
    cout << "The snake ate enough food and wins!" << '\n';
  else
    cout << "Oh no! The snake crashed!" << '\n';
}

pointT GetNextPosition(gameT& game, int dx, int dy) {

  /* Get the head position. */
  pointT result = game.snake.front();
  
  /* Increment the head position by the current direction. */
  result.row += dy;
  result.col += dx;

  return result;
}

bool InWorld(pointT pt, gameT& game) {
  return pt.col >= 0 &&
    pt.row >= 0 &&
    pt.col < game.numCols &&
    pt.row < game.numRows;
}

bool Crashed(pointT headPos, gameT& game) {
  return !InWorld(headPos, game) || 
    game.world[headPos.row][headPos.col] == kSnakeTile ||
    game.world[headPos.row][headPos.col] == kWallTile;
}

const double kTurnRate = 0.2; // 20% chance to turn each step.
void PerformAI(gameT& game) {
  /* Figure out where we will be after we move this turn. */
  pointT nextHead = GetNextPosition(game, game.dx, game.dy);

  /* If that hits a wall or we randomly decide to, turn the snake. */
  if(Crashed(nextHead, game) || RandomChance(kTurnRate)) {
    int leftDx = -game.dy;
    int leftDy = game.dx;

    int rightDx = game.dy;
    int rightDy = -game.dx;

    /* Check if turning left or right will cause to crash. */
    bool canLeft = !Crashed(GetNextPosition(game, leftDx, leftDy),game);
    bool canRight = !Crashed(GetNextPosition(game, rightDx, rightDy),game);

    bool willTurnLeft = false;
    if(!canLeft && !canRight)
      return; // If we can't turn, don't turn
    else if(canLeft && !canRight)
      willTurnLeft = true; // If we must turn left, do so.
    else if (!canLeft && canRight)
      willTurnLeft = false; // If we must turn right, do so.
    else
      willTurnLeft = RandomChance(0.5); // Else pick randomly

    game.dx = willTurnLeft? leftDx : rightDx;
    game.dy = willTurnLeft? leftDy : rightDy;
  }
}

void PlaceFood(gameT& game) {
  while(true) {
    int row = rand() % game.numRows;
    int col = rand() % game.numCols;

    /* If the specified position is empty, place the food there. */
    if(game.world[row][col] == kEmptyTile) {
      game.world[row][col] = kFoodTile;
      return;
    }
  }
}

bool MoveSnake(gameT& game) {
  pointT nextHead = GetNextPosition(game, game.dx, game.dy);
  if(Crashed(nextHead, game))
    return false;

  bool isFood = (game.world[nextHead.row][nextHead.col] == kFoodTile);

  game.world[nextHead.row][nextHead.col] = kSnakeTile;
  game.snake.push_front(nextHead);

  if(!isFood) {
    game.world[game.snake.back().row][game.snake.back().col] = kEmptyTile;
    game.snake.pop_back();
  } else {
    ++game.numEaten;
    PlaceFood(game);
  }

  return true;
}

void RunSimulation(gameT& game) {
  /* Keep looping while we haven't eaten too much. */
  while(game.numEaten < kMaxFood) {
    PrintWorld(game);     // Display the board
    PerformAI(game);      // Have the AI choose an action

    if (!MoveSnake(game)) // Move the snake and stop if we crashed
      break;

    Pause();
  }
  DisplayResult(game);    // Tell the user what happened
}

/* The main program. Initializes the world, then runs the simulation. */
int main() {
  gameT game;
  InitializeGame(game);
  RunSimulation(game);
  return 0;
}
