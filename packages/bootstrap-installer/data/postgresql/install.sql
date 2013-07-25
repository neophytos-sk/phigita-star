create function inline_0 ()
returns integer as '
declare
    um_id		apm_packages.package_id%TYPE;
    pm_id		apm_packages.package_id%TYPE;
    kernel_id           apm_packages.package_id%TYPE;
    node_id             site_nodes.node_id%TYPE;
    main_site_id        site_nodes.node_id%TYPE;
    admin_id            apm_packages.package_id%TYPE;
    my_id		apm_packages.package_id%TYPE;
    schema_user         varchar(100);
    jobnum              integer;
begin   

  main_site_id := apm_service__new(
                    null,
                    ''Start'',
                    ''subsite'',
                    ''apm_service'',
                    now(),
                    null,
                    null,
                    acs__magic_object_id(''default_context'')
               );


  PERFORM apm_package__enable (main_site_id); 


  node_id := site_node__new (
          null,
          null,          
          '''',
          main_site_id,          
          ''t'',
          ''t'',
          null,
          null
  );

  PERFORM acs_permission__grant_permission (
        main_site_id,
        acs__magic_object_id(''the_public''),
        ''read''
        );

  admin_id := apm_service__new (
      null,
      ''System Administration'',
      ''control-panel'',
      ''apm_service'',
      now(),
      null,
      null,
      null
      );

  PERFORM apm_package__enable (admin_id);

  node_id := site_node__new (
    null,
    site_node__node_id(''/'', null),
    ''control-panel'',
    admin_id,
    ''t'',
    ''t'',
    null,
    null
  );




  pm_id := apm_service__new (
      null,
      ''Package Manager'',
      ''package-manager'',
      ''apm_service'',
      now(),
      null,
      null,
      null
      );

  PERFORM apm_package__enable (pm_id);

  node_id := site_node__new (
    null,
    site_node__node_id(''/control-panel/'', null),
    ''package-manager'',
    pm_id,
    ''t'',
    ''t'',
    null,
    null
  );




  return null;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();
