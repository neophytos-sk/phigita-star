#ifndef COMMANDS_H
#define COMMANDS_H

struct commands {
  char *verb;
  void (*action)();
  void (*flush)();
} ;

extern int commands();

#endif
