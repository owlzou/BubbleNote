module Icons
    exposing
        ( alertCircle
        , book
        , check
        , copy
        , github
        , menu
        , moon
        , send
        , sun
        , trash2
        , xCircle
        )

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)


svgFeatherIcon : String -> List (Svg msg) -> Html msg
svgFeatherIcon className =
    svg
        [ class <| "feather feather-" ++ className
        , fill "none"
        , height "24"
        , stroke "currentColor"
        , strokeLinecap "round"
        , strokeLinejoin "round"
        , strokeWidth "2"
        , viewBox "0 0 24 24"
        , width "24"
        ]


alertCircle : Html msg
alertCircle =
    svgFeatherIcon "alert-circle"
        [ Svg.circle [ cx "12", cy "12", r "10" ] []
        , Svg.line [ x1 "12", y1 "8", x2 "12", y2 "12" ] []
        , Svg.line [ x1 "12", y1 "16", x2 "12.01", y2 "16" ] []
        ]


book : Html msg
book =
    svgFeatherIcon "book"
        [ Svg.path [ d "M4 19.5A2.5 2.5 0 0 1 6.5 17H20" ] []
        , Svg.path [ d "M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" ] []
        ]


check : Html msg
check =
    svgFeatherIcon "check"
        [ Svg.polyline [ points "20 6 9 17 4 12" ] []
        ]


copy : Html msg
copy =
    svgFeatherIcon "copy"
        [ Svg.rect [ Svg.Attributes.x "9", y "9", width "13", height "13", rx "2", ry "2" ] []
        , Svg.path [ d "M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" ] []
        ]


github : Html msg
github =
    svgFeatherIcon "github"
        [ Svg.path [ d "M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" ] []
        ]


menu : Html msg
menu =
    svgFeatherIcon "menu"
        [ Svg.line [ x1 "3", y1 "12", x2 "21", y2 "12" ] []
        , Svg.line [ x1 "3", y1 "6", x2 "21", y2 "6" ] []
        , Svg.line [ x1 "3", y1 "18", x2 "21", y2 "18" ] []
        ]


moon : Html msg
moon =
    svgFeatherIcon "moon"
        [ Svg.path [ d "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" ] []
        ]


send : Html msg
send =
    svgFeatherIcon "send"
        [ Svg.line [ x1 "22", y1 "2", x2 "11", y2 "13" ] []
        , Svg.polygon [ points "22 2 15 22 11 13 2 9 22 2" ] []
        ]


sun : Html msg
sun =
    svgFeatherIcon "sun"
        [ Svg.circle [ cx "12", cy "12", r "5" ] []
        , Svg.line [ x1 "12", y1 "1", x2 "12", y2 "3" ] []
        , Svg.line [ x1 "12", y1 "21", x2 "12", y2 "23" ] []
        , Svg.line [ x1 "4.22", y1 "4.22", x2 "5.64", y2 "5.64" ] []
        , Svg.line [ x1 "18.36", y1 "18.36", x2 "19.78", y2 "19.78" ] []
        , Svg.line [ x1 "1", y1 "12", x2 "3", y2 "12" ] []
        , Svg.line [ x1 "21", y1 "12", x2 "23", y2 "12" ] []
        , Svg.line [ x1 "4.22", y1 "19.78", x2 "5.64", y2 "18.36" ] []
        , Svg.line [ x1 "18.36", y1 "5.64", x2 "19.78", y2 "4.22" ] []
        ]


trash2 : Html msg
trash2 =
    svgFeatherIcon "trash-2"
        [ Svg.polyline [ points "3 6 5 6 21 6" ] []
        , Svg.path [ d "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" ] []
        , Svg.line [ x1 "10", y1 "11", x2 "10", y2 "17" ] []
        , Svg.line [ x1 "14", y1 "11", x2 "14", y2 "17" ] []
        ]


xCircle : Html msg
xCircle =
    svgFeatherIcon "x-circle"
        [ Svg.circle [ cx "12", cy "12", r "10" ] []
        , Svg.line [ x1 "15", y1 "9", x2 "9", y2 "15" ] []
        , Svg.line [ x1 "9", y1 "9", x2 "15", y2 "15" ] []
        ]