<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

   <fullquery name="lang::util::nls_language_from_language.nls_language_from_language">      
      <querytext>
      
        select nls_language
        from   ad_locales 
        where  language = :language
        limit  1
    
      </querytext>
   </fullquery>
 
</queryset>
