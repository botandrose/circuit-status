import Dict
import Effects exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
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


type Status = Open | Closed


statusToBool : Status -> Bool
statusToBool status =
  case status of
    Open -> True
    Closed -> False


boolToStatus : Bool -> Status
boolToStatus bool =
  case bool of
    True -> Open
    False -> Closed


type Action = Noop | FromServer (Dict.Dict String Model)



type alias Model = List Status


firebaseUrl : String
firebaseUrl = "https://shining-inferno-6056.firebaseio.com"


-- Mirror Firebase's content as the model's items

-- initialTask : Task Error (Task Error ())
-- inputItems : Signal ???
(initialTask, inputItems) =
  ElmFire.Dict.mirror syncConfig


--------------------------------------------------------------------------------

syncConfig : ElmFire.Dict.Config Model
syncConfig =
  { location = ElmFire.fromUrl firebaseUrl
  , orderOptions = ElmFire.noOrder
  , encoder =
    \model ->
      JE.object [ ("sections", JE.list (List.map (\status -> JE.bool (statusToBool status)) model)) ]
  , decoder =
    ( "sections" := (JD.list (JD.bool `JD.andThen` (\bool -> JD.succeed (boolToStatus bool)))) )
  }

--------------------------------------------------------------------------------

initialModel : Model
initialModel = []


initialEffect : Effects Action
initialEffect = initialTask |> kickOff

--------------------------------------------------------------------------------

-- Map any task to an effect, discarding any direct result or error value
kickOff : Task x a -> Effects Action
kickOff =
  Task.toMaybe >> Task.map (always (Noop)) >> Effects.task


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Noop ->
      ( model, Effects.none )

    FromServer dict ->
      ( Maybe.withDefault [] (Dict.get "sections" dict), Effects.none )


view : Signal.Address Action -> Model -> Html
view address model =
  let
    sectionView status =
      let
        color =
          case status of
            Open -> "green"
            Closed -> "red"

      in
        div
          [ style [( "background-color", color )] ]
          [ text "Section" ]

  in
    div [] (List.map sectionView model)


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

