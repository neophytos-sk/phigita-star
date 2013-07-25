#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int isCusipValid(const char *);

int
main(int argc, char *argv[])
{
    int i;

    if (argc < 2) {
        fprintf(stderr, "Usage: validate_cusip <cusip>\n");
        return 1;
    }

    for (i = 1; i < argc; ++i)
        printf("CUSIP '%s' is %svalid\n", argv[i], isCusipValid(argv[i]) ? "" : "in");

    return 0;
}

static int
isCusipValid(const char *cusip)
{
    int d, sum, multiply, i;

    if (!cusip || strlen(cusip) != 9 || !isdigit(cusip[8]))
        return 0;

    for (sum = 0, multiply = 1, i = 7; i > -1; --i) {
        if (i < 3) {
            if (isdigit(cusip[i]))
                d = cusip[i] - '0';
            else
                return 0;
        } else {
            if (isupper(cusip[i]))
                d = cusip[i] - 'A' + 10;
            else if (isdigit(cusip[i]))
                d = cusip[i] - '0';
            else
                return 0;
        }

        if (multiply)
            d *= 2;
        multiply = !multiply;
        sum += (d / 10) + (d % 10); 
    }

    sum %= 10;
    sum = 10 - sum;
    sum %= 10;

    if (sum != cusip[8] - '0')
        return 0;

    return 1;
}
