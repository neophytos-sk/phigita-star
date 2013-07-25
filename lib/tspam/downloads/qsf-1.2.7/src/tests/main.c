/*
 * Main entry point for calling all special tests.
 *
 * Copyright 2007 Andrew Wood, distributed under the Artistic License.
 */

#include "config.h"
#include "testi.h"
#include <stdlib.h>
#include <string.h>

/*
 * Prototype all tests here, and list them in the spam_test() function
 * below.
 */
int spam_test_gtube(opts_t, msg_t, spam_t);
int spam_test_attachment_scr(opts_t, msg_t, spam_t);
int spam_test_attachment_pif(opts_t, msg_t, spam_t);
int spam_test_attachment_exe(opts_t, msg_t, spam_t);
int spam_test_attachment_vbs(opts_t, msg_t, spam_t);
int spam_test_attachment_vba(opts_t, msg_t, spam_t);
int spam_test_attachment_lnk(opts_t, msg_t, spam_t);
int spam_test_attachment_com(opts_t, msg_t, spam_t);
int spam_test_attachment_bat(opts_t, msg_t, spam_t);
int spam_test_attachment_pdf(opts_t, msg_t, spam_t);
int spam_test_attachment_doc(opts_t, msg_t, spam_t);
int spam_test_attachment_xls(opts_t, msg_t, spam_t);
int spam_test_attachment_jpg(opts_t, msg_t, spam_t);
int spam_test_attachment_gif(opts_t, msg_t, spam_t);
int spam_test_attachment_png(opts_t, msg_t, spam_t);
int spam_test_gibberish_consonants(opts_t, msg_t, spam_t);
int spam_test_gibberish_vowels(opts_t, msg_t, spam_t);
int spam_test_gibberish_from_consonants(opts_t, msg_t, spam_t);
int spam_test_gibberish_from_vowels(opts_t, msg_t, spam_t);
int spam_test_gibberish_badstart(opts_t, msg_t, spam_t);
int spam_test_gibberish_hyphens(opts_t, msg_t, spam_t);
int spam_test_gibberish_longwords(opts_t, msg_t, spam_t);
int spam_test_html_comments_in_words(opts_t, msg_t, spam_t);
int spam_test_html_external_img(opts_t, msg_t, spam_t);
int spam_test_html_font(opts_t, msg_t, spam_t);
int spam_test_html_urls(opts_t, msg_t, spam_t);
int spam_test_image_single(opts_t, msg_t, spam_t);
int spam_test_image_multiple(opts_t, msg_t, spam_t);


/*
 * Run each test in turn, such that if a test triggers, its special token is
 * added to the token list or, if the test says to override the message's
 * spam/nonspam value, do that.
 *
 * Returns 0 normally, nonzero if testing is to be overridden: -1 means to
 * always mark the message as non-spam, 1 means to always mark it as spam.
 *
 * Test functions should return 0 for no action, -1 to override all other
 * tests and mark as non-spam, 1 to override all tests and mark as spam, and
 * 1+n to continue as usual but add that test's token to the token tree "n"
 * times (where "n" is 1 or more).
 *
 * Tokens should start with "." to distinguish themselves from real tokens,
 * which can never start with ".", and should end with "." for cosmetic
 * reasons. Tokens should never contain any characters not in TOKEN_CHARS
 * (see include/spam.h), and must NEVER be longer than 32 characters.
 */
int spam_test(opts_t opts, spam_t spam, msg_t msg)
{
	struct {
		char *token;
		spamtestfunc_t func;
	} test[] = {
		{
		".GTUBE.", spam_test_gtube}, {
		".ATTACH-SCR.", spam_test_attachment_scr}, {
		".ATTACH-PIF.", spam_test_attachment_pif}, {
		".ATTACH-EXE.", spam_test_attachment_exe}, {
		".ATTACH-VBS.", spam_test_attachment_vbs}, {
		".ATTACH-VBA.", spam_test_attachment_vba}, {
		".ATTACH-LNK.", spam_test_attachment_lnk}, {
		".ATTACH-COM.", spam_test_attachment_com}, {
		".ATTACH-BAT.", spam_test_attachment_bat}, {
		".ATTACH-PDF.", spam_test_attachment_pdf}, {
		".ATTACH-DOC.", spam_test_attachment_doc}, {
		".ATTACH-XLS.", spam_test_attachment_xls}, {
		".ATTACH-JPG.", spam_test_attachment_jpg}, {
		".ATTACH-GIF.", spam_test_attachment_gif}, {
		".ATTACH-PNG.", spam_test_attachment_png}, {
		".GIBBERISH-CONSONANTS.", spam_test_gibberish_consonants},
		{
		".GIBBERISH-VOWELS.", spam_test_gibberish_vowels}, {
		".GIBBERISH-FROMCONS.",
			    spam_test_gibberish_from_consonants}, {
		".GIBBERISH-FROMVOWL.", spam_test_gibberish_from_vowels},
		{
		".GIBBERISH-BADSTART.", spam_test_gibberish_badstart},
		{
		".GIBBERISH-HYPHENS.", spam_test_gibberish_hyphens}, {
		".GIBBERISH-LONGWORDS.", spam_test_gibberish_longwords},
		{
		".HTML-COMMENTS-IN-WORDS.",
			    spam_test_html_comments_in_words}, {
		".HTML-EXTERNAL-IMG.", spam_test_html_external_img}, {
		".HTML-FONT.", spam_test_html_font}, {
		".HTML-IP-IN-URLS.", spam_test_html_urls}, {
		".SINGLE-IMAGE.", spam_test_image_single}, {
		".MULTIPLE-IMAGES.", spam_test_image_multiple}, {
		NULL, NULL}
	};
	int i, ret, n;

	for (i = 0; test[i].func != NULL; i++) {
		ret = (test[i].func) (opts, msg, spam);

		switch (ret) {
		case -1:
			return -1;
		case 0:
			break;
		case 1:
			return 1;
		default:
			for (n = 1; n < ret; n++) {
				spam_token_add(opts, spam, test[i].token,
					       strlen(test[i].token));
			}
			break;
		}
	}

	return 0;
}

/* EOF */
