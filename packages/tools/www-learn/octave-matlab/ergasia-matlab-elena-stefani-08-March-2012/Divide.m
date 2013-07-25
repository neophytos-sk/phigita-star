function [q,r]=Divide(x,y)

  q = [];

  r = 0;

  found_first_nonzero_digit = 0;

  i = 1;

  while i <= length(x)

    % add i-th element (digit) of vector x to r
    r = r * 10 + x(i);

    % check whether r is big enough to divide by y
    if r >= y

      % how many times does y go into r
      num_times_y_in_r = floor(r / y);

      % new remainder
      r = r - num_times_y_in_r * y;

      % we have found the first non-zero digit of the quotient
      found_first_nonzero_digit = 1;

    else 

      % y is greater than r
      num_times_y_in_r = 0;

    endif

    % ignore leading zeros
    if found_first_nonzero_digit == 1

      q(end+1) = num_times_y_in_r;

    endif

    i = i + 1;

  endwhile


