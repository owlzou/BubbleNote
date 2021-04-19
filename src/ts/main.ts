//Capacitor
import { initDB, saveEntry, deleteEntry, get, getCount, Message } from "./db_capacitor"
import { Capacitor } from "@capacitor/core"
import { SplashScreen } from '@capacitor/splash-screen';
import { Clipboard } from '@capacitor/clipboard';
//TAURI
import { promisified } from 'tauri/api/tauri'
//依赖
import { nanoid } from 'nanoid'
import "/node_modules/material-design-lite/material.min.css"
import "vanilla-ripplejs"
//src
import "../assets/index.styl"
var Elm = require('../Main.elm').Elm;
const pkg = require("../../package.json")

type Flag =
    {
        data: Array<Message>
        , count: number
        , platform: String
        , version: String
    }

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

    await initDB(pkg.version);

    SplashScreen.hide();

    const data = await get(100, 0);
    const count = (await getCount())[0]["count(*)"];

    const flags: Flag = { data: data, count: count, platform: "Android", version: pkg.version }

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: flags,
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

    app.ports.copy.subscribe(async (content) => {
        await Clipboard.write({
            string: content
        });
        app.ports.sendSnackbar.send("复制成功")
    })
}



/* ---------------------------------- TAURI --------------------------------- */
//https://tauri.studio/en/docs/api/js/
async function initTauri() {
    console.log("ENV: TAURI")
    //init database
    await promisified({ cmd: 'init', version: pkg.version });

    const data = await promisified({ cmd: 'get' }) as Array<Message>;
    const count = await promisified({ cmd: "getCount" }) as number;
    const flags: Flag = { data: data, count: count, platform: "Desktop", version: pkg.version }

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: flags
    });
    //保存
    app.ports.saveEntry.subscribe((msg: Message) => {
        if (msg.id === "") { msg.id = nanoid() }
        promisified({ cmd: 'saveEntry', msg: msg }).then(_ => { app.ports.afterSave.send(msg) })
    });

    app.ports.deleteEntry.subscribe((id: string) => {
        promisified({ cmd: 'deleteEntry', id: id }).then(_ => { app.ports.afterDelete.send(id) })
    })

    // app.ports.copy.subscribe((content) => { app.ports.sendSnackbar.send(copy(content)) })
}

/* -------------------------------- Web 测试用代码 ------------------------------- */

function initWeb() {
    console.log("ENV: Web")

    let data = [
        { "id": "abcde", "content": "#Test TAG#", "date": 1617030253012 },
        { "id": "efgge", "content": "https://github.com/", "date": 1617030173784 },
        { "content": "#TAG# AND TEXT", "date": 1618126244323, "id": "N3Tkf5qOcqtUt3SmbLT08" },
        { "content": "#NOT TAG", "date": 1618129529618, "id": "ngZ39WNVEYAQXf8yYVhk8" },
        { "content": "https://github.com/ #TAGS#", "date": 1618134126056, "id": "9LYVnGP7zRWnR446ij0CL" },
        { "content": "dummy", "date": 1618134126057, "id": "9LYVnGP7zRWnR446i3422" }
    ];
    const flags: Flag = { data: data, count: data.length, platform: "Web", version: pkg.version }

    const app = Elm.Main.init({
        node: document.getElementById("app"),
        flags: flags
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

    app.ports.copy.subscribe((content) => { app.ports.sendSnackbar.send(copy(content)) })

}

/* ----------------------------------- 共用 ----------------------------------- */

// document.execCommand 未来会被废弃
function copy(content: string): string {
    //console.log("[Copy]", content);
    let input = document.createElement('input');
    input.value = content;
    document.body.appendChild(input);
    input.select();
    const success = document.execCommand("copy");
    document.body.removeChild(input);

    /* if (!success) {
        if (navigator.permissions) {
            navigator.permissions.query({ name: 'clipboard-write' }).then(async function (result) {
                if (result.state === 'granted') {
                    await navigator.clipboard.writeText(content);
                    return "复制成功"
                } else if (result.state === 'prompt') {
                    return "复制失败"
                } else {
                    return "复制失败"
                }
            });
        } else { return "复制失败" }
    } else {
        return "复制成功"
    } */

    return success ? "复制成功" : "复制失败"
}