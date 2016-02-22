import Dict
import Effects exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task exposing (Task)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Signal exposing (Mailbox, Address, mailbox, message)
import Task exposing (Task, andThen)
import Effects exposing (Effects, Never)

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
          [ Html.Attributes.style [( "background-color", color )]
          , onDoubleClick address (Toggle index)
          ]
          [ Html.text "Section" ]

  in
    div
      []
      [ div [] (List.indexedMap sectionView model)

      , Svg.svg
        [ version "1.1"
        , Svg.Attributes.width "100%"
        , Svg.Attributes.height "100%"
        , viewBox "0 0 1000 680"
        ]
        [ g
          []
          [ outline "575.332,373.477 556.083,320.798 590.528,217.974 620.414,208.856 654.35,230.637 711.082,234.182 718.679,286.355 739.447,320.292 735.395,365.879 760.721,532.02 738.94,554.813 633.076,553.8 608.256,535.565 593.567,501.628 533.797,453.508 527.719,389.179 546.967,389.179 548.487,374.997"
          , dashedLine "546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 682.195,554.285"
          , dashedLine "740.859,401.728 716.417,356.082 720.1,315.104 692.935,272.285 652.417,261.695 621.57,307.061 599.469,373.118 575.332,373.477"
          , dashedLine "760.721,532.02 740.359,521.375 696.619,407.649 741.762,407.649"
          ]
        , g
          []
          [ caveLeft, caveRight ]
        ]
      ]


caveLeft : Svg
caveLeft =
  polygon
    [ fill "green"
    , stroke "none"
    , points "
        527.719,389.179 546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 683.726,493.0 593.567,501.628 533.797,453.508
      "
    ]
    []


caveRight : Svg
caveRight =
  polygon
    [ fill "red"
    , stroke "none"
    , points "
        683.726,493.0 683.726,554.285 633.076,553.8 608.256,535.565 593.567,501.628
      "
    ]
    []


outline : String -> Svg
outline points' =
  polygon
    [ fill "grey"
    , stroke "#000000"
    , strokeMiterlimit "10"
    , points points'
    ]
    []


dashedLine : String -> Svg
dashedLine points' =
  polyline
    [ fill "none"
    , stroke "#000000"
    , strokeMiterlimit "10"
    , strokeDasharray "6,6"
    , points points'
    ]
    []

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

