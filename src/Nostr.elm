module Nostr exposing (Event)

import Dict exposing (Dict)
import Time


type alias Event =
    { id : Id
    , pubkey : PubKey
    , createdAt : Time.Posix
    , kind : Int
    , content : String
    , tags : Tags
    , sig : Signature
    }


type Id
    = Id String


type PubKey
    = PubKey String


type Signature
    = Signature String


type Tags
    = Tags (Dict String String)
