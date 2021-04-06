use crate::db::Message;
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(tag = "cmd", rename_all = "camelCase")]
pub enum Cmd {
  // your custom commands
  // multiple arguments are allowed
  // note that rename_all = "camelCase": you need to use "myCustomCommand" on JS
  Init {version: String, callback: String, error: String},
  SaveEntry { msg: Message, callback: String, error: String  },
  DeleteEntry { id: String,callback: String, error: String  },
  Get{ callback: String, error: String },
  GetCount{callback: String, error: String }
}
