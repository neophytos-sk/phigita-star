


                    'a'
                'b'      'c'
             'd'  'e'  'f' 'g'
             
             a\n
             bc\n
             defg\n
             
             
#include <queue>
#include <iostream>

using namespace std;

struct node {
    struct node *left;
    struct node *right;
    char data;
};

void print_tree(const node *root) {
    queue<node*> q;
    q.push(root);
    q.push(NULL);
    while (!q.empty()) {
        node *current = q.front();
        q.pop();
        if (!current) {
            cout << endl;
            if (!q.empty()) {
                q.push(NULL);
                continue;
            } else {
                break;
            }
        } else {
            cout << current->data;
        }
        if(current->left) q.push(current->left);
        if(current->right) q.push(current->right);
    }
}
