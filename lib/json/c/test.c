/*
  Copyright (c) 2009 Dave Gamble
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/

#include <stdio.h>
#include <stdlib.h>
#include "cJSON.h"


void parse_and_callback(cJSON *item) {

  while(item) {
    printf("type=%d, string=%s valuestring=%s\n",item->type,item->string,item->valuestring);
    if (item->child) parse_and_callback(item->child);
    item = item->next;
  }

}


/* Parse text to JSON, then render back to text, and print! */
void doit(char *text)
{
	char *out;cJSON *json;
	
	json=cJSON_Parse(text);
	if (!json) {printf("Error before: [%s]\n",cJSON_GetErrorPtr());}
	else
	{
	  parse_and_callback(json);
	  // out=cJSON_Print(json);
	  cJSON_Delete(json);
	  // printf("%s\n",out);
	  free(out);
	}
}

/* Read a file, parse, render back, etc. */
void dofile(const char *filename)
{
	FILE *f=fopen(filename,"rb");fseek(f,0,SEEK_END);long len=ftell(f);fseek(f,0,SEEK_SET);
	char *data=malloc(len+1);fread(data,1,len,f);fclose(f);
	doit(data);
	free(data);
}


int main (int argc, const char * argv[]) {

  if (argc != 2) {
    printf("Usage: %s filename\n",argv[0]);
    return 1;
  }

  dofile(argv[1]);

  return 0;
}
