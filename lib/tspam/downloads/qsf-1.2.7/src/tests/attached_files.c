/*
 * Rules which add tokens if a message attachment's filename matches various
 * patterns.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include <string.h>

#define DISPOSITION_HEADER "\nContent-Disposition:"


extern char *minimemmem(char *, long, char *, long);


/*
 * Return the number of times an attachment with the given filename
 * extension (eg "scr", "pif", "exe") was found.
 */
static int spam_test_attachment__scan(msg_t msg, char *extension)
{
	long pos, lastdot;
	int nfound = 0;

	pos = 0;

	while (pos < msg->body_size) {
		int quotes;
		char *ptr;

		ptr =
		    minimemmem(msg->body + pos, msg->body_size - pos,
			       DISPOSITION_HEADER,
			       strlen(DISPOSITION_HEADER));

		if (ptr == 0)
			return nfound;

		pos = ptr - msg->body;
		pos += strlen(DISPOSITION_HEADER);

		while ((pos < msg->body_size)
		       && ((msg->body[pos] == ' ')
			   || (msg->body[pos] == '\t')
		       )
		    ) {
			pos++;
		}

		if (pos >= (msg->body_size - 12))
			return nfound;

		if (strncasecmp(msg->body + pos, "attachment;", 11) != 0)
			continue;

		pos += 11;

		while ((pos < msg->body_size)
		       && ((msg->body[pos] == ' ')
			   || (msg->body[pos] == '\t')
			   || (msg->body[pos] == '\r')
			   || (msg->body[pos] == '\n')
		       )
		    ) {
			pos++;
		}

		if (pos >= (msg->body_size - 15))
			return nfound;

		if (strncasecmp(msg->body + pos, "filename=", 9) != 0)
			continue;

		pos += 9;
		quotes = 0;

		if (msg->body[pos] == '"') {
			quotes = 1;
			pos++;
		}

		lastdot = 0;

		if (quotes) {
			while ((pos < msg->body_size)
			       && (msg->body[pos] != '"')
			       && (msg->body[pos] != '\r')
			       && (msg->body[pos] != '\n')
			    ) {
				if (msg->body[pos] == '.')
					lastdot = pos;
				pos++;
			}
		} else {
			while ((pos < msg->body_size)
			       && (msg->body[pos] != ';')
			       && (msg->body[pos] != ' ')
			       && (msg->body[pos] != '"')
			       && (msg->body[pos] != '\t')
			       && (msg->body[pos] != '\r')
			       && (msg->body[pos] != '\n')
			    ) {
				if (msg->body[pos] == '.')
					lastdot = pos;
				pos++;
			}
		}

		if (lastdot == 0)
			continue;

		if (pos >= (msg->body_size - 2))
			return nfound;

		lastdot++;

		if (strlen(extension) != (pos - lastdot))
			continue;

		if (strncasecmp
		    (msg->body + lastdot, extension, pos - lastdot) == 0)
			nfound++;
	}

	return nfound;
}


/*
 * Add a token for every attachment with the filename "something.scr".
 */
int spam_test_attachment_scr(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "scr");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.pif".
 */
int spam_test_attachment_pif(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "pif");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.exe".
 */
int spam_test_attachment_exe(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "exe");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.vbs".
 */
int spam_test_attachment_vbs(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "vbs");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.vba".
 */
int spam_test_attachment_vba(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "vba");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.lnk".
 */
int spam_test_attachment_lnk(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "lnk");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.com".
 */
int spam_test_attachment_com(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "com");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.bat".
 */
int spam_test_attachment_bat(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "bat");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.pdf".
 */
int spam_test_attachment_pdf(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "pdf");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.doc".
 */
int spam_test_attachment_doc(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "doc");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.xls".
 */
int spam_test_attachment_xls(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "xls");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.gif".
 */
int spam_test_attachment_gif(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "gif");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.jpg" or
 * "something.jpeg".
 */
int spam_test_attachment_jpg(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg,
				       "jpg") +
	    spam_test_attachment__scan(msg, "jpeg");
	if (n > 0)
		return n + 1;

	return 0;
}


/*
 * Add a token for every attachment with the filename "something.png".
 */
int spam_test_attachment_png(opts_t opts, msg_t msg, spam_t spam)
{
	int n;

	n = spam_test_attachment__scan(msg, "png");
	if (n > 0)
		return n + 1;

	return 0;
}

/* EOF */
