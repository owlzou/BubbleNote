port module Main exposing (main)

import Browser
import Credits
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, header, img, input, label, li, main_, nav, p, span, text, textarea, th, ul)
import Html.Attributes exposing (checked, class, href, placeholder, src, style, target, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Icons
import Json.Decode as D
import Json.Encode as E
import List
import Task
import Time



-- MAIN


main : Program E.Value Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type alias ID =
    String


type Platform
    = Web
    | Android
    | Desktop


type alias Message =
    { id : ID
    , content : String
    , date : Int
    }


type alias Model =
    { messages : Dict ID Message
    , input : String
    , date : Int
    , count : Int
    , activeMessage : Maybe Message
    , activeInput : String
    , zone : Time.Zone
    , drawerOpen : Bool
    , delDialogOpen : Bool
    , aboutDialogOpen : Bool
    , nightMode : Bool
    , platform : Platform
    }


type alias InitData =
    { data : List Message
    , count : Int
    , platform : Platform
    }


init : E.Value -> ( Model, Cmd Msg )
init val =
    case D.decodeValue jsonToData val of
        Ok value ->
            ( { initModel | messages = Dict.fromList (List.map (\i -> ( i.id, i )) value.data), count = value.count, platform = value.platform }, Task.perform AdjustTimeZone Time.here )

        Err _ ->
            ( initModel, Task.perform AdjustTimeZone Time.here )


initModel : Model
initModel =
    { messages = Dict.empty
    , input = ""
    , activeMessage = Nothing
    , activeInput = ""
    , date = 0
    , count = 0

    -- 时间
    , zone = Time.utc
    , drawerOpen = False
    , delDialogOpen = False
    , aboutDialogOpen = False
    , nightMode = False
    , platform = Web
    }



-- UPDATE


type Msg
    = Enter -- 获取时间
    | PastEnter Time.Posix --得到返回的时间
    | AfterSaveEnter Message --得到数据库返回的 分配的 ID
    | OnInput String
    | OnFloatActionInput String
    | Update
    | Delete ID
    | AfterDelete ID
    | ClickOnBubble Message
    | Close
    | AdjustTimeZone Time.Zone -- 时间
    | NoOp
    | SwitchDrawer Bool
    | SwitchNightMode
    | SwitchDelDialog Bool
    | SwitchAboutDialog Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Enter ->
            if String.length (String.trim model.input) > 0 then
                ( model, Task.perform PastEnter Time.now )

            else
                ( { model | input = "" }, Cmd.none )

        PastEnter newTime ->
            let
                message =
                    { id = "", content = model.input, date = Time.posixToMillis newTime }
            in
            ( { model | date = Time.posixToMillis newTime, count = model.count + 1 }
            , saveEntry message
            )

        AfterSaveEnter message ->
            ( { model
                | messages = upsertDict message model.messages
                , input = ""
              }
            , Cmd.none
            )

        Update ->
            let
                cmd =
                    case model.activeMessage of
                        Just m ->
                            saveEntry m

                        Nothing ->
                            Cmd.none
            in
            ( { model | activeMessage = Nothing }, cmd )

        OnInput str ->
            ( { model | input = str }, Cmd.none )

        OnFloatActionInput str ->
            let
                am =
                    Maybe.map (\i -> { i | content = str }) model.activeMessage
            in
            ( { model | activeMessage = am }, Cmd.none )

        ClickOnBubble message ->
            ( { model | activeMessage = Just message, activeInput = message.content }, Cmd.none )

        AdjustTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        Delete id ->
            ( { model | activeMessage = Nothing, delDialogOpen = False }, deleteEntry id )

        AfterDelete id ->
            ( { model | messages = Dict.remove id model.messages, count = model.count - 1 }, Cmd.none )

        Close ->
            ( { model | activeMessage = Nothing }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        SwitchDrawer b ->
            ( { model | drawerOpen = b }, Cmd.none )

        SwitchNightMode ->
            ( { model | nightMode = not model.nightMode }, Cmd.none )

        SwitchDelDialog b ->
            ( { model | delDialogOpen = b }, Cmd.none )

        SwitchAboutDialog b ->
            ( { model | aboutDialogOpen = b, drawerOpen = False }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        classDarkmode =
            if model.nightMode then
                class "dark-mode"

            else
                class ""

        drawerVisible =
            if model.drawerOpen then
                class "is-visible"

            else
                class ""
    in
    div
        [ class "mdl-layout mdl-layout--fixed-header", classDarkmode ]
        [ header [ class "mdl-layout__header" ]
            [ div [ class "mdl-layout__drawer-button", onClick (SwitchDrawer True) ] [ Icons.menu ]
            , div [ class "mdl-layout__header-row" ]
                [ -- TITLE
                  span [ class "mdl-layout-title" ] [ text "BubbleNote" ]
                ]
            ]

        -- DRAWER
        , lazy3 drawer model.drawerOpen model.count model.nightMode

        -- CONTENT
        , main_ [ class "mdl-layout__content" ]
            [ lazy viewHistory model.messages
            , lazy viewInput model.input
            ]

        -- DIALOGS
        , case model.activeMessage of
            Just msg ->
                div [] [ floatAction model.activeInput, delDialog model.delDialogOpen msg ]

            Nothing ->
                span [] []
        , lazy2 aboutDialog model.aboutDialogOpen model.platform

        -- 遮罩
        , div [ class "mdl-layout__obfuscator", drawerVisible, onClick (SwitchDrawer False) ] []
        ]


viewHistory : Dict ID Message -> Html Msg
viewHistory messages =
    let
        indexedBubble message =
            ( message.id, bubble message )
    in
    Keyed.node "div" [ class "history" ] <| List.map indexedBubble (List.sortBy .date <| List.map (\( _, data ) -> data) <| Dict.toList messages)


viewInput : String -> Html Msg
viewInput str =
    div [ class "input" ]
        [ input [ onInput OnInput, onEnter Enter, placeholder "Input something ...", value str ] []
        , iconButton [ onClick Enter, class "send-button" ] [ Icons.send ]
        ]


drawer : Bool -> Int -> Bool -> Html Msg
drawer open count nightMode =
    div
        [ class "mdl-layout__drawer"
        , if open then
            class "is-visible"

          else
            class ""
        ]
        [ img [ src "./assets/aaron-burden-Q_5UTUA58Z4-unsplash.jpg" ] []
        , ul [ class "mdl-list" ]
            [ li [ class "mdl-list__item", style "position" "relative" ]
                [ div [ class "material-icons icons" ] [ Icons.book ]
                , span [ class "mdl-list__item-primary-content" ] [ text "笔记总数" ]
                , span [ class "mdl-list__item-secondary-action" ] [ text (String.fromInt count) ]
                , div [ class "rippleJS" ] []
                ]
            , li [ class "mdl-list__item", style "position" "relative" ]
                [ div [ class "material-icons icons" ]
                    [ if nightMode then
                        Icons.moon

                      else
                        Icons.sun
                    ]
                , span [ class "mdl-list__item-primary-content" ] [ text "夜间模式" ]
                , span [ class "mdl-list__item-secondary-action" ] [ switch nightMode SwitchNightMode ]
                , div [ class "rippleJS" ] []
                ]
            , li [ class "mdl-list__item", style "position" "relative", onClick (SwitchAboutDialog True) ]
                [ div [ class "material-icons icons" ] [ Icons.alertCircle ]
                , span [ class "mdl-list__item-primary-content" ] [ text "关于" ]
                , div [ class "rippleJS" ] []
                ]
            ]
        ]


bubble : Message -> Html Msg
bubble message =
    div [ class "bubble" ]
        [ div [ class "text", onClick (ClickOnBubble message) ]
            [ text message.content
            , div [ class "rippleJS" ] []
            ]
        ]


floatAction : String -> Html Msg
floatAction content =
    div [ class "float-action" ]
        [ textarea [ Html.Attributes.rows 10, placeholder "textarea ...", onInput OnFloatActionInput ] [ text content ]
        , div [ class "menu-down" ]
            [ iconButton [ class "delete-button", onClick (SwitchDelDialog True) ] [ Icons.trash2 ]
            , iconButton [ class "close-button", onClick Close ] [ Icons.xCircle ]
            , iconButton [ class "check-button", onClick Update ] [ Icons.check ]
            ]
        ]


delDialog : Bool -> Message -> Html Msg
delDialog vis msg =
    let
        delDialogVisible =
            if vis then
                class "is-visible"

            else
                class ""
    in
    div [ class "mdl-dialog", delDialogVisible ]
        [ div [ class "mdl-dialog__content" ] [ p [] [ Html.b [] [ text "确定删除？" ] ], p [] [ text msg.content ] ]
        , div [ class "mdl-dialog__actions" ]
            [ button [ class "mdl-button", onClick (Delete msg.id) ] [ text "确定" ]
            , button [ class "mdl-button close", onClick (SwitchDelDialog False) ] [ text "取消" ]
            ]
        ]


aboutDialog : Bool -> Platform -> Html Msg
aboutDialog vis platform =
    let
        delDialogVisible =
            if vis then
                class "is-visible"

            else
                class ""

        for =
            case platform of
                Web ->
                    "for Web"

                Android ->
                    "for Android"

                Desktop ->
                    "for Desktop"
    in
    div [ class "mdl-dialog", delDialogVisible ]
        [ div [ class "mdl-dialog__content" ]
            [ p [] [ Html.b [] [ text "关于" ] ]
            , p [] [ text "BubbleNote v0.1 ", span [ class "sub-text" ] [ text for ] ]
            , p [] [ a [ href "https://github.com/owlzou/BubbleNote", target "_blank" ] [ text "https://github.com/owlzou/BubbleNote" ] ]
            , p [] [ Html.b [] [ text "第三方代码" ] ]
            , case platform of
                Android ->
                    Credits.list (List.append Credits.common Credits.android)

                Desktop ->
                    Credits.list (List.append Credits.common Credits.desktop)

                Web ->
                    Credits.list (List.append Credits.common Credits.web)
            , p [] [ Html.b [] [ text "抽屉图片" ] ]

            -- Photo by <a href="https://unsplash.com/@aaronburden?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Aaron Burden</a> on <a href="https://unsplash.com/s/photos/bubble?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
            , p [] [ text "Photo by ", a [ href "https://unsplash.com/@aaronburden?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText", target "_blank" ] [ text "Aaron Burden" ], text " on ", a [ href "https://unsplash.com/s/photos/bubble?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText", target "_blank" ] [ text "Unsplash" ] ]
            , p [] [ Html.b [] [ text "标题字体" ] ]
            , p [] [ text "Oswald" ]
            ]
        , div [ class "mdl-dialog__actions" ]
            [ button [ class "mdl-button close", onClick (SwitchAboutDialog False) ] [ text "关闭" ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ afterSave AfterSaveEnter, afterDelete AfterDelete ]



-- PORTS
-- 保存数据


port saveEntry : Message -> Cmd msg


port afterSave : (Message -> msg) -> Sub msg



-- 删除数据


port deleteEntry : ID -> Cmd msg


port afterDelete : (ID -> msg) -> Sub msg



-- Helper


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                D.succeed msg

            else
                D.fail "fail"
    in
    on "keydown" (D.andThen isEnter keyCode)


jsonToMessage : D.Decoder Message
jsonToMessage =
    D.map3 Message (D.field "id" D.string) (D.field "content" D.string) (D.field "date" D.int)


jsonToData : D.Decoder InitData
jsonToData =
    let
        decodePlatform : String -> Platform
        decodePlatform code =
            case code of
                "Web" ->
                    Web

                "Android" ->
                    Android

                "Desktop" ->
                    Desktop

                _ ->
                    Web
    in
    D.map3 InitData (D.field "data" (D.list jsonToMessage)) (D.field "count" D.int) (D.field "platform" (D.map decodePlatform D.string))


updateMessage : Message -> Dict ID Message -> Dict ID Message
updateMessage msg list =
    Dict.update msg.id (Maybe.map (\_ -> msg)) list


upsertDict : Message -> Dict ID Message -> Dict ID Message
upsertDict msg dict =
    case Dict.get msg.id dict of
        Just _ ->
            updateMessage msg dict

        Nothing ->
            Dict.insert msg.id msg dict

-- MDL

iconButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
iconButton attr list =
    Html.button (List.append [ class "mdl-button mdl-button--icon" ] attr)
        (List.append [ div [ class "rippleJS fill" ] [] ] list)


switch : Bool -> Msg -> Html Msg
switch bool switchMsg =
    label
        [ class "mdl-switch is-upgraded"
        , if bool then
            class "is-checked"

          else
            class ""
        ]
        [ input [ class "mdl-switch__input", type_ "checkbox", checked bool ] []
        , div [ class "mdl-switch__track" ] []
        , div [ class "mdl-switch__thumb" ] []
        , span [ class "mdl-switch__ripple-container", class "rippleJS fill", onClick switchMsg ]
            [ span [ class "mdl-ripple is-animating" ] []
            ]
        ]

