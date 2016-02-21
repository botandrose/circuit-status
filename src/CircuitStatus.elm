import Effects exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import StartApp
import Task exposing (Task)


type Status = Open | Closed


type Action = Noop


type alias Model = List Status


initialModel : Model
initialModel = [ Open, Closed, Open, Closed ]


update : Action -> Model -> ( Model, Effects Action )
update action model =
  ( model, Effects.none )


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
  { init = (initialModel, Effects.none)
  , update = update
  , view = view
  , inputs = [ Signal.constant Noop ]
  }


app : StartApp.App Model
app = StartApp.start config


port runEffects : Signal (Task Never ())
port runEffects = app.tasks


main : Signal Html
main = app.html

