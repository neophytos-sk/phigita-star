function code=Vigenere(message,key,alphabet)

  % message - text to be encrypted
  % key - key for encryption and decryption
  % alphabet - alphabet for valid characters
  % code - encrypted or decrypted message depending on the sign of key

  code = "";

  length_of_msg = length(message);
  length_of_key = length(key);
  length_of_alphabet = length(alphabet);

  % If first character of the given key is positive, 
  % then encrypt. Otherwise, decrypt.

  sign = 1;
  if key(1) < 0
    sign = -1;
    key = char(-key);
  endif

  for i = 1:length_of_msg

    % figure out index of character in key
    k = 1 + mod(i-1, length_of_key);

    % find pos of msg letter in alphabet, -1 because of modulo below
    pos_of_letter_in_msg = index(alphabet, message(i)) - 1;

    % find pos of key letter in alphabet, -1 because of modulo below
    pos_of_letter_in_key = sign * (index(alphabet, key(k)) - 1);

    % add positions of character i of row 2 and 4
    shift = pos_of_letter_in_msg + pos_of_letter_in_key;

    % wrap (take modulo alphabet length)
    code(i) = alphabet(1 + mod(shift, length_of_alphabet));

  endfor
