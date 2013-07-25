
#include <stdio.h>
#include <plot.h>

#define min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define max(X, Y)  ((X) > (Y) ? (X) : (Y))


#define VERSION "0.91 "
void print_version(FILE *file)
{
             fprintf(file,"ascii_chart version " VERSION "\n"); 
             fprintf(file,"Copyright (C) 1998, 1999 by Bernhard Reiter & Chris Elliott. \n"
             	    "The GNU GENERAL PUBLIC LICENSE applies. "
             	    	"Absolutly No Warranty!\n");
#ifdef DEBUG
             fprintf(file,"compiled with option: DEBUG\n"); 
#endif
}


#include <stdlib.h>
#include <math.h>
#include <string.h> 	/* for strdup() */
     
/* this program used getopt and relys on that it is included in the 
 * stdlib. I wanted to use getopt_long from Gnu, but it is not included
 * in the clib i have here. So it is still left TODO.
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
 * the max number of slices (^=MAXSLICES).
 * LINE_BUFSIZ is the maxmumlength of input-lines.
 *(You see, how lasy i was. I was not using some object orientated language
 *	like objective-c and left all the neat dynamic string handling for
 *	the interested hacker and or some version in the future.)
 */
#define MAXSLICES 65
#define LINE_BUFSIZ 256

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
char *colortable[MAXSLICES] = {  /* colors changed by chris */
   "red",  "blue",   "green", "yellow", 
 "firebrick",  "aliceblue","greenyellow",  "wheat",
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
};

/* one global variable. It is needed everywhere..				*/
char * progname; 		/*  for printing errors out		*/


void read_stdin(int *n_slices, struct slice *slices[MAXSLICES]);

#define MAXORDER 12
void draw_c_curve (plPlotter *plotter, double dx, double dy, int order)
{
  if (order >= MAXORDER)
    /* continue path along (dx, dy) */
    pl_fcontrel_r (plotter, dx, dy);
  else {
      draw_c_curve (plotter,
                    0.5 * (dx - dy), 0.5 * (dx + dy), order + 1);
      draw_c_curve (plotter,
                    0.5 * (dx + dy), 0.5 * (dy - dx), order + 1);
  }
}



/* Attention: Main Progam to be started.... :)				*/


int plot(char *display_type,char *title,char *xtext,char *mytext, int chart_type,double radius, double text_distance)
{
  //char * title=NULL;		/* Title of the chart			*/
//   char * xtext=NULL;		/* X axis Title of the chart			*/
   //   char * mytext=NULL;		/* Y axis Title of the chart			*/
int return_value;		/* return value for libplot calls.	*/
//char *display_type = "meta";	/* default libplot output format 	*/
int handle;			/* handle for open plotter		*/

struct slice *slices[MAXSLICES];/* the array of slices			*/
int n_slices=0;			/* number of slices in slices[]	;)	*/
int t;				/* loop var(s) 				*/
double slice_max, sum;		/* max and sum of all slice values chris		*/
int neg_flag  ;   
                                /* check all values > 0 chris */

double text_space  ;   
   
/* vars for ymax */
   char buffer [55] ;    
   double ymax ;
    int ystep ;
    int nf [4] = { 2,5,2,0 };
    int n = 1 ;
    ymax = 1.0 ;
    ystep = 0 ;
    
    
    // process_arguments(argc,argv,&display_type,&title,&xtext,&mytext,&isPie,&radius,&text_distance,colortable);

read_stdin(&n_slices,slices);

/* Let us find the sum and  max and check for negative values */
/* code added to by chris */   
sum = 0 ;
slice_max=1.;
neg_flag = 0 ;   
   
for(t=0;t<n_slices;t++)
     {
     sum+=slices[t]->value;
     slice_max = max (slice_max,slices[t]->value) ;
     if ( slices [t]->value < 0 ) neg_flag ++ ;	
     }

if ( neg_flag )
     {
     fprintf(stderr,"Some data were apparently less than zero. \nThis version of the program does not plot negative values.\n");
     exit(1);
     }
/* initialising one plot session	*/
				/* specify type of plotter		*/
handle=pl_newpl(display_type, NULL, stdout, stderr);
if(handle<0)
{   fprintf(stderr,"The plotter could not be created.\n");
    exit(1);
}

return_value=pl_selectpl(handle);          
if(return_value<0)
{   fprintf(stderr,"The plotter does not exist or could not be selected.\n");
    exit(1);
}

return_value= pl_openpl();
if(return_value<0)
{   fprintf(stderr,"The selected plotter could not be opened!\n");
    exit(1);
}

/* now decide to plot bar or pie */
if (chart_type==1) {
  /* creating your user coordinates	*/
  if(title)
    return_value= pl_fspace(-1.4,-1.4,1.4,1.4);
  else
    return_value= pl_fspace(-1.2,-1.2,1.2,1.2);
  if(return_value)
    {	fprintf(stderr,"fspace returned %d!\n",return_value);	}
  
  
  /* we should be ready to plot pie, now! */



  /* i like to think in degrees. 		*/
#define X(radius,angle) (cos(angle)*(radius))
#define Y(radius,angle) (sin(angle)*(radius))
  
#define RAD(angle) (((angle)/180.)*M_PI)
  
#define XY(radius,angle) (X((radius),RAD(angle))),(Y((radius),RAD(angle)))

  /* plot title if there is one */
  if(title&&*title){
    pl_fmove(0,radius+text_distance+0.2);
    pl_alabel('c','b',title);
  }

  pl_pencolorname(LINECOLOR);

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
				
	pl_fmove(0,0);		/* start at center..			*/
	pl_fcont(XY(r,angle));	
    	if(distance>179)
    	{			/* we need to draw a semicircle first 	*/
				/* we have to be sure to draw 
				   counterclockwise (180 wouldn`t work 
				   in all cases)			*/
	    pl_farc(0,0,XY(r,angle),XY(r,angle+179)); 
	    angle+=179;	
	    distance-=179;
    	}
	pl_farc(0,0,XY(r,angle),XY(r,angle+distance));
	pl_fcont(0,0);		/* return to center			*/
	pl_endpath();		/* not really necessary, but intuitive	*/
	
	angle+=distance;	/* log fraction of circle already drawn	*/
				 
	color++; 		/* next color for next slice 		*/
	if(!*color) color=colortable;/* start over if all colors used 	*/
    }

    				/* the closing circle and middle point  */
				/* only, if LINEWIDTH!=default	*/
    if(LINEWIDTH!=-1)
    {
				/* add %5 to compensate for arc obstrution*/
    	pl_flinewidth(LINEWIDTH*1.2);

	pl_filltype(0);
	pl_fcircle(0.,0.,r);	

	pl_colorname(LINECOLOR);
	pl_filltype(1);
	pl_fpoint(0,0);	
    }
   					
    pl_restorestate();
  }

  /* and now for the text		*/
  {
    double distance,angle=0,place;
    double r=radius+text_distance;/* radius of circle where text is placed*/
    char h,v;
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
	pl_fmove(XY(r,place));
	pl_alabel(h,v,slices[t]->text);
	
	angle+=distance;
      }
    
    pl_restorestate();
  }


  
 } /* end of is Pie */
 else if (1 == chart_type) {  /* next part plots bars , chris */
   if(title || xtext || mytext) {
     text_space = -2.0 - text_distance ;
   } else {
     text_space = -1.0 - text_distance ;	     
   }
   /* x0, y0, x1 y1 but it has to be square for the fonts*/
   return_value= pl_fspace(text_space / radius, 
			   text_space / radius, 
			   (10.0 - text_space) / radius, 
			   (10.0 - text_space) / radius );
   if(return_value)
     {	fprintf(stderr,"fspace returned %d!\n",return_value);	}


   /* we should be ready to plot bars, now! */


 
   /* plot title if there is one */
   if(title&&*title) {
     pl_ffontsize (0.5);
     pl_fmove( 5, 11 ) ;
     pl_alabel('c','c',title); /* cnetered */
   }
   /* plot X axis title if there is one */
   if(xtext&&*xtext) {
     pl_ffontsize (0.5);
     pl_fmove( 5, 0.7 * text_space ) ;
     pl_alabel('c','c',xtext); /* cnetered */
   }
   /* plot Y axis title if there is one */
   if(mytext&&*mytext) {
     pl_ffontsize (0.5);
     pl_fmove( 0.8 * text_space, 6 ) ;
     pl_ftextangle (90);
     pl_alabel('c','c',mytext); 
     pl_ftextangle (0); 
   }
   /* find y max */
    
   while ( ymax < slice_max ) {
     ymax = ymax * nf [n] ;
     n ++ ;
     if ( nf[n] ) n = 0 ;
   }
   pl_line ( 0,0,0, 10.0 *  ymax / slice_max  );
   /* plot Y axis */
   while ( ystep < ymax ) {
     pl_fline ( -0.3, 10 * (double) ystep/ slice_max ,0.0, 10 * ystep / slice_max );
     pl_fmove ( 0.3 * text_space , 10 * (double) ystep / slice_max  );
     sprintf ( buffer, "%d", ystep );
     pl_alabel ( 'r','c', buffer );	
     ystep = ystep + ymax / 10;
     if (ystep < 1 ) ystep ++ ;
   }  

   pl_pencolorname(LINECOLOR);

   /* and now for the bars		*/
   {

     char **color=colortable;

     pl_savestate();
     pl_joinmod("round");
    
     pl_filltype(1);
     pl_flinewidth(LINEWIDTH);
     pl_pencolorname(LINECOLOR);
     for(t=0;t<n_slices;t++) {
       pl_fillcolorname(*color);
       pl_fbox (10.0 * (double)(t)/(double)(n_slices),
		0,
		10.0 * (double)(t+1)/(double)(n_slices),
		10 * slices[t]->value/slice_max );
       color++; 		/* next color for next slice 		*/
       if(!*color) color=colortable;/* start over if all colors used 	*/
     } /* end of for each slice */

     pl_restorestate();
   }

   /* and now for the text		*/
   {
     char just ;
     just = 'c';
     
     pl_savestate();
     pl_ffontsize (0.4);
     if (n_slices > 5)
       {
	 pl_ftextangle (90); /* degrees */
	 just = 'r' ;
       }
     for(t=0;t<n_slices;t++) 
       {
	 /* plot now!				*/
	 pl_fmove(10.0 * (double)(t+0.5)/(double)(n_slices),
		  0.3 * text_space );
	 pl_alabel(just, 'c' ,slices[t]->text);
       }
     pl_restorestate();
   }
 } /* end of is ! Pie */
 else if (2  == chart_type) {
   plPlotter *plotter;
   plPlotterParams *plotter_params;

   /* set a plotter parameter */
   plotter_params = pl_newplparams();
   pl_setplparam(plotter_params, "PAGESIZE", "letter");

   /* Create a Postscript plotter that writes to standard output */
   if ((plotter = pl_newpl_r(display_type,stdin,stdout,stderr,plotter_params)) == NULL) {
     fprintf(stderr, "Couldn't create Plotter\n");
   }

   /* open Plotter */ 
   if (pl_openpl_r(plotter) < 0 ) {
     fprintf(stderr,"Couldn't open Plotter\n");
     return 1;
   }
   pl_fspace_r(plotter,0.0,0.0,1000.0,1000.0); /* set coor system */
   pl_flinewidth_r(plotter, 0.25); /* set line thickness */
   pl_pencolorname_r(plotter, "red"); /* use red pen */
   pl_erase_r(plotter); /* erase graphics display */
   pl_fmove_r(plotter, 600.0, 300.0); /* position the graphics cursor */
   draw_c_curve(plotter, 0.0, 400.0, 0);
   if (pl_closepl_r(plotter) <0 ) {
     fprintf(stderr, "Couldn't close Plotter\n");
     return 1;
   }

   if (pl_deletepl_r(plotter) <0 ) {
     fprintf(stderr,"Couldn't delete plotter\n");
     return 1;
   }
   return 0;
 }
 if (3  == chart_type) {
   plPlotter *plotter;
   plPlotterParams *plotter_params;

   /* set a plotter parameter */
   plotter_params = pl_newplparams();
   pl_setplparam(plotter_params, "PAGESIZE", "letter");

   /* Create a Postscript plotter that writes to standard output */
   if ((plotter = pl_newpl_r(display_type,stdin,stdout,stderr,plotter_params)) == NULL) {
     fprintf(stderr, "Couldn't create Plotter\n");
   }

   /* open Plotter */ 
   if (pl_openpl_r(plotter) < 0 ) {
     fprintf(stderr,"Couldn't open Plotter\n");
     return 1;
   }
   pl_fspace_r(plotter,0.0,0.0,1000.0,1000.0); /* set coor system */
   pl_flinewidth_r(plotter, 0.25); /* set line thickness */
   pl_pencolorname_r(plotter, "red"); /* use red pen */
   pl_erase_r(plotter); /* erase graphics display */
   pl_fmove_r(plotter, 0.0, 0.0); /* position the graphics cursor */
   //draw_c_curve(plotter, 0.0, 400.0, 0);
   //double x1=0.0,y1=0.0,x2=0.0,y2=0.0;
   double x_step =1000/(n_slices-1);
   double y_step=1000/slice_max;
   double x=0, y=y_step*slices[0]->value;
   pl_fmove_r(plotter,x,y);
   pl_flinewidth_r(plotter,3.5);
   pl_markerrel_r(plotter,0,0,17,20);
   for(t=1;t<n_slices;t++) {
     x+=x_step;
     y=y_step*slices[t]->value;
     //pl_fline_r(plotter, x1,y1,x2,y2);
     //x1=x2;
     //y1=y2;
     pl_fcont_r(plotter,x,y);
     pl_markerrel_r(plotter,0,0,17,20);
     pl_alabel_r(plotter,'l','x',slices[t]->text);
     pl_fmove_r(plotter,x,y);
   }
   pl_endsubpath_r(plotter);


   if (pl_closepl_r(plotter) <0 ) {
     fprintf(stderr, "Couldn't close Plotter\n");
     return 1;
   }

   if (pl_deletepl_r(plotter) <0 ) {
     fprintf(stderr,"Couldn't delete plotter\n");
     return 1;
   }
   return 0;
 }






/* end a plot sesssion			*/
return_value= pl_closepl();
if(return_value<0)
  { 	fprintf(stderr,"The plotter could not be closed.\n");
    /* no exit, because we try to delete the plotter 		*/
  }
				
/* need to select a different plotter in order to deleter our		*/
return_value=pl_selectpl(0);
if(return_value<0)
  {   fprintf(stderr,"Default Plotter could not be selected!\n");
  }

return_value=pl_deletepl (handle);/* clean up by deleting used plotter	*/
if(return_value<0)
  {   fprintf(stderr,"Selected Plotter could not be deleted!\n");
  }

			
return 0;
}


/************************************************************************
 * functions
 */
 


void read_stdin(int *n_slices, struct slice *slices[MAXSLICES])
{
char line [LINE_BUFSIZ];		/* input line buffer			*/

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
		
		if(*n_slices>=MAXSLICES)
			fprintf(stderr,"too many slices\n"),exit(8);
			
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
