# For use on Blackstone
kippco <- src_postgres('kippco')
advisories <- tbl(kippco, 'advisories') %>% collect()

#ch <- odbcConnect('Blackstone')

#advisories <- sqlQuery(ch, 'SELECT * FROM advisories')

#close(ch)
