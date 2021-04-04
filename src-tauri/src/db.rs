use rusqlite::{params, Connection, Result, NO_PARAMS};
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Debug, Serialize, Deserialize)]
pub struct Message {
  id: String,
  content: String,
  date: i64,
}

pub fn init_db() -> Result<()> {
  //建立文件夹 如果不存在
  if !Path::new("./data").exists() {
    std::fs::create_dir("./data").expect("Create dir error")
  }
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  conn.execute(
    "CREATE TABLE IF NOT EXISTS notes(
      id TEXT PRIMARY KEY NOT NULL,
      content TEXT NOT NULL,
      date INTEGER
    )",
    params![],
  )?;
  //conn.close();
  Ok(())
}

pub fn save_entry(entry: Message) -> Result<()> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  conn.execute(
      "INSERT INTO notes (id, content, date) VALUES (?1,?2,?3) ON CONFLICT (id) DO UPDATE SET content = ?4",
      params![entry.id, entry.content, entry.date, entry.content],
    )?;
  Ok(())
}

pub fn delete_entry(id: String) -> Result<()> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  conn.execute("DELETE FROM notes WHERE ID = ?1", params![id])?;
  Ok(())
}

pub fn get(_count: i32, _offset: i32) -> Result<Vec<Message>> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  let mut stmt = conn.prepare("SELECT id,content,date FROM notes ORDER BY date DESC")?;
  let mut res = vec![];

  let mut msg_iter = stmt.query(NO_PARAMS)?;
  while let Some(row) = msg_iter.next()? {
    res.push(Message {
      id: row.get(0)?,
      content: row.get(1)?,
      date: row.get(2)?,
    });
  }

  Ok(res)
}

pub fn get_count() -> Result<i32> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  let mut stmt = conn.prepare("SELECT count(*) FROM notes")?;
  let mut num = stmt.query(NO_PARAMS)?;
  
  Ok(num.next()?.unwrap().get(0)?)
}
