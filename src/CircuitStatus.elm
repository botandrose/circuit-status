import Effects exposing (Never)
import Html exposing (Html)
import Model exposing (..)
import Persistence exposing (initialEffect, modelUpdates)
import StartApp
import Task exposing (Task)
import Update exposing (update)
import View exposing (view)


config : StartApp.Config Model Action
config =
  { init = ( initialModel, initialEffect )
  , update = update
  , view = view
  , inputs = [ Signal.map Model.FromServer modelUpdates ]
  }


app : StartApp.App Model
app = StartApp.start config


port runEffects : Signal (Task Never ())
port runEffects = app.tasks


main : Signal Html.Html
main = app.html

