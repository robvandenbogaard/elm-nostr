port module Main exposing (main)

import Browser
import Html
import Html.Events as Html
import Nostr
import Nostr.ImplementationPossibilities as NIP


port sendMessage : Message -> Cmd msg


port messageReceiver : (Message -> msg) -> Sub msg


type alias Model =
    { url : String
    , message : String
    , relays : List String
    , timeline : List Message
    }


type alias Message =
    { url : String
    , message : String
    }


type Msg
    = GotMessage Message
    | UpdatedUrl String
    | UpdatedMessage String
    | Send
    | Subscribe
    | Unsubscribe


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


init () =
    ( { url = "", message = "", relays = [], timeline = [] }, Cmd.none )


update msg model =
    case msg of
        GotMessage { url, message } ->
            ( { model | timeline = Message url message :: model.timeline }, Cmd.none )

        UpdatedUrl url ->
            ( { model | url = url }, Cmd.none )

        UpdatedMessage message ->
            ( { model | message = message }, Cmd.none )

        Send ->
            ( { model | message = "" }, sendMessage { url = model.url, message = model.message } )

        Subscribe ->
            let
                filter =
                    [ Nostr.filter
                        |> Nostr.onKinds [ NIP.Basic ]
                    ]
            in
            ( model
            , sendMessage
                { url = model.url
                , message = Nostr.subscribe "testsub" filter
                }
            )

        Unsubscribe ->
            ( model
            , sendMessage
                { url = model.url
                , message = Nostr.unsubscribe "testsub"
                }
            )


view model =
    Html.main_ []
        [ Html.aside []
            [ Html.input [ Html.onInput UpdatedUrl ] [ Html.text model.url ]
            , Html.input [ Html.onInput UpdatedMessage ] [ Html.text model.message ]
            , Html.button [ Html.onClick Send ] [ Html.text "Send" ]
            ]
        , Html.aside []
            [ Html.button [ Html.onClick Subscribe ] [ Html.text "Subscribe" ]
            , Html.button [ Html.onClick Unsubscribe ] [ Html.text "Unsubscribe" ]
            ]
        , Html.article []
            [ model.relays
                |> List.map relayItem
                |> Html.ul []
            , model.timeline
                |> List.map timelineItem
                |> Html.ul []
            ]
        ]


relayItem relay =
    Html.li [] [ Html.text relay ]


timelineItem packet =
    Html.li [] [ Html.text <| packet.url ++ ": " ++ packet.message ]


subscriptions model =
    messageReceiver GotMessage
