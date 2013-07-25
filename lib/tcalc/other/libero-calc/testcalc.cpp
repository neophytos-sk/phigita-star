#include "prelude.h"
#include "calcul.h"
#include <iostream>

static double function_i (int i   );
static double function_l (long l  );
static double function_d (double d);
static double function_s (char  *s);

static char
    *calc_error [] = 
      {
        "No errors.",
        "Invalid or unrecognised token.",
        "Unexpected end of expression.",
        "Left parenthesis is missing.",
        "Right parenthesis is missing.",
        "Quotes missing after string.",
        "Too many operands in expression.",
        "Too many levels of parentheses in expression.",
        "Number is required here.",
        "String between quotes is required here.",
        "Unknown function name."
      };

int main ()
{
    static Ccalcul
        calcul;
    static char 
        input [80];
    int
        error_posn,                     //  Error position
        feedback;
    double
        result;

    //  Add custom function to object
    calcul.add_function (function_i, "FINT"   );
    calcul.add_function (function_l, "FLONG"  );
    calcul.add_function (function_d, "FDOUBLE");
    calcul.add_function (function_s, "FSTRING");

    cout << "Functions: FINT, FLONG, FDOUBLE, FSTRING" << endl;
    FOREVER
      {
        cout << "==> ";
        cin.getline (input, 80);

        if (strlen (input) == 0)
            break;

        feedback = calcul.calculate (input , &result, &error_posn);

        if (feedback) 
          {
            printf ("    %*c\n", error_posn + 1, '^');
            cout << calc_error [feedback] << endl;
          }
        else
            cout << "Result is: " << result << endl;
      }

	return 0;
}

static double function_i (int i)
{
    return (i - 1);
}

static double function_l (long l)
{
    return (l - 2);
}

static double function_d (double d)
{
    return (d - 3);
}

static double function_s (char *s)
{
    return (strlen (s));
}

