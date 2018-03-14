#!/bin/bash

psql -p 20004 postgres -c 'ALTER NODE coord1 WITH (HOST='pgnode2', PORT=20004)'
psql -p 20004 postgres -c 'CREATE NODE coord2 WITH (TYPE='coordinator', HOST='pgnode3', PORT=20005)'
psql -p 20004 postgres -c 'CREATE NODE datanode1 WITH (TYPE='datanode', HOST='pgnode2', PORT=20008, PRIMARY, PREFERRED)'
psql -p 20004 postgres -c 'CREATE NODE datanode2 WITH (TYPE='datanode', HOST='pgnode3', PORT=20009)'
psql -p 20004 postgres -c 'CREATE NODE coord1 WITH (TYPE='coordinator', HOST='pgnode2', PORT=20004)'
psql -p 20004 postgres -c 'ALTER NODE coord2 WITH (HOST='pgnode3', PORT=20005)'
psql -p 20004 postgres -c 'CREATE NODE datanode1 WITH (TYPE='datanode', HOST='pgnode2', PORT=20008, PRIMARY)'
psql -p 20004 postgres -c 'CREATE NODE datanode2 WITH (TYPE='datanode', HOST='pgnode3', PORT=20009, PREFERRED)'
