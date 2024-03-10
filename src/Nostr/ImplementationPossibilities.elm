module Nostr.ImplementationPossibilities exposing (Kind(..), decode, encode, fromInt, toInt)

import Json.Decode as Decode
import Json.Encode as Encode


type Kind
    = Meta
    | Basic
    | Unknown


toInt : Kind -> Maybe Int
toInt kind =
    case kind of
        Meta ->
            Just 0

        Basic ->
            Just 1

        Unknown ->
            Nothing


fromInt kind =
    case kind of
        0 ->
            Meta

        1 ->
            Basic

        _ ->
            Unknown


decode =
    Decode.int
        |> Decode.andThen (fromInt >> Decode.succeed)


encode =
    toInt
        >> Maybe.map Encode.int
        >> Maybe.withDefault Encode.null
