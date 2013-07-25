::xo::lib::require tspam

set filename "/web/data/mail/cur/20111026T174414.1319651054_7fe1f893e700"
set is_spam [tspam::classify $filename]
doc_return 200 text/plain is_spam=$is_spam