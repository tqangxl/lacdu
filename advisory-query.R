# For use on Blackstone
kippco <- src_postgres('kippco')
advisories <- tbl(kippco, 'advisories') %>% collect()
