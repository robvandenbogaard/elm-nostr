module Nostr exposing
    ( Event
    , Filter
    , Relay
    , Session
    , filter
    , noTags
    , onKinds
    , publish
    , subscribe
    , unsubscribe
    )

import Dict exposing (Dict)
import Json.Encode as Encode
import Nostr.ImplementationPossibilities as NIP
import Time


type alias Session =
    { relays : List Relay
    }


type alias Relay =
    { address : String
    , inbox : List Event
    , outbox : List Event
    }


type alias Event =
    { id : Id
    , pubKey : PubKey
    , createdAt : Time.Posix
    , kind : NIP.Kind
    , content : String
    , tags : Tags
    , sig : Signature
    }


type alias Filter =
    { ids : List Id
    , authors : List PubKey
    , kinds : List NIP.Kind
    , tags : Tags
    , since : Maybe Time.Posix
    , until : Maybe Time.Posix
    , limit : Int
    }


type Id
    = Id String


type PubKey
    = PubKey String


type Signature
    = Signature String


type Tags
    = Tags (Dict String String)


noTags =
    Tags Dict.empty


idString (Id value) =
    value


pubKeyString (PubKey value) =
    value


signatureString (Signature value) =
    value


tagsString (Tags tags) =
    tags
        |> Dict.toList
        |> List.map (\( k, v ) -> k ++ "," ++ v)
        |> String.join ","


sign : Event -> Signature
sign { id, pubKey, createdAt, kind, content, tags } =
    [ "0"
    , pubKeyString pubKey
    , Time.posixToMillis createdAt
        |> String.fromInt
    , NIP.toInt kind
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""
    , tagsString tags
    , content
    ]
        |> String.join ","
        |> (++) "["
        |> String.append "]"
        |> escape
        |> sha256
        |> Signature


escape =
    identity


sha256 =
    identity


publish event =
    Encode.list identity [ Encode.string "EVENT", encodeEvent event ]
        |> Encode.encode 0


subscribe id filters =
    Encode.list identity (Encode.string "REQ" :: Encode.string id :: List.map encodeFilter filters)
        |> Encode.encode 0


unsubscribe id =
    Encode.list Encode.string [ "CLOSE", id ]
        |> Encode.encode 0


filter =
    Filter [] [] [] noTags Nothing Nothing 10


onKinds kinds f =
    { f | kinds = kinds }


encodeEvent event =
    Encode.object
        []


encodeFilter f =
    Encode.object
        []
