-- @author Mark Dettinger (mdettinger@arsdigita.com)
-- $Id: host-node-map-create.sql,v 1.3 2003/01/16 13:37:46 jeffd Exp $

create table host_node_map (
   host                 varchar(200) 
	constraint host_node_map_host_pk primary key 
	constraint host_node_map_host_nn not null,
   node_id              integer 
	constraint host_node_map_node_id_fk references site_nodes
);
