#include <stdio.h>
#include <stdlib.h>

typedef struct nodeT {
  struct nodeT* left;
  struct nodeT* right;
  int value;
} node_t;


node_t *NewNode(int value)
{
  node_t *node = (node_t *) malloc(sizeof(node_t));
  node->value = value;
  node->left = NULL;
  node->right = NULL;
  return node;
}

// Insert node using recursion
void RInsert(node_t **root, int value)
{
  if (*root == NULL) {
    *root = NewNode(value);
    return;
  }

  if (value < (*root)->value)
    RInsert(&(**root).left,value);
  else
    RInsert(&(**root).right,value);
}

void Insert(node_t **root, int value)
{

  node_t *newNode = NewNode(value);

  if (*root == NULL) {
    *root = newNode;
    return;
  }

  node_t *current = *root;
  while(current) {
    if (value < current->value) {
      // insert left
      if(current->left == NULL) {
	current->left=newNode;
	return;
      } else {
	current=current->left;
      }
    } else {
      // insert right
      if(current->right == NULL) {
	current->right=newNode;
	return;
      } else {
	current = current->right;
      }

    }
  }

}


node_t *FindNode(node_t *root, int target)
{
  if (!root)
    return NULL;
  
  node_t *current = root;
  while(current) {
    if (target < current->value)
      current=current->left;
    else if (target > current->value)
      current=current->right;
    else
      return current;
  }
  return NULL; // not found
}


node_t **find_inorder_predecessor(node_t **node)
{
  node_t **pred = &(*node)->left;
  while ((*pred)->right != NULL)
    pred = &(*pred)->left;

  return pred;
}

// http://en.literateprograms.org/Binary_search_tree_(C)
void Delete(node_t **node, int value)
{
  if (value < (*node)->value) {
    Delete( &((*node)->left), value);
  } else if (value > (*node)->value) {
    Delete( &((*node)->right), value);
  } else {

    // This is the node to be deleted.

    printf("found node %d\n",(*node)->value);

    node_t *old_node = *node;

    if ((*node)->left == NULL) { 
      // deleting a leaf or a node with one child (right)
      *node = (*node)->right;
      free(old_node);
    } else if ((*node)->right == NULL) {
      // deleting a node with one child (left)
      *node= (*node)->left;
      free(old_node);
    } else {
      // deleting a node with two children
      
      node_t **pred = find_inorder_predecessor(node);
      
      if (*pred) {
	printf("deleting a node with two children, pred=%d\n",(*pred)->value);
      }

      /* swap values */
      void *temp = (*pred)->value;
      (*pred)->value = (*node)->value;
      (*node)->value = temp;

    }


  }
}


void PreOrderBST(const node_t *root)
{
  if (!root)
    return;

  printf("%d\n",root->value);
  PreOrderBST(root->left);
  PreOrderBST(root->right);

}

void InOrderBST(const node_t *root)
{
  if (!root)
    return;

  InOrderBST(root->left);
  printf("%d\n",root->value);
  InOrderBST(root->right);

}

void PostOrderBST(const node_t *root)
{
  if (!root)
    return;

  PostOrderBST(root->left);
  PostOrderBST(root->right);
  printf("%d\n",root->value);

}

int main(int argc, char *argv[])
{
  node_t *tree =  NULL;

  Insert(&tree,123);
  Insert(&tree,456);
  Insert(&tree,88);
  Insert(&tree,5);
  Insert(&tree,67);
  Insert(&tree,999);
  Insert(&tree,31);
  Insert(&tree,204);

  InOrderBST(tree);

  node_t *temp;
  //temp = FindNode(tree,23); // value not found
  temp = FindNode(tree,31);
  if (temp)
    printf("found value, temp->value = %d\n",temp->value);
  else 
    printf("value not found in tree\n");



  printf("delete value 67 from BST\n");
  Delete(&tree,67);

  printf("delete value 123 from BST\n");
  Delete(&tree,123);

  printf("==InOrder==\n");
  InOrderBST(tree);
  printf("==PreOrder==\n");
  PreOrderBST(tree);
  printf("==PostOrder==\n");
  PostOrderBST(tree);
  return 0;
}
