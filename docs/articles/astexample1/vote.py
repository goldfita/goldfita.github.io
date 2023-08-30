#!/usr/bin/env python

#http://home.cogeco.ca/~camstuff/agi.html
#http://sourceforge.net/projects/mysql-python

import agi
from connect import get_mysql_connection

OPTIONS = "123"

interface = agi.AGI()

select_map = {1: "pink",
              2: "green",
              3: "mahogany"}
select_stmt = 'SELECT votes FROM colors WHERE color="%s"'
update_stmt = 'UPDATE colors SET votes=%d WHERE color="%s"'


try:
    (res,int_res)=interface.Cmd('STREAM FILE voteprompt "%s"' % OPTIONS)
    db = get_mysql_connection()
    color = select_map[int(chr(int_res))]
    db.query(select_stmt % color)
    rs = db.store_result()
    val = rs.fetch_row()[0][0]
    db.query(update_stmt % (val+1,color))
    db.close()
except:
    pass
