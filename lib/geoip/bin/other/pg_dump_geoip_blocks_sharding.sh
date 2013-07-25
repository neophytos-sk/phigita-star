for i in {0,1000001,2000001}; do
/opt/postgresql/bin/psql -U postgres -q -t -A -o geoip_blocks_data_${i}.csv -c "select start_ip_num, end_ip_num,end_ip_num-start_ip_num as end_ip_diff,location_id,start_ip,end_ip from blocks order by start_ip_num offset $i limit 1000000;" geoipdb
done