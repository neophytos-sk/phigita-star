/*
 * Functions for logging.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _LOG_H
#define _LOG_H 1

void log_level(int);
void log_add(int, char *, ...);
void log_dump(char *);
void log_errdump(char *);
void log_free(void);

#endif /* _LOG_H */

/* EOF */
