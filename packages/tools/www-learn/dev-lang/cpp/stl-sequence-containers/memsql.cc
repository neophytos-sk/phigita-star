/*
         1
    2    ->    3
 4 -> 5 ->   6 -> 7
     8     ->      10
*/


   
void link_siblings(node_t* root)
{
    if (!root) return;
    node_t *current = root->r;
    std::queue<node_t *> lqueue;
    lqueue.push(root);
    while(!lqueue.empty()) {
        root = lqueue.front();
        current = rqueue.front();
        
        root->s = current;
        
        lqueue.pop();
        rqueue.pop();
        
        lqueue.push(root->l);
        lqueue.push(root->r);

    }
        

}

