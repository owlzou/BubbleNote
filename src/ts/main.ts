//Capacitor
import { initDB, saveEntry, deleteEntry, get, getCount, Message } from "./db_capacitor"
import { Capacitor } from "@capacitor/core"
import { SplashScreen } from '@capacitor/splash-screen';
//TAURI
import { promisified } from 'tauri/api/tauri'
//依赖
import { nanoid } from 'nanoid'
import "/node_modules/material-design-lite/material.min.css"
import "vanilla-ripplejs"
//src
import "../assets/index.styl"
var Elm = require('../Main.elm').Elm;

/* ----------------------------------- 初始化 ---------------------------------- */
if ((window as any).__TAURI__) {
    initTauri();
} else if (Capacitor.getPlatform() !== "web") {
    initMobile()
} else {
    initWeb()
}

/* ---------------------------------- 手机初始化 --------------------------------- */

async function initMobile() {
    console.log("ENV: Android")

    await initDB();

    SplashScreen.hide();

    const data = await get(100, 0);
    const count = (await getCount())[0]["count(*)"];

    //console.log(`send_data: ${JSON.stringify({ data: data, count: count, platform: "Android" })}`)

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: { data: data, count: count, platform: "Android" },
    });
    //保存
    app.ports.saveEntry.subscribe((msg: Message) => {
        if (msg.id === "") { msg.id = nanoid() }
        saveEntry(msg).then(_ => {
            app.ports.afterSave.send(msg)
        })
    });

    app.ports.deleteEntry.subscribe((id: string) => {
        deleteEntry(id)
        app.ports.afterDelete.send(id)
    })
}



/* ---------------------------------- TAURI --------------------------------- */
//https://tauri.studio/en/docs/api/js/
async function initTauri() {
    console.log("ENV: TAURI")
    //init database
    await promisified({ cmd: 'init' });

    const data = await promisified({ cmd: 'get' });
    const count = await promisified({ cmd: "getCount" });

    SplashScreen.hide();

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: { data: data, count: count, platform: "Desktop" }
    });
    //保存
    app.ports.saveEntry.subscribe((msg: Message) => {
        if (msg.id === "") { msg.id = nanoid() }
        promisified({ cmd: 'saveEntry', msg: msg }).then(_ => { app.ports.afterSave.send(msg) })
    });

    app.ports.deleteEntry.subscribe((id: string) => {
        promisified({ cmd: 'deleteEntry', id: id }).then(_ => { app.ports.afterDelete.send(id) })
    })
}

/* -------------------------------- Web 测试用代码 ------------------------------- */

function initWeb() {
    console.log("ENV: Web")

    let data = [{ "id": "abcde", "content": "Test1", "date": 1617030253012 }, { "id": "efgge", "content": "Test2", "date": 1617030173784 }];

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: { data: data, count: data.length, platform: "Web" }
    });

    // 
    app.ports.saveEntry.subscribe((msg) => {
        if (msg.id === "") {
            msg.id = nanoid()
            console.log("[Save]", msg);
        }
        else {
            console.log("[Update]", msg)
        }
        app.ports.afterSave.send(msg)
    });

    app.ports.deleteEntry.subscribe((id) => {
        console.log("[Delete]", id)
        app.ports.afterDelete.send(id)
    })

}

