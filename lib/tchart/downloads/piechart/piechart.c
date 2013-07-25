/* Bernhard Reiter
 * $Id: piechart.c,v 1.24 2004/09/28 19:15:08 bernhard Exp $
 *
 * Copyright (C) 1997-2004 by Bernhard Reiter 
 * 
 *    This program is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU General Public License
 *   as published by the Free Software Foundation; either version 2
 *   of the License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *	
 *	Creates a piechart, must be linked with a libplot library
 *	reads ascii input file from stdin.
 *
 *	format: one slice per line. every trailing tab and space will
 *		be ignored. The string after the last tab or space
 *		will be scanned as value. The beginning is the label-text.
 *		Empty lines and lines starting with "#" are ignored
 *
 *	INSTALLATION: See the makefile on how to build piechart.
 *		You might get a warning about an implicit declaration
 *		of getopt(). You can try and include getopt.h then,
 *		e.g. with commenting out the #include line later in this file.
 *
 *      KNOWN_BUGS: There is a numerical bug in plotutils-2.4.1 libplot
 * 		involving small angles, you can tickle it out with piechart
 *              when using very large and very small numbers. E.g. like:
 *                echo -e 'One 150000000000\nTwo 2' | ./piechart -T X
 *              Workaround: scale down all input numbers 
 *                          or set reasonably small ones to zero
 *
 *
 *	TODO: many improvements possible.
 *		- make stuff more dynamic (input linelength and max # of slices)
 *		- better handling of progname
 *		- move more stuff into command line options
 *		e.g.	
 *			+ fonts
 *			+ rotation of the pie
 *		- use getopt_long
 *		- make better assumptions on how to place the labels
 *		- special handling of very small slices
 *		- make multi line labels possible
 *		- multi-line titles?
 *		- does every system have strdup(), strncpy()?
 *		- 
 *		...
 *
 *	CONTRIBUTORS: 
 *		"Martin J. Evans" <martin@mjedev.demon.co.uk>
 *		pointed out that some systems do not terminate
 *		the target string after strncpy().
 *		
 *		Jan-Oliver Wagner <jwagner@usf.uni-osnabrueck.de>
 *		created the first version to work with gnu plotutils-2.2.
 *		Added pullout option.
 *		
 *		Tom Peters <tpeters@xs4all.nl> notified me that some
 *		systems have getopt.h .
 *
 *		Satish Alreja <salreja@hotmail.com> reported a bug
 *		in v0.10 when not displaying percentages.
 *
 *		Franck Aniere <aniere@genoscope.cns.fr> reported a
 *		bug in v0.11 when using "-f".
 *
 *		Alexander Pohoyda alexander.pohoyda a.t gmx.net contributed
 *		the "-B" option (incl. a calculcation to keep the aspect ratio)
 *		and the "-n" option.
 */

#include <stdio.h>
/* #include <getopt.h> */ /*include this header file if your system needs it */
#include <plot.h>

#define VERSION "0.13 (CVS-$Revision: 1.24 $)"
void print_version(FILE *file)
{
             fprintf(file,"piechart version " VERSION "\n"); 
             fprintf(file,"Copyright (C) 1998-2004 Bernhard Reiter.\n"
             	    	"Piechart is Free Software under "
		    	"the GNU GENERAL PUBLIC LICENSE v2 or later.\n"
             	    	"It comes with ABSOLUTELY NO WARRANTY!\n");
#ifdef DEBUG
             fprintf(file,"compiled with option: DEBUG\n"); 
#endif
}

void print_sign(FILE *file)
{
	     fprintf(file,"\n"
"*Note:* In general pie graphs are bad for representing information!\n"
"The --warning option will print the whole story.\n\n"
		);
}

/*
 * $Log: piechart.c,v $
 * Revision 1.24  2004/09/28 19:15:08  bernhard
 * Added patch from Alexander Pohoyda for fontsize "-n",
 * 	also enabled negative values for "-n" and set the default to -1
 * makefile: changed test and moretests to use -n a bit
 *
 * Revision 1.23  2004/09/28 18:57:25  bernhard
 * Patch from Alexander Pohoyda to keep the aspect ratio when -B ing.
 * makefile: Adjusted test call to display bug fix.
 *
 * Revision 1.22  2004/09/28 18:44:59  bernhard
 * Added Alexander Pohoyda's -B option patch.
 *
 * Revision 1.21  2004/09/24 12:39:57  breiter
 * Added KNOWN_BUGS section with a description of the numerical libplot bug.
 *
 * Revision 1.20  2004/09/23 20:13:21  breiter
 * Bumped copyright year to 2004 and version anticipating next release.
 *
 * Revision 1.19  2004/09/23 20:10:27  breiter
 * Removed use of multi-line string constants.
 *   This makes piechart compile with gcc 3.3.x x>=1 again,
 *   because those strings have been a deprecated extension that got removed.
 *
 * Revision 1.18  2003/04/03 18:10:02  breiter
 * Slightly improved the warning message.
 *
 * Revision 1.17  2002/04/12 19:50:10  breiter
 * - bugfix: buffer for strings too small for "-f" option
 * - cleanup: minor formatting, version number, copyright year
 *
 * Revision 1.16  2001/12/09 12:09:52  breiter
 * - bugfix: seqfault with not displaying percentages (reported by Satish Alreja)- clean-up: better copyright and license message
 * - clean-up: minor: some additional comments and typo corrections
 * - bugfix: error status
 * - Improved usage help for available display types.
 *
 * Revision 1.15  2001/04/18  08:25:38  breiter
 * Corrected some typos in the warning message.
 *
 * Revision 1.14  2000/03/28  21:29:37  breiter
 * added literature to the warning sign
 *
 * Revision 1.13  2000/03/28  20:43:48  breiter
 * - added: Jan's pullout feature.
 * - codeclean-up: slice drawing code
 * - codeclean-up: moved plotsession init and end into functions
 * - bugfix: almost full circle slices are drawn correctly now
 * - closing circle code removed because arc are okay with libplot now
 * - added: Warning sign and story
 *
 * - codeclean-up: introduced MAX_RADIUS
 * - added: options "-f" and "-D"
 *  to show the percentage of the values
 *
 * Revision 1.12  1999/10/05  23:29:46  breiter
 * Added builg information
 * fixed a few doc typos
 *
 * Revision 1.11  1999/04/03  10:26:32  breiter
 * adapted to plotutils-2.2: added pl_ to all function calls
 * adjusted help text
 * more return values are checked now, as the function provide more of them
 * end circle and middle point are only drawn if LINEWIDTH is not default
 * changed constant name LINEWIDTH_LINES -> LINEWIDTH
 * end circle and middle point LINEWIDTH is multiplied with a factor(~1.2) now
 * extra external variables for getopt() are commented out
 *
 * Revision 1.10  1998/07/28  13:41:54  breiter
 * - Terminating strncpy()ed string now. Thanks to "Martin J. Evans"
 * for reporting this problem.
 * - Removed hard limit on label-size.
 * - Changed inputline buffersize to a new constant defined as LINE_BUFSIZ.
 * - Cleaned up some comments.
 * version number incremented to 0.8
 *
 * Revision 1.9  1998/07/07  23:44:26  breiter
 * added -C option for specifing colors
 * version number is 0.7 now.
 *
 * Revision 1.8  1998/07/07  17:04:40  breiter
 * major improvements:
 * - more structure: moves code into functions: process_arguments(),read_stdin()
 * - new scanning -> multi word labels are possible now
 * - two new options: -r radius and -d text distance
 * - errmsgs and usage are printed to stderr now, but to stdout, wenn requested
 * - fixed debug output typo
 *
 * Revision 1.7  1998/01/31  16:13:02  breiter
 * changed fill() -> filltype() as fill() is only temporarily supported
 *
 * Revision 1.6  1998/01/31  16:05:40  breiter
 * using a path to draw one slice now. This is far simpler.
 * No need for LINEWIDTH_FILL anymore.
 *
 * Revision 1.5  1998/01/30  16:06:37  breiter
 * adapted for use with libplot from plotutils-2.0
 * added +T display-type commandline option therefore.
 *
 * Revision 1.4  1997/10/11  17:19:14  breiter
 * cosmetic changes. version information enhanced.
 *
 * Revision 1.3  1997/10/11  16:31:56  breiter
 * version information enhanced.
 *
 * Revision 1.2  1997/10/11  16:09:15  breiter
 * bug fixes. small improvements. userspace is always square now.
 *
 * Revision 1.1  1997/10/11  15:07:27  breiter
 * Initial revision
 *
 */

#include <stdlib.h>
#include <math.h>
#include <string.h> 	/* for strdup() */
     
/* this program used getopt and relys on that it is included in the 
 * stdlib. I wanted to use getopt_long from Gnu, but it is not included
 * in the clib I have here. So it is still left TODO.
 */

/*******************************************************************************
 * Configurations -- change, what you like
 * 	If time permits some stuff could be influenced by command line options
 ******************************************************************************/

/*	Color in which the separating lines and the circle are drawn
 */
#define LINECOLOR "black"

/* LINEWIDTH is for the separating lines and the arcs
 * if closing circle and middle point will be drawn, a factor will be applied
 * -1 means default ; 0.02 might be a usefull value
 */
#define LINEWIDTH -1

/* Some hardcoded limits:
 * the max number of slices (^=MAX_SLICES).
 * LINE_BUFSIZ is the maxmumlength of input-lines.
 *(You see, how lasy I was. I was not using some object orientated language
 *	like objective-c and left all the neat dynamic string handling for
 *	the interested hacker and or some version in the future.)
 */
#define MAX_SLICES 50
#define LINE_BUFSIZ 256

/* MAX_RADIUS limits the slice and accompaining text radius		*/
#define MAX_RADIUS 1.2

/* if an input line starts with this character, it is ignored.		*/
#define COMMENTCHAR '#'

/* Colors the slices are getting filled with.
 * the color names are feed into the libplot functions.
 * The plotutils distribution contains a file doc/colors.txt which lists the
 * recogized names.
 *
 * if the nullpointer is reached the color pointer is resetted starting
 * with the first color again.
 */
char *colortable[MAX_SLICES] = {
"red","blue","green","yellow", "brown",
 "coral",  "magenta","cyan", "seagreen3",
NULL
};


/*******************************************************************************
 * Beware: This following code is for hackers only.
 * 	( Yeah, it is not THAT bad, you can risk a look, if you know some C ..)
 ******************************************************************************/

/* Program structure outline:
 *	- get all options 
 *	- read all input data (only from stdin so far)
 *	- print
 *		+ init stuff
 *		+ print title
 *		+ print color part for slices
 *		+ print separating lines and circle
 *		+ print labels
 *		+ clean up stuff
 */


/* A nice structure, we will fill some of it, when we read the input.
 */
struct slice {
	char *text;		/* label for the slice			*/
	double value;		/* value for the slice			*/
	char *ftext;		/* text showing the percentage		*/
};

/* one global variable. It is needed everywhere..				*/
char * progname; 		/*  for printing errors out		*/


/* declarations of functions defined after main()			
 */
int init_plotsession(char *display_type, char *bitmap_size);
int end_plotsession(int handle);
void draw_slice(double center_x, double center_y, double radius, 
	double startangle, double sliceangle);
void process_arguments(int argc, char **argv, 
	char **display_type, char ** title, char ** pulled_slice, 
	double *radius, double *text_distance, double *ftext_distance,
	int *show_fraction, char *colortable[], char **bitmap_size,
	double *font_size);
void read_stdin(int *n_slices, struct slice *slices[MAX_SLICES]);


/*******************************************************************************
 *
 * Attention: Main Progam to be started.... :)				
 */
int main(int argc, char **argv)
{
char * title=NULL;		/* Title of the chart			*/
char * pulled_slice=NULL;	/* Name of slice to be pulled out	*/
int pulled_slice_no = -1;	/* Number of the slice to be pulled out */
double pullout_direction_angle;	/* pull-out direction			*/
double pullout_center_x;	/* center X-coord for pulled slice	*/
double pullout_center_y;	/* center Y-coord for pulled slice	*/
int return_value;		/* return value for libplot calls.	*/
char *display_type = "meta";	/* default libplot output format 	*/
int handle;			/* handle for open plotter		*/

struct slice *slices[MAX_SLICES];/* the array of slices			*/
int n_slices=0;			/* number of slices in slices[]	;)	*/
int t;				/* loop var(s) 				*/
double sum;			/* sum of all slice values		*/
int w, h;			/* width and height of the plot		*/

double radius=0.8;		/* radius of the circle in plot coords	*/
double font_size=-1;		/* size of text font			*/
double text_distance=0;		/* distance of text from circle		*/
double ftext_distance=0;	/* distance of fraction text from text	*/
int show_fraction=0;	        /* flag to show the fraction		*/
char *bitmap_size=NULL; 	/* bitmap size of the pixel outputs	*/


process_arguments(argc,argv,
	&display_type,&title,&pulled_slice,&radius,&text_distance,
	&ftext_distance,&show_fraction,colortable,&bitmap_size,&font_size);

print_sign(stderr);

read_stdin(&n_slices,slices);

/* Let us count the values */
sum=0.;
for(t=0;t<n_slices;t++)
	sum+=slices[t]->value;

/* create the text for the percentages, if wanted */
if (show_fraction) {
	for(t=0;t<n_slices;t++) {
		slices[t]->ftext=calloc(1,sizeof(char)*20);/*space for int*/
		if(!slices[t]->ftext) perror(progname),exit(10);
		/* well snprintf would be good here, but some systems
		 * or libcs are still missing snprint, we just trust %f*/
		sprintf(slices[t]->ftext,"%-.1f%%",(slices[t]->value/sum)*100);
	}
} 


/* Lets test for the slice to be pulled out */
if (pulled_slice && *pulled_slice) {
	for (t=0;t<n_slices;t++)
		if (strcmp(slices[t]->text,pulled_slice) == 0)
			{ pulled_slice_no = t; break; }

	if (pulled_slice_no == -1) {
		fprintf(stderr,"The name of the slice to be pulled out can not be found.\n");
		exit(1);
	}
}

handle=init_plotsession(display_type,bitmap_size);

				/* creating your user coordinates	*/
if (bitmap_size != NULL)
{
	sscanf(bitmap_size, "%dx%d", &w, &h);
}
else
{
	w = MAX_RADIUS; h = MAX_RADIUS;
}

if(title)
{
	return_value= pl_fspace(-(MAX_RADIUS+0.2), -(MAX_RADIUS+0.2) * h / w,
				(MAX_RADIUS+0.2), (MAX_RADIUS+0.2) * h / w);
}
else
{
	return_value= pl_fspace(-MAX_RADIUS, -MAX_RADIUS * h / w,
				MAX_RADIUS, MAX_RADIUS * h / w);
}

if(return_value)
{	fprintf(stderr,"fspace returned %d!\n",return_value);	}


/* we should be ready to plot, now! */



				/* I like to think in degrees. 		*/
#define X(radius,angle) (cos(angle)*(radius))
#define Y(radius,angle) (sin(angle)*(radius))

#define RAD(angle) (((angle)/180.)*M_PI)

#define XY(radius,angle) (X((radius),RAD(angle))),(Y((radius),RAD(angle)))

/* plot title if there is one */
if(title&&*title)
{
	pl_ffontsize(font_size+0.02);
	pl_fmove(0,radius+text_distance+0.2);
	pl_alabel('c','b',title);
}

pl_pencolorname(LINECOLOR);
pl_ffontsize(font_size);


/* and now for the slices		*/
{
    double distance,angle=0;
    char **color=colortable;
    double r=radius;			/*the radius of the slice circle*/


    pl_savestate();
    pl_joinmod("round");

				/* drawing the slices			*/
    
    pl_filltype(1);
    pl_flinewidth(LINEWIDTH);
    pl_pencolorname(LINECOLOR);
    for(t=0;t<n_slices;t++)
				/* draw one path for every slice 	*/
    {
    	distance=(slices[t]->value/sum)*360.;
    	pl_fillcolorname(*color);
				
	if (t == pulled_slice_no) { /* test for pulling out */
		/* pull-out direction is middle of start and end: */
		pullout_direction_angle = distance / 2 + angle;

		/* pullout_center_(xy) is also used later when adding labels.*/
		pullout_center_x = X(0.1, RAD(pullout_direction_angle));
		pullout_center_y = Y(0.1, RAD(pullout_direction_angle));

		draw_slice(pullout_center_x, pullout_center_y,r,angle,distance);

	} else {
		draw_slice(0,0,r,angle,distance);
	}

	angle+=distance;	/* log fraction of circle already drawn	*/

	color++; 		/* next color for next slice 		*/
	if(!*color) color=colortable;/* start over if all colors used 	*/

    }
   					
    pl_restorestate();
}

/* and now for the text		*/
{
    double distance,angle=0,place;
    double r=radius+text_distance;/* radius of circle where text is placed*/
    char h,v;
    char *label;		/* helping variabel containing the label */
    pl_savestate();

    for(t=0;t<n_slices;t++) 
    {
    	distance=(slices[t]->value/sum)*360.;
    				/* let us calculate the position ...	*/
	place=angle+0.5*distance;
				/* and the alignment			*/
	if(place<180)
		v='b';
	else
		v='t';
	if(place<90 || place>270)
		h='l';
	else
		h='r';
				/* plot now!				*/

	if (t == pulled_slice_no)
		pl_fmove(X(r,RAD(place))+pullout_center_x,Y(r,RAD(place)) + 
							pullout_center_y);
	else
		pl_fmove(XY(r,place));




	if (show_fraction && ftext_distance==0) {
		label=malloc(
			strlen(slices[t]->ftext)+strlen(slices[t]->text)+2+1);
		if (!label) perror(progname),exit(10);
	 	if (show_fraction==1) 
		  sprintf(label,"%s  %s",slices[t]->text,slices[t]->ftext);
		else
		  sprintf(label,"%s  %s",slices[t]->ftext,slices[t]->text);
	} else label=slices[t]->text;

	pl_alabel(h,v,label);
			
	if (show_fraction && (ftext_distance!=0)) {
		if (t == pulled_slice_no)
			pl_fmove(
			   X(r+ftext_distance,RAD(place))+pullout_center_x,
			   Y(r,RAD(place)) + pullout_center_y);
		else
			pl_fmove(XY(r+ftext_distance,place));
		pl_alabel(h,v,slices[t]->ftext);
	}

	angle+=distance;
    }
   					
    pl_restorestate();
}

return end_plotsession(handle);
/* Note: We did not free() the allocated space for the slices. */
}



/*******************************************************************************
 * functions
 */

int init_plotsession(char *display_type, char *bitmap_size)
/* Initialise libplot and return handle of wanted plotter.	*/
{   
    int handle, return_value;

    return_value=pl_parampl("BITMAPSIZE", bitmap_size);
    if(return_value<0)
    {  fprintf(stderr,"The plotter does not accept parameters.\n");
       exit(1);
    }

    handle=pl_newpl(display_type, NULL, stdout, stderr);
    if(handle<0)
    {   fprintf(stderr,"The plotter could not be created.\n");
        exit(1);
    }
    
    return_value=pl_selectpl(handle);          
    if(return_value<0)
    {  fprintf(stderr,"The plotter does not exist or could not be selected.\n");
       exit(1);
    }

    return_value=pl_openpl();
    if(return_value<0)
    {   fprintf(stderr,"The selected plotter could not be opened!\n");
        exit(1);
    }

    return handle;
}

/******************************************************************************/
int end_plotsession(int handle)
/* Close and delete plotter, return NULL if everything went fine.	*/
{
    int err_status=0, return_value;
    
    				/* end a plot sesssion			*/
    return_value= pl_closepl();
    if(return_value<0)
    { 	fprintf(stderr,"The plotter could not be closed.\n");
    	/* no exit, because we try to delete the plotter 		*/
    	err_status +=1;
    }
    				
    /* need to select a different plotter in order to delete our	*/
    return_value=pl_selectpl(0);
    if(return_value<0)
    {   fprintf(stderr,"Default Plotter could not be selected!\n");
        err_status +=1<<1;
    }
    
    return_value=pl_deletepl (handle);/* clean up by deleting used plotter */
    if(return_value<0)
    {   fprintf(stderr,"Selected Plotter could not be deleted!\n");
        err_status +=1<<2;
    }
    
    return err_status;
}
/******************************************************************************/
void draw_slice(double center_x, double center_y, double r, 
	double startangle, double sliceangle)
/* draw one slice starting at center(xy). Slice has radius an angle
   we use one filled drawing path, but we might need more than one arc pieces

	sliceangle is the distance in degrees we still have to go
	startangle is the angle where the next arc piece starts
*/
{
	pl_fmove(center_x,center_y);
	pl_fcont(X(r, RAD(startangle))+center_x, Y(r,RAD(startangle))+center_y);	
	while(sliceangle>179)
	{			/* we need to draw a circlepart first 	*/
				/* we have to be sure to draw 
				   counterclockwise (180 wouldn`t work 
				   in all cases)			*/
	    pl_farc(center_x,center_y,
		X(r, RAD(startangle))+center_x,Y(r,RAD(startangle))+center_y,
		X(r,RAD(startangle+179))+center_x,
				Y(r,RAD(startangle+179))+center_y);
	    startangle+=179;	
	    sliceangle-=179;
	}
	pl_farc(center_x,center_y,
		X(r, RAD(startangle))+center_x, Y(r,RAD(startangle))+center_y,
		X(r,RAD(startangle+sliceangle))+center_x,
				Y(r,RAD(startangle+sliceangle))+center_y);
	pl_fcont(center_x,center_y);		/* return to center	*/

	pl_endpath();		/* not really necessary, but intuitive	*/
}
 
/******************************************************************************/
void process_arguments(	int argc, char **argv, 
	char **display_type, char ** title, char ** pulled_slice,
	double *radius, double *text_distance, double *ftext_distance,
	int *show_fraction, char *colortable[], char **bitmap_size,
	double *font_size)
{
/* well, we do not have the gnu getopt long here. :-( 
 * so I use getopt for now
 */
          int c;		
          extern char *optarg;
	  /* optint,opterr,optopt relate to getopt(),see manpage*/
	  /* but we do not use them so far			*/
          /* extern int optind,opterr,optopt; */ 
          int errflg = 0;
          int show_usage=0;
          int show_version=0;
	  int specified_display_type=0;
	  char **help;	/* will help splitting the colornames	*/
	  char *arg;	/* one string argument			*/

progname=argv[0];	/* fill the only global variable	*/

	c=argc;
	while(--c)
	{   if ( strcmp("--warning",argv[c]) == 0 )
	    {	printf("\n\
Warning!\n\
	\n\
	Piecharts are generally not recommended to visualise information!\n\
	Use bar- or pointchars instead if the quantities are important.\n\
\n\
Studies have shown that piecharts are hard to read if you actually have to\n\
answer questions about the numbers they represent. They look very pleasing\n\
and can be seen in many places but they are bad to visualise quantitative\n\
information. Analytic thinking persons will read the percentages or values\n\
given on the legend or the chart itself and analyse them in their head\n\
when encountering a piechart.\n\
\n\
This is mostly because differences in angles are not easy to judge \n\
for the human eye and there are a bunch of cases were you make the \n\
piechart experience even worse. There are still reasons to use piecharts.\n\
In certain situations when the raw numbers are not what is needed. You might\n\
go for a more fancy or slick presentation which does not stress the numbers\n\
or the interpretation of them.\n\
\n\
\n\
Some rules to get better piecharts:\n\
	* Only use them to display 2 up to 6 fraction of one units\n\
	* The values should to be in the same magnitute\n\
	* Values shall not be almost the same, differences will be lost\n\
	* Use colors with high contrasts to each other\n\
\n\
Edward Tufte [3-5] and Howard Wainer [6] both recommend bar- or pointcharts\n\
for the tasks other people would use piecharts for.\n\
\n\
This program started as an programming example for libplot. \n\
After doing more research about visualisation I found that piecharts are\n\
a bad idea for scientific data display. Therefore I erected this\n\
warning sign as tribute to visualisation scientist, whose words are\n\
lost too often in business noise. It also eases my consciousness.\n\
You are educated now, ready to approach piecharts with a little bit\n\
more scepticism and decide for yourself.\n\
\n\
	Bernhard Reiter, April 2003\n\
\n\
Literature:\n\
\n\
\n\
[1] Gary T. Henry. Graphing Data - Techniques for Display and Analysis,\n\
    volume 36 of Applied Social Research Methods. \
SAGE Publications, Inc.,1995.\n\
\n\
[2] Calvin Fischer Schmid.  Statistical Graphics - Design Principles and\n\
    Practices. Wiley, 1983.\n\
\n\
[3] Edward Rolf Tufte.  The Visual Display of Quantitative Information.\n\
    Graphics Press, PO Box 430, Cheshire, Connecticut 06410, 1983.\n\
\n\
[4] Edward Rolf Tufte. Envisioning Information, 1990.\n\
\n\
[5] Edward Rolf Tufte. Visual Explanations - \
Images and Quantities, Evidence \n\
    and Narrative, 1997.\n\
\n\
[6] Howard Wainer. Visual Revelations - Graphical Tales of Fate and De-\n\
    ception from Napolean Bonaparte to Ross Perot. \
Copernicus (Springer), 1997.\n\
");
		exit(0);
	    }
	}

          while ((c = getopt(argc, argv, "Vt:p:f:T:r:d:D:C:hsB:n:")) != EOF)
               switch (c) {
               case 'B':
		   *bitmap_size=strdup(optarg);
		   break;

               case 't':
                    if (*title)
                         errflg++;
                    else
                         *title=strdup(optarg);
                    break;

		case 'p':
			if (*pulled_slice)
				errflg ++;
			else
				*pulled_slice = strdup(optarg);
			break;

               case 'T':
                    if (specified_display_type)
                         errflg++;
                    else {
		    	specified_display_type++;
	  	        *display_type = strdup(optarg);
		    }
                    break;

	       case 'r':
	       	    *radius=atof(optarg);
	       	    if(*radius<0.1||*radius>MAX_RADIUS)
		    	errflg++;
		    break;

               case 'n':
		   *font_size=atof(optarg);
	       	   if(*font_size>=0 && 
				(*font_size<0.001||*font_size>MAX_RADIUS)
		     )
		    	errflg++;
		   break;

	       case 'd':
	       	    *text_distance=atof(optarg);
	       	    if(*text_distance<(-2.0)||*text_distance>MAX_RADIUS)
		    	errflg++;
			/* we have a second check after processing all options*/
		    break;

	       case 'D':
		    *ftext_distance=atof(optarg);
	       	    if(*ftext_distance<(-2.0)||*ftext_distance>MAX_RADIUS)
		    	errflg++;
		       /* we need the second check after all options 	*/
		    break;

	       case 'f':
	            switch (optarg[0]) {
			    case 'l':
				    *show_fraction=2;
				    break;
			    case 'r':
				    *show_fraction=1;
				    break;
			    case '-':
			    case 'n':
				    *show_fraction=0;
				    break;
			    default :
				    errflg++;
	            }
		    break;
		    
	       case 'C':
	       	    help=colortable;
		    arg=strdup(optarg);
		    *help++=strtok(arg,",\0");
		    if(!*help)
		    	errflg++;
		    else
		    	while((*(help++)=strtok(NULL,",\0")));
		    break;
		    
               case 'V':
                    if (show_version)
                         errflg++;
                    else
                         show_version++;
                    break;

               case 'h':
                    if (show_usage)
                         errflg++;
                    else
                         show_usage++;
                     break;

               case '?':
                    errflg++;
               }
	       			/* check if distances are reasonable	*/
	  if(*text_distance + *radius < 0 || 
	     *text_distance+*radius > MAX_RADIUS) errflg++;
	  if(*ftext_distance + *text_distance+ * radius < 0 || 
             *ftext_distance + *text_distance+*radius > MAX_RADIUS) errflg++;
	  		
          if (errflg) {
               fprintf(stderr, "parameters were bad!\n");
               show_usage++;
          }
          if(show_version)
          {
             print_version(stdout); 
             print_sign(stdout); 
             exit(1);
          }
          if(show_usage)
          {	FILE *f=stdout;
	  	if(errflg)
             		f=stderr;
		else 	f=stdout;
	     print_version(f);
	     print_sign(f);
		
             fprintf(f,"usage: %s [options]\n",progname); 
             fprintf(f,"\t the stdin is read once.\n");
             fprintf(f,"\t options are:\n"\
             	    "\t\t-t Title\tset \"Title\" as piechart title\n"\
		    "\t\t-p name\t\tpull out slice with text=name\n"\
		    "\t\t-f type\t\tShow percentage. type of:\n"\
		    "\t\t\t\t'-' or 'n'\twell don't do it\n"\
		    "\t\t\t\t'l'\t\tplace left of label\n"\
		    "\t\t\t\t'r'\t\tplace right after label\n"\
             	    "\t\t-T Display-Type\tone of "\
			"X, ps, fig, png, meta, cgm,\n" 
		    "\t\t\t\thpgl, ai, regis, tek, svg, pnm\n"\
		    "\t\t\t\t(or whatever your libplot version supports)\n"\
		    "\t\t\t\tdefault:meta\n"\
		    "\t\t-r radius\tfloat out of [0.1;%.1f] default:0.8\n"\
		    "\t\t-n fontsize\tsize of the font used to plot the text\n"\
                    "\t\t\t\tfloat out of [0.001;%.1f] or negative\n"\
		    "\t\t\t\tdefault:-1\n"\
		    "\t\t-d textdistance\tfloat out of "\
		    	"[- r;%.1f-r] default:0.0\n"\
		    "\t\t-D ftext_distance\tadditional distance for percentage text\n"\
		    "\t\t\t\tfloat out of [-(r+d);%.1f-(r+d)]\n"\
		    "\t\t-C colornames\tcomma separated list of colornames\n"\
		    "\t\t\t\t(see valid names in color.txt of plotutils doc.)\n"\
             	    "\t\t-B size\t\tbitmapsize\tformat WIDTHxHEIGHT\n"\
             	    "\t\t\t\t(Possible: Append start coords for X like +0-5)\n"\
             	    "\t\t\t\tdefault: 570x570    example: 500x500-30+50\n"\
             	    "\t\t-h\t\tprint this help and exit\n"\
             	    "\t\t-V\t\tprint version and exit\n\n"\
             	    "\t\t--warning\tPrint advice against using piecharts.\n"\
             	    ,MAX_RADIUS,MAX_RADIUS,MAX_RADIUS,MAX_RADIUS);
             
             exit(1);
          }

/* Everything is fine with the options now ... */
}


/******************************************************************************/
void read_stdin(int *n_slices, struct slice *slices[MAX_SLICES])
/* consume all lines from stdin, parse them in the slices array.
 * allocate, initialise and fill slice structs.
 */
{
char line [LINE_BUFSIZ];		/* input line buffer		*/

/* So, let us read the standardinput */
while( !(feof(stdin) || ferror(stdin)) )
{
char *c; 			/* string return from fgets		*/
struct slice * aslice;		/* freshly filled slice-structure	*/
int r;				/* help variable for scanning		*/
char *s,*t;			/* help variables for scanning		*/

	c=fgets(line,LINE_BUFSIZ,stdin);
	if(!c) continue;	/* encountered error of eof		*/
	if(line[strlen(line)-1]!='\n')
	{
		fprintf(stderr,"line was too long!\n");
		exit(2);
	}
				/* strip newline */
	line[strlen(line)-1]='\0';
				/* strip carridge return, if there is one*/
	if(line[strlen(line)-1]=='\r') 
		line[strlen(line)-1]='\0';
	
				/* Skip empty lines or lines beginning  
				 * with COMMENTCHAR			*/
	if(!(line[0]==COMMENTCHAR || !(line) || strlen(line)==0))
	{
#ifdef DEBUG
		fprintf(stderr,"Scanning line: %s\n",line);
#endif
		aslice=malloc(sizeof(struct slice));
		if(!aslice)
			perror(progname),exit(10);
			
			
				/* scanning the last part
				 * after a tab or space as number	*/
				 
				/* delete trailing tabs and spaces	*/
		r=strlen(line);
		while(r>0 && (line[r-1]==' ' || line[r-1]=='\t') )
			line[r---1]='\0';
				/* scan for last tab or space		*/
		s=strrchr(line,' ');
		t=strrchr(line,'\t');
		s=(s>t?s:t);	/* which is the last white-space?	*/
			
				/*use full string,if no whitespace found
				else copy text up to whitespace
				and get enough memory			*/
		if(s==NULL) 
		{
			if(!(aslice->text=malloc(1))) 
				perror(progname),exit(10);
			aslice->text[0]='\0'; 
			s=line;
		} else
		{	
			if(!(aslice->text=malloc(strlen(line)-strlen(s)+1))) 
				perror(progname),exit(10);
			strncpy(aslice->text,line, strlen(line)-strlen(s));
				/*some systems don`t terminate target 
				string in strncpy, so we have to do it	*/
			aslice->text[strlen(line)-strlen(s)]='\0';
		}
		
				/* scan last string for number		*/
		r=sscanf(s,"%lf",&aslice->value);
		if(r!=1)
			fprintf(stderr,"number in line couldn`t be scanned\n"),
				exit(8);
		
		if(*n_slices>=MAX_SLICES)
			fprintf(stderr,"too many slices\n"),exit(8);

			
		aslice->ftext=NULL;	/* initialise at least the pointer */
		slices[(*n_slices)++]=aslice;
	}
}

if(ferror(stdin))
{
	perror(progname);
	exit(5);
}

#ifdef DEBUG
fprintf(stderr,"Read %d slices!\n",*n_slices);
#endif 
}
