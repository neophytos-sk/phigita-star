/*
 * Logging functions.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "log.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

static int _log_level = 0;
static int _log_lines = 0;
static char **_log_array = 0;


/*
 * Set the logging level (0 is off).
 */
void log_level(int level)
{
	_log_level = level;
}


/*
 * Add a log message to the queue, if logging is enabled with a level
 * greater than or equal to "level" (i.e. level 1 is highest priority, then
 * level 2, and so on).
 */
void log_add(int level, char *format, ...)
{
	char buf[8192];			 /* RATS: ignore (checked OK - ish) */
	va_list ap;
	char **ptr;
	int sz;

	if (_log_level < level)
		return;

	va_start(ap, format);

	buf[0] = 0;

#ifdef HAVE_VSNPRINTF
	vsnprintf(buf, sizeof(buf), format, ap);
#else
	vsprintf(buf, format, ap);	    /* RATS: ignore (unavoidable) */
#endif

	va_end(ap);

	if (_log_array == 0) {
		ptr = (char **) malloc(sizeof(char *) * (_log_lines + 1));
	} else {
		ptr = (char **) realloc(_log_array,	/* RATS: ignore */
					sizeof(char *) * (_log_lines + 1));
	}

	if (ptr == 0)
		return;

	sz = strlen(buf) + 1;
	_log_array = ptr;
	_log_array[_log_lines] = malloc(sz);
	if (_log_array[_log_lines] == 0)
		return;
	memcpy(_log_array[_log_lines], buf, sz);	/* RATS: ignore (checked) */
	_log_lines++;
}


/*
 * Dump out all log messages, with the given prefix before each line.
 */
void log_dump(char *prefix)
{
	int i;

	if (_log_array == 0)
		return;

	for (i = 0; i < _log_lines; i++) {
		if (_log_array[i] == 0)
			continue;
		printf("%s%s\n", prefix, _log_array[i]);
	}
}


/*
 * Dump out all log messages, with the given prefix plus ": " before each
 * line, to stderr.
 */
void log_errdump(char *prefix)
{
	int i;

	if (_log_array == 0)
		return;

	for (i = 0; i < _log_lines; i++) {
		if (_log_array[i] == 0)
			continue;
		fprintf(stderr, "%s: %s\n", prefix, _log_array[i]);
	}
}


/*
 * Free all memory used by this logging system.
 */
void log_free(void)
{
	int i;

	if (_log_array == 0)
		return;

	for (i = 0; i < _log_lines; i++) {
		if (_log_array[i] == 0)
			continue;
		free(_log_array[i]);
		_log_array[i] = 0;
	}

	free(_log_array);

	_log_array = 0;
	_log_lines = 0;
}

/* EOF */
