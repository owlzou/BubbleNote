
import { CapacitorSQLite, SQLiteConnection, SQLiteDBConnection } from "@capacitor-community/sqlite";
const sqlitePlugin: any = CapacitorSQLite;
const sqlite = new SQLiteConnection(sqlitePlugin);
var db: SQLiteDBConnection;
//https://github.com/capacitor-community/sqlite/blob/master/docs/API.md

export type Message = {
  id: string
  , content: string
  , date: number
}

async function connection(): Promise<SQLiteDBConnection> {
  try {
    const db = await sqlite.createConnection("bubble", false, "no-encryption", 1);
    if (db) {
      return Promise.resolve(db);
    }
    else {
      return Promise.reject("No returned connection")
    }
  } catch (err) {
    return Promise.reject(err)
  }
}

/**
 * 初始化数据库
 *
 */
export async function initDB() {
  const createTablesExecuteSet = `
    CREATE TABLE IF NOT EXISTS notes(
      id TEXT PRIMARY KEY NOT NULL,
      content TEXT NOT NULL,
      date INTEGER
    )
  `;

  //建表
  try {
    db = await connection();
    await db.open();
    await db.execute(createTablesExecuteSet);
  } catch (err) {
    return Promise.reject(err)
  }

}
/**
 * 向数据库内插入数据
 *
 * @export 
 * @param {Message} entry 要插入的数据
 * @returns {string} 返回插入数据的 id
 */
export async function saveEntry(entry: Message): Promise<void> {
  const saveEntryExecute = `INSERT INTO notes (id, content, date) VALUES (?,?,?) ON CONFLICT (id) DO UPDATE SET content = ?`
  try {
    await db.open();
    await db.run(saveEntryExecute, [entry.id, entry.content, entry.date, entry.content])
    return Promise.resolve()
  } catch (err) {
    return Promise.reject(err)
  }

}
/**
 * 删除数据
 *
 * @export
 * @param {number} id
 * @returns
 */
export async function deleteEntry(id: string) {
  const deleteEntryExecute = `DELETE FROM notes WHERE ID = ?`
  try {
    await db.open();
    await db.run(deleteEntryExecute, [id])
    return
  } catch (err) {
    return Promise.reject(err)
  }
}
/**
 * 提取最新x条数据
 *
 * @export
 * @param {number} count 提取量
 * @param {number} offset 偏移量
 * @returns {Promise<Array<Message>>}
 */
export async function get(count: number, offset: number): Promise<Array<Message>> {
  const getEntryExecute = `SELECT id,content,date FROM notes ORDER BY date DESC`
  try {
    await db.open();
    let values = await db.query(getEntryExecute, [])
    return Promise.resolve(values.values)
  } catch (err) {
    return Promise.reject(err)
  }
}
/**
 * 返回数据库中笔记条数
 *
 * @export
 * @return {*}  {Promise<number>}
 */
export async function getCount(): Promise<any> {
  const execute = `SELECT count(*) FROM notes`
  try {
    await db.open()
    let values = await db.query(execute, [])
    return Promise.resolve(values.values)
  } catch (err) {
    return Promise.reject(err)
  }
}