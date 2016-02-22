module Update (update) where

import Dict
import Effects exposing (Effects, Never)
import Model exposing (..)
import Persistence exposing (saveModel)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Noop ->
      ( model, Effects.none )

    FromServer dict ->
      ( Maybe.withDefault initialModel (Dict.get "sections" dict), Effects.none )

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

      in
        ( model, Persistence.saveModel model )

