/* Drops the 'sis' data base. */
conn = new Mongo();
db = conn.getDB('sis')
db.dropDatabase();
