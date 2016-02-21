import Dict
import Effects exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp
import Task exposing (Task)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Signal exposing (Mailbox, Address, mailbox, message)
import Task exposing (Task, andThen)
import Effects exposing (Effects, Never)
import StartApp

import ElmFire
import ElmFire.Dict
import ElmFire.Op


type Action = Noop | FromServer (Dict.Dict String Model) | Toggle Int


type Status = Open | Closed


type alias Model = List Status

--------------------------------------------------------------------------------

firebaseUrl : String
firebaseUrl = "https://shining-inferno-6056.firebaseio.com"


modelEncoder : List Status -> JE.Value
modelEncoder model =
  let
    statusToBool status =
      case status of
        Open -> True
        Closed -> False

  in
    JE.list (List.map (\status -> JE.bool (statusToBool status)) model)


modelDecoder : JD.Decoder (List Status)
modelDecoder =
  let
    boolToStatus bool =
      case bool of
        True -> Open
        False -> Closed

  in
    JD.list (JD.bool `JD.andThen` (\bool -> JD.succeed (boolToStatus bool)))


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
  Task.toMaybe >> Task.map (always (Noop)) >> Effects.task


-- Mirror Firebase's content as the model's items
-- initialTask : Task Error (Task Error ())
-- inputItems : Signal ???
(initialTask, inputItems) =
  ElmFire.Dict.mirror syncConfig


initialModel : Model
initialModel = []


initialEffect : Effects Action
initialEffect = initialTask |> kickOff

--------------------------------------------------------------------------------

update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Noop ->
      ( model, Effects.none )

    FromServer dict ->
      ( Maybe.withDefault [] (Dict.get "sections" dict), Effects.none )

    Toggle toggleIndex ->
      let
        toggleStatus status =
          case status of
            Open -> Closed
            Closed -> Open

        toggleOnIndex index status =
          if index == toggleIndex
            then toggleStatus status
            else status

        updatedModel =
          List.indexedMap toggleOnIndex model

      in
        ( updatedModel, effectModel <| ElmFire.Op.insert "sections" updatedModel )

--------------------------------------------------------------------------------

view : Signal.Address Action -> Model -> Html
view address model =
  let
    sectionView index status =
      let
        color =
          case status of
            Open -> "green"
            Closed -> "red"

      in
        div
          [ style [( "background-color", color )]
          , onDoubleClick address (Toggle index)
          ]
          [ text "Section" ]

  in
    div [] (List.indexedMap sectionView model)

--------------------------------------------------------------------------------

config : StartApp.Config Model Action
config =
  { init = ( initialModel, initialEffect )
  , update = update
  , view = view
  , inputs = [ Signal.map FromServer inputItems ]
  }


app : StartApp.App Model
app = StartApp.start config


port runEffects : Signal (Task Never ())
port runEffects = app.tasks


main : Signal Html
main = app.html

