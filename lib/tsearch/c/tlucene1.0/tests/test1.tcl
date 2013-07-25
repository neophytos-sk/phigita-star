load /opt/naviserver/lib/libnsd.so
load /opt/naviserver/bin/tlucene1.0.so

puts [::xo::lib::lucene tokenize "hello world this is a test"]