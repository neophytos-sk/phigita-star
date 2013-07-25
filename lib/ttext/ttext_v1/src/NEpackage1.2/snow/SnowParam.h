// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: SnowParam.h                                   =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef SNOWPARAM_H__
#define SNOWPARAM_H__


bool ParseParamFile( const char* paramFilename,
		     GlobalParams & globalParams );
bool ValidateParams( GlobalParams & globalParams);
bool ProcessParam( char param, const char* arg, 
		   GlobalParams & globalParams );
bool ParseCmdLine( int argc, char* argv[], 
		   GlobalParams & globalParams );

#endif
