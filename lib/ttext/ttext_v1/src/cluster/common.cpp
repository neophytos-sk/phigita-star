#include "common.h"

bool getLines(string filename,vector<string>* lines)
{
    lines->clear();
    FILE * f = fopen(filename.c_str(),"r");
    if (f)
    {
	while (!feof(f))
	{
	    string line("");
	    char ch = 'a';
	    while (ch != '\n')
	    {
		char ch = (char) fgetc(f);
		if (ch != EOF)
		{
		    if (ch == '\n' || ch == '\0')
			break;
		    line += ch;
		}
		else
		{
		    fclose(f);
		    return true;
		}
	    }
	    lines->push_back(line);
	    
	}
    }
    return false;
}

bool getText(string filename, string* text)
{
    *text = "";
    FILE * f = fopen(filename.c_str(),"r");
    if (f)
    {
	while (!feof(f))
	{
	    string line("");
	    char ch = 'a';
	    while (ch != '\n')
	    {
		char ch = (char) fgetc(f);
		if (ch != EOF)
		{
		    if (ch == '\n' || ch == '\0')
			break;
		    line += ch;
		}
		else
		{
		    fclose(f);
		    return true;
		}
	    }
	    *text += " " + line;
	}
    }
    return false;
}
    
string toLower(string str)
{
    char * d = (char*) str.c_str();
    Tcl_UtfToLower(d);
    str.assign(d);
    return str;
}

/*string toLower(string str)
{
    char * s = (char *) str.c_str();
    unsigned int length = Tcl_NumUtfChars(s,-1);
    string empty("");
    string result("");
    for (unsigned int i = 0; i < length; i++)
    {
	Tcl_UniChar cht = Tcl_UniCharAtIndex(s,i);
	
	char * ch = (char *) empty.c_str();
	cht = Tcl_UniCharToLower(cht);
	Tcl_UniCharToUtf(cht,ch);
	result += ch;
    }
    return result;
}*/

string replaceAll(string str)
{
    for (unsigned int i = 0; i < str.length(); i++)
	if (!Tcl_UniCharIsAlnum((int) str[i]))
	    str[i] = ' ';
    return str;	
}

string clearString(string str)
{
    string s("");
    for (unsigned int i = 0; i < str.length(); i++) {
	if (Tcl_UniCharIsPrint((int) str[i]))
	    s += str[i];
    }
    return s;
}

string trim(string line)
{
    while (Tcl_UniCharIsSpace(line[0])) 
	line.erase(0,1);
    while (Tcl_UniCharIsSpace(line[line.length()-1])) 
	line.erase(line.length()-1,1);
    return line;
}

string getFilePath(string filename)
{
    int slashpos = filename.rfind("/");
    if (slashpos >= 0)
	return filename.substr(0,slashpos+1);
    else
	return "";
}

vector<string> getTokens(string str)
{
    vector<string> tokens;
    string token("");
    char * s = (char *) str.c_str();
    unsigned int length = Tcl_NumUtfChars(s,-1);
    string empty("");
    for (unsigned int i = 0; i < length; i++)
    {
	Tcl_UniChar cht = Tcl_UniCharAtIndex(s,i);
	
	char * ch = (char *) empty.c_str();
	Tcl_UniCharToUtf(cht,ch);
	
	if (Tcl_UniCharIsAlnum(cht))
	    token += ch;
	else 
	{
	    if (token.length() > 0)
	    {
		tokens.push_back(token);
		token = "";
	    }
	}
    }
    if (token.length() > 0)
	tokens.push_back(token);
	return tokens;
}

int compareStrings(string s1, string s2)
{
    return Tcl_UtfNcasecmp(
	(char*) s1.c_str(), 
	(char*) s2.c_str(), 
	min( Tcl_NumUtfChars((char*) s1.c_str(),-1),Tcl_NumUtfChars((char*) s2.c_str(),-1) )
	    );
}
