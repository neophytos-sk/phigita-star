/* Copyright 2010 Stanford University CS106l */

#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <set>

using std::set;

unsigned int seedTmp = time(NULL);

/* Rolls a six-sided die and returns the number that came up. */
int DieRoll() {
  /* rand_r() % 6 gives back a value between 0 and 5, inclusive. Adding one to
   * this gives us a valid number for a die roll.
   */

  /* cpplint.py: Consider using rand_r(...) instead of rand(...) for improved 
   * thread safety.  [runtime/threadsafe_fn] [2] 
   */
  return (rand_r(&seedTmp) % 6) + 1;
}

/* Rolls the dice until a number appears twice, then reports the number of die
 * rolls.
 */
size_t RunProcess() {
  set<int> generated;

  while (true) {
    /* Roll the die. */
    int nextValue = DieRoll();

    /* See if this value has come up before. If so, return the number of
     * rolls required. This is equal to the number of dice that have been
     * rolled up to this point, plus one for this new roll.
     */
    if (generated.count(nextValue))
      return generated.size() + 1;

    /* Otherwise, remember this die roll. */
    generated.insert(nextValue);
  }
}


const size_t kNumIterations = 10000;  // Number of iterations to run

int main() {
  /* Seed the randomizer. See the last chapter for more information on this
   * line.
   */
  srand(static_cast<unsigned>(time(NULL)));

  size_t total = 0;  // Total number of dice rolled

  /* Run the process kNumIterations times, accumulating the result into
   * total.
   */
  for (size_t k = 0; k < kNumIterations; ++k)
    total += RunProcess();

  /* Finally, report the result. */
  printf("Average number of steps: %f\n",
         static_cast<double>(total) / kNumIterations);

  return 0;
}
