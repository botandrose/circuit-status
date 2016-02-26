module Persistence (initialEffect, sectionsUpdates, saveSections) where

import Dict
import Effects exposing (Effects, Never)
import ElmFire
import ElmFire.Dict
import ElmFire.Op
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Model exposing (..)
import Task exposing (Task)


firebaseUrl : String
firebaseUrl = "https://shining-inferno-6056.firebaseio.com"


stringToSectionId : String -> SectionId
stringToSectionId string =
  let
    detectSectionId memo sectionId =
      if toString sectionId == string
        then sectionId
        else memo

    sectionId =
      List.foldr detectSectionId CaveLeft sectionIds

  in
    if toString sectionId == string
      then sectionId
      else Debug.log ("unmatched sectionId string: \"" ++ string ++ "\", defaulting to") sectionId


sectionsEncoder : (List Section) -> JE.Value
sectionsEncoder sections =
  let
    statusToBool status =
      case status of
        Open -> True
        Closed -> False

    encodeSection { sectionId, status } =
      JE.object
        [ ( "sectionId", JE.string <| toString sectionId )
        , ( "status", JE.bool <| statusToBool status )
        ]

  in
    JE.list <| List.map encodeSection sections


sectionsDecoder : JD.Decoder (List Section)
sectionsDecoder =
  let
    boolToStatus bool =
      case bool of
        True -> Open
        False -> Closed

    statusDecoder : JD.Decoder Status
    statusDecoder =
      JD.bool `JD.andThen` \bool -> JD.succeed <| boolToStatus bool

    convertKeysToSections : JD.Decoder SectionId
    convertKeysToSections =
      JD.string `JD.andThen` \string -> JD.succeed <| stringToSectionId string

  in
    JD.list
      <| JD.object2 Section
        ("sectionId" := convertKeysToSections)
        ("status" := statusDecoder)


syncConfig : ElmFire.Dict.Config (List Section)
syncConfig =
  { location = ElmFire.fromUrl firebaseUrl
  , orderOptions = ElmFire.noOrder
  , encoder = sectionsEncoder
  , decoder = sectionsDecoder
  }


effectSections : ElmFire.Op.Operation (List Section) -> Effects Action
effectSections operation =
  ElmFire.Op.operate
    syncConfig
    operation
  |> kickOff


-- Map any task to an effect, discarding any direct result or error value
kickOff : Task x a -> Effects Action
kickOff =
  Task.toMaybe >> Task.map (always Noop) >> Effects.task


-- Mirror Firebase's content as the sections's items
-- initialTask : Task Error (Task Error ())
-- dictSignal : Signal (Dict String v)
( initialTask, firebaseDictUpdates ) =
  ElmFire.Dict.mirror syncConfig


sectionsUpdates : Signal (List Section)
sectionsUpdates =
  let
    logFailure dict =
      Debug.log ("no 'sections' key from firebase " ++ toString dict ++ ", defaulting to") initialModel.sections

    extractSections dict =
      Maybe.withDefault (logFailure dict) <| Dict.get "sections" dict

  in
    Signal.map extractSections firebaseDictUpdates


initialEffect : Effects Action
initialEffect = initialTask |> kickOff


saveSections : List Section -> Effects Action
saveSections sections =
  effectSections <| ElmFire.Op.insert "sections" sections

