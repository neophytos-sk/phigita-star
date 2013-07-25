//----------------------------------------------------------------------------
//
// PATRICIA Trie Template Class
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
// File:    nPatriciaTrie.h
// Date:    02/03/2005
// Purpose: Patricia trie ADT.
//
//----------------------------------------------------------------------------

#ifndef nPatriciaTrieH
#define nPatriciaTrieH

#include <stdlib.h>
#include <string.h>

typedef char* nPatriciaTrieKey;
template <class T> class nPatriciaTrie;


//----------------------------------------------------------------------------
//
// Class:   nPatriciaTrieNode
// Purpose: A node in a PATRICIA trie.
//          Each node stores one key, and the data associated with that key.
//
//----------------------------------------------------------------------------
template <class T>
class nPatriciaTrieNode {
	private:
		friend class nPatriciaTrie<T>;
		int bit_index;
		nPatriciaTrieKey        key;
		T                       data;
		nPatriciaTrieNode<T>*   left;
		nPatriciaTrieNode<T>*   right;

	public:

		// Constructors & destructor
		nPatriciaTrieNode();
		nPatriciaTrieNode(nPatriciaTrieKey, T, int, nPatriciaTrieNode<T>*, nPatriciaTrieNode<T>*);
		virtual ~nPatriciaTrieNode();

		// Name:    Initialize
		// Args:    key, data, left, right
		// Return:  void
		// Purpose: Initialize this node with the given data.
		void					Initialize(nPatriciaTrieKey, T, int, nPatriciaTrieNode<T>*, nPatriciaTrieNode<T>*);

		// Name:	GetData/SetData
		// Args:	data : T
		// Return:	T | bool
		// Purpose:	Accessors for the data field.
		T                       GetData();
		bool                    SetData(T);
		
		// Name:	GetKey
		// Args:	none
		// Return:	char*
		// Purpose:	Getter for the key field.
		nPatriciaTrieKey        GetKey();

		// Name:	GetLeft/GetRight
		// Args:	none
		// Return:	nPatriciaTrieNode*
		// Purpose:	Getters for the left/right fields.
		nPatriciaTrieNode<T>*   GetLeft();
		nPatriciaTrieNode<T>*   GetRight();

};

//----------------------------------------------------------------------------
//
// Class:   nPatriciaTrie
// Purpose: Implements a PATRICIA trie structure with keys of
//          type nPatriciaTrieKey (currently char*, but can be changed, see
//          the definition of nPatriciaTrieKey above).
//
//----------------------------------------------------------------------------
template <class T>
class nPatriciaTrie {
	private:
		void recursive_remove(nPatriciaTrieNode<T>*);
		int  bit_get(nPatriciaTrieKey, int);
		int  bit_first_different(nPatriciaTrieKey, nPatriciaTrieKey);
		bool key_compare(nPatriciaTrieKey, nPatriciaTrieKey);
		void key_copy(nPatriciaTrieNode<T>*, nPatriciaTrieNode<T>*);
		nPatriciaTrieNode<T>* head;

	public:

		// Constructor and destructor
		nPatriciaTrie();
		virtual ~nPatriciaTrie();

		// Name:	Insert(key, data)
		// Args:	key : nPatriciaTrieKey, data : T
		// Return:	nPatriciaTrieNode*
		// Purpose:	Insert a new key+data pair in the Patricia structure, and
		//          return the new node.
		virtual nPatriciaTrieNode<T>*   Insert(nPatriciaTrieKey, T);

		// Name:	Lookup(key)
		// Args:	key : nPatriciaTrieKey
		// Return:	T
		// Purpose:	Search for the given key, and return the data associated
		//          with it (or NULL).
		virtual T                       Lookup(nPatriciaTrieKey);

		// Name:	LookupNode(key)
		// Args:	key : nPatriciaTrieKey
		// Return:	T
		// Purpose:	Search for the given key, and return the node that
		//          contains it (or NULL).
		virtual nPatriciaTrieNode<T>*   LookupNode(nPatriciaTrieKey);

		// Name:	Delete(key)
		// Args:	key : nPatriciaTrieKey
		// Return:	bool
		// Purpose:	Remove the node containing the given key. Return
        //          true if the operation succeeded, false otherwise.
		virtual bool                    Delete(nPatriciaTrieKey);

};

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>::nPatriciaTrieNode() {
	Initialize(NULL, NULL, -1, this, this);
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>::nPatriciaTrieNode(nPatriciaTrieKey k,
                                        T d,
                                        int bi,
                                        nPatriciaTrieNode<T>* l,
                                        nPatriciaTrieNode<T>* r) {
    Initialize(k, d, bi, l, r);
}

//----------------------------------------------------------------------------
template <class T>
void nPatriciaTrieNode<T>::Initialize(nPatriciaTrieKey k,
                                      T d,
                                      int bi,
                                      nPatriciaTrieNode<T>* l,
                                      nPatriciaTrieNode<T>* r) {
	if (k)
		key = (nPatriciaTrieKey)strdup(k);
	else
		key = k;
	data      = d;
	left      = l;
	right     = r;
	bit_index = bi;
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>::~nPatriciaTrieNode() {
	if (key) {
		free(key);
		key = NULL;
	}
}

//----------------------------------------------------------------------------
template <class T>
T nPatriciaTrieNode<T>::GetData() {
	return data;
}

//----------------------------------------------------------------------------
template <class T>
bool nPatriciaTrieNode<T>::SetData(T d) {
	memcpy(&data, &d, sizeof(T));
	return true;
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieKey nPatriciaTrieNode<T>::GetKey() {
	return key;
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>* nPatriciaTrieNode<T>::GetLeft() {
	return left;
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>* nPatriciaTrieNode<T>::GetRight() {
	return right;
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrie<T>::nPatriciaTrie() {
	// Create the head of the structure. The head is never moved
	// around in the trie (i.e. it always stays at the top of the structure).
    // This prevents further complications having to do with node removal.
	head = new nPatriciaTrieNode<T>();
#define ZEROTAB_SIZE 256
	head->key = (char*)calloc(ZEROTAB_SIZE, 1);
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrie<T>::~nPatriciaTrie() {
	recursive_remove(head);
}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>* nPatriciaTrie<T>::Insert(nPatriciaTrieKey k, T d) {
	
	nPatriciaTrieNode<T> *p, *t, *x;

	// Start at the root
	p = head;
	t = (nPatriciaTrieNode<T>*)(p->right);

	// Navigate down the tree and look for the key
	while (p->bit_index < t->bit_index) {
		p = t;
		t = (nPatriciaTrieNode<T>*)(bit_get(k, t->bit_index) ? t->right : t->left);
	}

	// Is the key already in the tree?
	if (key_compare(k, t->key))
		return NULL; // Already in the tree!

	// Find the first bit that does not match.
	int i = bit_first_different(k, t->key);

	// Find the appropriate place in the tree where
	// the node has to be inserted
	p  = head;
	x  = (nPatriciaTrieNode<T>*)(p->right);
	while ( ( p->bit_index < x->bit_index ) &&
			( x->bit_index < i) ) {
		p = x;
		x = (nPatriciaTrieNode<T>*)(bit_get(k, x->bit_index) ? x->right : x->left);
	}

	// Allocate a new node and initialize it.
	t = new nPatriciaTrieNode<T>();
	t->Initialize(k, d, i, (bit_get(k, i) ? x : t), (bit_get(k, i) ? t : x));

	// Rewire
	if (bit_get(k, p->bit_index))
		p->right = t;
	else
		p->left = t;

	// Return the newly created node
	return t;

}

//----------------------------------------------------------------------------
template <class T>
T nPatriciaTrie<T>::Lookup(nPatriciaTrieKey k) {

	// Lookup the node
	nPatriciaTrieNode<T>* node = LookupNode(k);

	// Failed?
	if (!node)
		return NULL;

	// Return the data stored in this node
	return node->data;

}

//----------------------------------------------------------------------------
template <class T>
nPatriciaTrieNode<T>* nPatriciaTrie<T>::LookupNode(nPatriciaTrieKey k) {

	nPatriciaTrieNode<T>* p;
	nPatriciaTrieNode<T>* x;

	// Start at the root.
    p = head;
	x = (nPatriciaTrieNode<T>*)(head->right);

	// Go down the Patricia structure until an upward
	// link is encountered.
	while (p->bit_index < x->bit_index) {
		p = x;
		x = (nPatriciaTrieNode<T>*)(bit_get(k, x->bit_index) ? x->right : x->left);
	}

	// Perform a full string comparison, and return NULL if
	// the key is not found at this location in the structure.
	if (!key_compare(k, x->key))
		return NULL;

	// Return the node
	return x;

}

//----------------------------------------------------------------------------
template <class T>
bool nPatriciaTrie<T>::Delete(nPatriciaTrieKey k) {

	nPatriciaTrieNode<T> *p, *t, *x, *pp, *lp;
	int bp, bl, br;
	char* key = NULL;

	// Start at the root
	p  = head;
	t  = (nPatriciaTrieNode<T>*)(p->right);

	// Navigate down the tree and look for the key
	while (p->bit_index < t->bit_index) {
		pp = p;
		p  = t;
		t  = (nPatriciaTrieNode<T>*)(bit_get(k, t->bit_index) ? t->right : t->left);
	}

	// Is the key in the tree? If not, get out!
	if (!key_compare(k, t->key))
		return false; // The key could not be found!

	// Copy p's key to t
	if (t != p)
		key_copy(p, t);

	// Is p a leaf?
	bp = p->bit_index;
	bl = ((nPatriciaTrieNode<T>*)(p->left))->bit_index;
	br = ((nPatriciaTrieNode<T>*)(p->right))->bit_index;

	if ((bl > bp) || (br > bp)) {
		
        // There is at least one downward edge.

		if (p != t) {
			
			// Look for a new (intermediate) key
			key = strdup(p->key);

			lp = p;
			x  = (nPatriciaTrieNode<T>*)(bit_get(key, p->bit_index) ? p->right : p->left);
      
			while (lp->bit_index < x->bit_index) {
				lp = x;
				x  = (nPatriciaTrieNode<T>*)(bit_get(key, x->bit_index) ? x->right : x->left);
			}

			// If the intermediate key was not found, we have a problem..
            if (!key_compare(key, x->key)) {
                free(key);
				return false; // The key could not be found!
            }

			// Rewire the leaf (lp) to point to t
			if (bit_get(key, lp->bit_index))
				lp->right = t;
			else
				lp->left = t;

		}

		// Rewire the parent to point to the real child of p
		if (pp != p) {
			nPatriciaTrieNode<T>* ch = (nPatriciaTrieNode<T>*)(bit_get(k, p->bit_index) ? p->left : p->right);
			if (bit_get(k, pp->bit_index))
				pp->right = ch;
			else
				pp->left = ch;
		}

        // We no longer need 'key'
        free(key);
        key = NULL;
	
	} else {

		// Both edges (left, right) are pointing upwards or to the node (self-edges).
    
		// Rewire the parent
		if (pp != p) {
			nPatriciaTrieNode<T>* blx = (nPatriciaTrieNode<T>*)(p->left);
			nPatriciaTrieNode<T>* brx = (nPatriciaTrieNode<T>*)(p->right);
			if (bit_get(k, pp->bit_index))
				pp->right = (((blx == brx) && (blx == p)) ? pp : ((blx==p)?brx:blx));
			else
				pp->left  = (((blx == brx) && (blx == p)) ? pp : ((blx==p)?brx:blx));
		}

	}

	// Deallocate p (no longer needed)
	delete p;

	// Success!
	return true;

}

//----------------------------------------------------------------------------
template <class T>
void nPatriciaTrie<T>::recursive_remove(nPatriciaTrieNode<T>* root) {

	nPatriciaTrieNode<T>* l = (nPatriciaTrieNode<T>*)root->left;
	nPatriciaTrieNode<T>* r = (nPatriciaTrieNode<T>*)root->right;

	// Remove the left branch
	if ( (l->bit_index >= root->bit_index) && (l != root) && (l != head) )
		recursive_remove(l);

	// Remove the right branch
	if ( (r->bit_index >= root->bit_index) && (r != root) && (r != head) )
		recursive_remove(r);

	// Remove the root
	delete root;

}

//----------------------------------------------------------------------------
template <class T>
int nPatriciaTrie<T>::bit_get(nPatriciaTrieKey bit_stream, int n) {
  if (n < 0) return 2; // "pseudo-bit" with a value of 2.
  int k = (n & 0x7);
  return ( (*(bit_stream + (n >> 3))) >> k) & 0x1;
}

//----------------------------------------------------------------------------
template <class T>
bool nPatriciaTrie<T>::key_compare(nPatriciaTrieKey k1, nPatriciaTrieKey k2) {
    if (!k1 || !k2)
        return false;
	return (strcmp((char*)k1, (char*)k2) == 0);
}

//----------------------------------------------------------------------------
template <class T>
int nPatriciaTrie<T>::bit_first_different(nPatriciaTrieKey k1, nPatriciaTrieKey k2) {
    if (!k1 || !k2)
        return 0; // First bit is different!
	int n = 0;
	int d = 0;
	while (	(k1[n] == k2[n]) &&
			(k1[n] != 0) &&
			(k2[n] != 0) )
		n++;
	while (bit_get(&k1[n], d) == bit_get(&k2[n], d))
		d++;
	return ((n << 3) + d);
}

//----------------------------------------------------------------------------
template <class T>
void nPatriciaTrie<T>::key_copy(nPatriciaTrieNode<T>* src, nPatriciaTrieNode<T>* dest) {

	if (src == dest)
		return;

	// Copy the key from src to dest
	if (strlen(dest->key) < strlen(src->key))
		dest->key = (nPatriciaTrieKey)realloc(dest->key, 1 + strlen(src->key));
	strcpy(dest->key, src->key);

	// Copy the data from src to dest
	dest->data = src->data;

	// How about the bit index?
	//dest->bit_index = src->bit_index;
	
}


#endif
