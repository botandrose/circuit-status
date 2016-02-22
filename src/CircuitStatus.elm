import Effects exposing (Never)
import Html exposing (..)
import Model exposing (..)
import Persistence exposing (..)
import Signal exposing (Mailbox, Address, mailbox, message)
import StartApp
import Task exposing (Task)
import Update exposing (..)
import View exposing (..)


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

