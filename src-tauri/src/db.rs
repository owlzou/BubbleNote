use rusqlite::{params, Connection, Result, NO_PARAMS};
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Debug, Serialize, Deserialize)]
pub struct Message {
  id: String,
  content: String,
  date: i64,
}

pub fn init_db(version: String) -> Result<()> {
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
    );
  ",
    NO_PARAMS,
  )?;
  conn.execute(
    "CREATE TABLE IF NOT EXISTS env(
      version TEXT PRIMARY KEY NOT NULL
    )",
    NO_PARAMS,
  )?;
  conn.execute(
    "INSERT INTO env (version) VALUES (?1) ON CONFLICT (version) DO UPDATE SET version = ?2",
    params![version, version],
  )?;

  conn.close().map_err(|e| e.1)?;
  Ok(())
}

pub fn save_entry(entry: Message) -> Result<()> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  conn.execute(
      "INSERT INTO notes (id, content, date) VALUES (?1,?2,?3) ON CONFLICT (id) DO UPDATE SET content = ?4",
      params![entry.id, entry.content, entry.date, entry.content],
    )?;
  conn.close().map_err(|e| e.1)?;
  Ok(())
}

pub fn delete_entry(id: String) -> Result<()> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  conn.execute("DELETE FROM notes WHERE ID = ?1", params![id])?;
  conn.close().map_err(|e| e.1)?;
  Ok(())
}

pub fn get(_count: i32, _offset: i32) -> Result<Vec<Message>> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  let res = {
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
    res
  };
  conn.close().map_err(|e| e.1)?;
  Ok(res)
}

pub fn get_count() -> Result<i32> {
  let conn = Connection::open("./data/bubbleSQLite.db")?;
  let res = {
    let mut stmt = conn.prepare("SELECT count(*) FROM notes")?;
    let mut num = stmt.query(NO_PARAMS)?;
    num.next()?.unwrap().get(0)?
  };
  conn.close().map_err(|e| e.1)?;
  Ok(res)
}
