package recfun
import common._

object Main {
  def main(args: Array[String]) {
    println("Pascal's Triangle")
    for (row <- 0 to 10) {
      for (col <- 0 to row)
        print(pascal(col, row) + " ")
      println()
    }
  }

  /**
   * Exercise 1
   */
  def pascal(c: Int, r: Int): Int = if (c==0 || c==r) 1 else pascal(c,r-1)+pascal(c-1,r-1);

  /**
   * Exercise 2
   */

  def balance(chars: List[Char]): Boolean = {
    def isOpen(char: Char): Boolean = char=='(';

    def isClose(char: Char): Boolean = char==')';

    def isBalanced(chars: List[Char], stack: List[Char]): Boolean = {

       if (chars.isEmpty)
         stack.isEmpty
       else if (isOpen(chars.head))
         isBalanced(chars.tail, chars.head :: stack)
       else if (isClose(chars.head)) 
         !stack.isEmpty && isOpen(stack.head) && isBalanced(chars.tail,stack.tail)
       else 
         isBalanced(chars.tail,stack);

     }

     isBalanced(chars,Nil);
  }


  /**
   * Exercise 3
   */
  def countChange(money: Int, coins: List[Int]): Int = {
      if (money == 0)
      	1
      else if (money < 0 || coins.isEmpty) 
        0
      else
        if (money >= coins.head) 
          countChange(money - coins.head, coins) + countChange(money,coins.tail)
        else
          countChange(money,coins.tail)
  }

}
