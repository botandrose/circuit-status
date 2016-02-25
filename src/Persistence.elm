module Persistence (initialEffect, modelUpdates, saveModel) where

import Dict
import Effects exposing (Effects, Never)
import ElmFire
import ElmFire.Dict
import ElmFire.Op
import Json.Decode as JD
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


modelEncoder : Model -> JE.Value
modelEncoder model =
  let
    statusToBool status =
      case status of
        Open -> True
        Closed -> False

    encodeSection ( sectionId, status ) =
      ( toString sectionId, JE.bool <| statusToBool status )

  in
    JE.object <| List.map encodeSection model


modelDecoder : JD.Decoder Model
modelDecoder =
  let
    boolToStatus bool =
      case bool of
        True -> Open
        False -> Closed

    statusDecoder : JD.Decoder Status
    statusDecoder =
      JD.bool `JD.andThen` \bool -> JD.succeed <| boolToStatus bool

    convertKeysToSections : List ( String, Status ) -> JD.Decoder Model
    convertKeysToSections =
      let
        firstToSectionId ( sectionId, status ) =
          ( stringToSectionId sectionId, status )
      in
        JD.succeed << List.map firstToSectionId

  in
    JD.keyValuePairs statusDecoder `JD.andThen` convertKeysToSections


syncConfig : ElmFire.Dict.Config Model
syncConfig =
  { location = ElmFire.fromUrl firebaseUrl
  , orderOptions = ElmFire.noOrder
  , encoder = modelEncoder
  , decoder = modelDecoder
  }


effectModel : ElmFire.Op.Operation Model -> Effects Action
effectModel operation =
  ElmFire.Op.operate
    syncConfig
    operation
  |> kickOff


-- Map any task to an effect, discarding any direct result or error value
kickOff : Task x a -> Effects Action
kickOff =
  Task.toMaybe >> Task.map (always Noop) >> Effects.task


-- Mirror Firebase's content as the model's items
-- initialTask : Task Error (Task Error ())
-- dictSignal : Signal (Dict String v)
( initialTask, firebaseDictUpdates ) =
  ElmFire.Dict.mirror syncConfig


modelUpdates : Signal Model
modelUpdates =
  let
    logFailure dict =
      Debug.log ("no 'sections' key from firebase " ++ toString dict ++ ", defaulting to") initialModel

    extractModel dict =
      Maybe.withDefault (logFailure dict) <| Dict.get "sections" dict

  in
    Signal.map extractModel firebaseDictUpdates


initialEffect : Effects Action
initialEffect = initialTask |> kickOff


saveModel : Model -> Effects Action
saveModel model =
  effectModel <| ElmFire.Op.insert "sections" model

