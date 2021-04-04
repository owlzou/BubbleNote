module Credits exposing (..)

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (href, style, target)


type alias Info =
    { name : String
    , url : String
    , license : String
    }


common : List Info
common =
    [ { name = "elm-feather", url = "https://github.com/feathericons/elm-feather", license = "BSD-3-Clause License" }
    , { name = "Material Design Lite", url = "https://getmdl.io/", license = "Apache License 2.0" }
    , { name = "rippleJS", url = "https://github.com/samthor/rippleJS", license = "MIT" }
    , { name = "Nano ID", url = "https://github.com/ai/nanoid/", license = "MIT" }
    ]


android : List Info
android =
    [ { name = "Capacitor", url = "https://capacitorjs.com/", license = "MIT" }
    , { name = "capacitor-community/sqlite", url = "https://github.com/capacitor-community/sqlite/", license = "MIT" }
    ]


desktop : List Info
desktop =
    [ { name = "TAURI", url = "https://github.com/tauri-apps/tauri", license = "MIT" }
    , { name = "Rusqlite", url = "https://github.com/rusqlite/rusqlite", license = "MIT" }
    ]


web : List Info
web =
    []


list : List Info -> Html msg
list info =
    ul [ style "padding-left" "20px" ]
        (List.map
            (\i -> li [] [ a [ href i.url, target "_blank" ] [ text i.name ] ])
            info
        )
