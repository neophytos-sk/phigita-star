<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="name">      
      <querytext>
      select acs_object__name(:object_id)

      </querytext>
</fullquery>

 
<fullquery name="party_name">      
      <querytext>
      select acs_object__name(:party_id) 
      </querytext>
</fullquery>

 
</queryset>
