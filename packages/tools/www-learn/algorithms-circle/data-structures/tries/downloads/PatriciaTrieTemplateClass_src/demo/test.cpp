//----------------------------------------------------------------------------
//
// PATRICIA Trie Template Class -- Demo application
//
// Released into the public domain on February 3, 2005 by:
//
//      Radu Gruian
//      web:   http://www.gruian.com
//      email: gruian@research.rutgers.edu
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to:
//
//      Free Software Foundation, Inc.
//      59 Temple Place, Suite 330
//      Boston, MA 02111-1307
//      USA
//
//----------------------------------------------------------------------------
//
// File:    test.cpp
// Date:    02/03/2005
// Purpose: Demonstrates how to use the nPatriciaTrie template class.
//
//----------------------------------------------------------------------------

#include <stdio.h>
#include "nPatriciaTrie.h"

int main(int argc, char* argv[]) {

	nPatriciaTrie<int>* p = new nPatriciaTrie<int>();

    // Insert some (key,data) pairs into the structure.
    printf("Inserting... %s\n", p->Insert("foobar1", 1) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("foobar2", 2) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("foobar3", 3) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("foobar4", 4) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("foobar5", 5) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("__2867", 23) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("_23437256", 234) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("c:\\work\\development", -20) ? "OK" : "FAILED!");
	printf("Inserting... %s\n", p->Insert("c:\\work\\release", -22) ? "OK" : "FAILED!");

    // Lookup
    printf("foobar1 = %d\n", p->Lookup("foobar1"));
	printf("foobar2 = %d\n", p->Lookup("foobar2"));
	printf("foobar3 = %d\n", p->Lookup("foobar3"));
	printf("foobar4 = %d\n", p->Lookup("foobar4"));
	printf("foobar5 = %d\n", p->Lookup("foobar5"));
	printf("__2867 = %d\n", p->Lookup("__2867"));
	printf("_23437256 = %d\n", p->Lookup("_23437256"));
	printf("c:\\work\\development = %d\n", p->Lookup("c:\\work\\development"));
	printf("c:\\work\\release = %d\n", p->Lookup("c:\\work\\release"));

    // Remove some items from the structure
	printf("Deleting 'foobar4'... %s\n", p->Delete("foobar4") ? "OK" : "Uh-oh!");
	printf("Deleting 'foobar5'... %s\n", p->Delete("foobar5") ? "OK" : "Uh-oh!");

    // Lookup
    printf("Looking up 'foobar4'... %s\n", p->LookupNode("foobar4") ? "Still there!" : "Not there (OK).");
    printf("Looking up 'foobar5'... %s\n", p->LookupNode("foobar5") ? "Still there!" : "Not there (OK).");

    
	delete p;

	return 0;
}

