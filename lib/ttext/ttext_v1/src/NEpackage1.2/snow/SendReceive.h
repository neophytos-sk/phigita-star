// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: SendReceive.h                                 =
//=  Version: 3.1.4                                         =
//=  Authors: Nick Rizzolo                                  =
//=     Date: 8/24/01                                       = 
//=                                                         =
//= Comments: Sends the size of the data in bytes before    =
//=           sending the actual data.  Expects the same in =
//=           in return.  The size variable is a 4 byte,    =
//=           big-endian (network standard) integer.        =
//=           As of 7/5/02, the handle_recv_error()         =
//=           function is lacking (although I've never run  =
//=           into problems).  If anyone would like to make =
//=           it better, feel free.                         =
//===========================================================

#ifndef SEND_AND_RECEIVE_
#define SEND_AND_RECEIVE_

//#define VERBOSE

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <ctype.h>
#include <errno.h>

int send_bytes( int socket, char* message, int length, int flags );
int receive_bytes( int socket, char* &message, int flags );
int handle_recv_error();


unsigned char __little_endian(2);

 /*****
  * resolve_endianness() reverses the byte order of its parameter n if the
  *   machine this code is compiled on is little endian.
 **/
void resolve_endianness(int& n)
{
  int i;
  if (__little_endian == 2)
  {
    i = 1;
    __little_endian = *((char*) &i);
  }

  if (__little_endian == 1)
  {
    n = ((n >>  8) & 0x00FF00FF) | ((n <<  8) & 0xFF00FF00);
    n = ((n >> 16) & 0x0000FFFF) | ((n << 16) & 0xFFFF0000);
  }
}

 /*****
  * send_bytes() is an interface to the send() function that first sends the
  *   length of the message to the socket as an integer, so that the other
  *   party knows how much data to expect.
  *
  * parameters: same as send()
  * returns:    same as send()
 **/

int send_bytes( int socket, char* message, int length, int flags )
{
  resolve_endianness(length);
  send(socket, &length, 4, flags);
  resolve_endianness(length);

#ifdef VERBOSE
  cout << "\nSending " << length << " bytes.\n";
#endif

  return send(socket, message, length, flags);
}


 /*****
  * receive_bytes() is an interface to the recv() function that first receives
  *   the length of the message that it expects to receive next.  It then
  *   executes recv() in a loop while the entire expected message has not yet
  *   been received.
  *
  * parameters:
  *   - int socket:    The connected socket to receive from.
  *   - char* message: The buffer into which data should be received.
  *   - int flags:     See the recv() man page.
  *
  * returns:    same as recv()
 **/

int receive_bytes( int socket, char* &message, int flags )
{
  int temp;
  struct
  {
    int received;
    union
    {
      int length;
      char buffer;
    } expected;
  } incoming;

  int i;
  if (__little_endian == 2)
  {
    i = 1;
    __little_endian = *((char*) &i);
  }

  incoming.received = 0;
  do
  {
    temp = recv(socket, &incoming.expected.buffer + incoming.received,
                sizeof(int) - incoming.received, flags);
    if (temp == -1 && handle_recv_error() == -1) return -1;
    incoming.received += temp;
  } while (incoming.received < sizeof(int));

  if (incoming.expected.length == 0) return 0;
  resolve_endianness(incoming.expected.length);

  incoming.received = temp = 0;

  /*
  while (temp < 1)
  { 
    temp = recv(socket, message, 1, flags);
    if (temp == -1 && handle_recv_error() == -1) return -1;
  }

  if (message[0] == '\0') --incoming.expected.length;
  else ++incoming.received;
  */

#ifdef VERBOSE
  cout << "\nExpecting " << incoming.expected.length
       << " bytes in message.\n";
#endif

  message = new char[incoming.expected.length + 1];
  message[incoming.expected.length] = '\0';

  while (incoming.received < incoming.expected.length)
  {
    temp = recv(socket, message + incoming.received,
                incoming.expected.length - incoming.received, flags);
    if (temp == -1 && handle_recv_error() == -1) return -1;
    incoming.received += temp;
  }

#ifdef VERBOSE
  cout << "Received " << incoming.received << " bytes.\n\n";
#endif

  return incoming.received;
}


int handle_recv_error()
{
  char* first_part = "recv error #";
  char* message = new char[20];
  sprintf(message, "%s%d", first_part, errno);

  switch (errno)
  {
    case EBADF:
    case EINTR:
    case EIO:
    case ENOMEM:
    case ENOSR:
    case ENOTSOCK:
    case ESTALE:
    case EWOULDBLOCK: break;
    case 2: cout << "Bad address\n"; return 0;
    default: cout << "unknown error\n";
  }

  perror(message);
  return -1;
}


#endif

