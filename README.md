# FOLIO-user-import
Repo for maniplating csv into JSON for FOLIO ingest

BannerJsonify takes a pipe-delimited file provided by campus IT, splits the file into 50 record segments, and then turns each file into the correctly formatted JSON for user data ingest. 

Patron import is modified version of mod-user import example. For each 50 record json file it imports until all files have been imported. 
