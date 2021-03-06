import Effects exposing (Never)
import Html exposing (Html)
import Model exposing (..)
import Persistence exposing (initialEffect, sectionsUpdates)
import TimeApp
import Task exposing (Task)
import Update exposing (update)
import View exposing (view)


config : TimeApp.Config Model Action
config =
  { init = ( initialModel, initialEffect )
  , update = update
  , view = view
  , inputs = [ Signal.map Model.FromServer sectionsUpdates ]
  }


app : TimeApp.App Model
app = TimeApp.start config


port runEffects : Signal (Task Never ())
port runEffects = app.tasks


main : Signal Html.Html
main = app.html

