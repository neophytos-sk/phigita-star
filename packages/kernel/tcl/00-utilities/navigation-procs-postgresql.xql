<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>                                                    
<fullquery name="ad_context_bar.context">      
      <querytext>
      
    select ltree2url(tree_sk) as url, 
	   object_id,
           acs_object__name(object_id) as object_name,
           nlevel(tree_sk) as level
      from site_nodes
     where node_id = :node_id
  order by level asc
  
      </querytext>
</fullquery>

 
</queryset>
