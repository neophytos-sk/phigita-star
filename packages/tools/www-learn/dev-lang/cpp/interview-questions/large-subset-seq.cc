Here's a in-place algorithm with O(n) time and O(1) extra-space
Given array 'A' of size 'n', the goal is to reorder elements in the given array so that they are in their correct positions i.e. A[i]-min(A) is at A[0] when A[i]==min(A)
and A[j]-min(A) is at A[1] if A[j] = min(A)+1
and A[k]-min(A) is at A[2] if A[k] = min(A)+2 ..... so on....



1. Pass1: Find max(A) and min(A)
if ( max(A)-min(A) > n ) then return false //i.e. you cannot have a sequence greater than n
2. Pass2: For every element 'i',
a. if A[i] == A[A[i]-min(A)] //already at the right position
if A[i] != A[min(A)+i] then set A[i]=-Inf //this is a duplicate
else continue next iteration
b. else //swap to move it to the right position
swap A[i] with A[A[i]-min(A)]
after swapping if A[i] != min(A)+i repeat from step 'a'
3. Pass3: For every element 'i', check if next element == A[i]+1,
if not then return false.


An example with duplicates: {45,50,47,45,50,46,49,48,49}
Pass1: max(A) = 50, min(A) = 45
Pass2: modified Array:
[45,50,47,45,50,46,49,48,49] //45 already at A[A[0]-min(A)]
[45,46,47,45,50,50,49,48,49] //swap 50 & 46
[45,46,47,45,50,50,49,48,49] //47 already at A[47-45]
[45,46,47,-Inf,50,50,49,48,49] //A[3] = -Inf since it is a duplicate
[45,46,47,-Inf,-Inf,50,49,48,49]
[45,46,47,-Inf,-Inf,50,49,48,49]
[45,46,47,-Inf,49,50,-Inf,48,49]
[45,46,47,48,49,50,-Inf,-Inf,49]
[45,46,47,48,49,50,-Inf,-Inf,-Inf]
Pass3: return true

//Note : instead of -Inf you can use some other marker such as min(A)-2
