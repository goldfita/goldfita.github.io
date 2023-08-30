from string import split

try:
    dict
except:
    def dict(sequence):
        resultDict = {}
        for key, value in sequence:
            resultDict[key] = value
        return resultDict
    
def __get_db_login(file_name,delim):
    items = ''.join(open("/var/lib/asterisk/agi-bin/"+file_name).readlines()).strip().splitlines()
    return dict(map(split,items,(delim,)*len(items)))

def get_mysql_connection():
    import MySQLdb
    connect = __get_db_login("login.db","==")
    db = MySQLdb.connect(db=connect["name"],
                         host=connect["host"],
                         port=int(connect["port"]),
                         user=connect["user"],
                         passwd=connect["password"])
    return db

def get_jdbc_connection():
    from java.lang import * 
    from java.sql import *

    connect = __get_db_login("login.db","==")
    Class.forName(connect["driver"]).newInstance()
    db = DriverManager.getConnection("%s//%s:%s/%s?%s%s%s%s" %
                                     (connect["path"],
                                      connect["host"],connect["port"],
                                      connect["name"],
                                      "user=",connect["user"],
                                      "&password=",connect["password"]))
    return db
