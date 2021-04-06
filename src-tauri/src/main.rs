#![cfg_attr(
  all(not(debug_assertions), target_os = "windows"),
  windows_subsystem = "windows"
)]

mod cmd;
mod db;

/* ---------------------------------- MAIN ---------------------------------- */

fn main() {
  tauri::AppBuilder::new()
    .invoke_handler(|_webview, arg| {
      use cmd::Cmd::*;
      match serde_json::from_str(arg) {
        Err(e) => Err(e.to_string()),
        Ok(command) => {
          match command {
            Init { version,  callback, error } => tauri::execute_promise(
              _webview,
              move || Ok(db::init_db(version).expect("Database initialization error")),
              callback,
              error,
            ),
            SaveEntry {
              msg,
              callback,
              error,
            } => tauri::execute_promise(
              _webview,
              move || Ok(db::save_entry(msg).expect("Save note error")),
              callback,
              error,
            ),
            DeleteEntry {
              id,
              callback,
              error,
            } => tauri::execute_promise(
              _webview,
              move || Ok(db::delete_entry(id).expect("Delete note error")),
              callback,
              error,
            ),
            Get { callback, error } => tauri::execute_promise(
              _webview,
              move || Ok(db::get(100, 0).expect("Read database error")),
              callback,
              error,
            ),
            GetCount { callback, error } => tauri::execute_promise(
              _webview,
              move || Ok(db::get_count().expect("Read database error")),
              callback,
              error,
            ),
          }
          Ok(())
        }
      }
    })
    .build()
    .run();
}
