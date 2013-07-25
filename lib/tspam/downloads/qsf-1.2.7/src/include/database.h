/*
 * Database handling prototypes, structures, and constants.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#ifndef _DATABASE_H
#define _DATABASE_H 1

typedef enum {
	QDB_NEW,
	QDB_READONLY,
	QDB_READWRITE
} qdb_open_t;

struct qdb_s;
typedef struct qdb_s *qdb_t;
struct qdbint_s;
typedef struct qdbint_s *qdbint_t;

typedef struct {
	unsigned char *data;
	int size;
} qdb_datum;

qdb_t qdb_open(const char *, qdb_open_t);
int qdb_fd(qdb_t);
char *qdb_type(qdb_t);
void qdb_close(qdb_t);

qdb_datum qdb_fetch(qdb_t, qdb_datum);
int qdb_store(qdb_t, qdb_datum, qdb_datum);
int qdb_delete(qdb_t, qdb_datum);

qdb_datum qdb_firstkey(qdb_t);
qdb_datum qdb_nextkey(qdb_t, qdb_datum);

void qdb_optimise(qdb_t);

char *qdb_error(void);

void qdb_unlock(qdb_t);
void qdb_relock(qdb_t);

void qdb_restore_start(qdb_t);
void qdb_restore_end(qdb_t);

/*
 * Common library functions for backends to use.
 */
int qdb_int__lock(int, int, int *);
void qdb_int__sig_block(void);
void qdb_int__sig_unblock(void);

#endif /* _DATABASE_H */

/* EOF */
