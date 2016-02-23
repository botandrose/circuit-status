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

    Toggle section ->
      let
        toggleStatus status =
          case status of
            Open -> Closed
            Closed -> Open

        toggleSelectedSectionStatus selectedSection section =
          let
            sectionId = (fst selectedSection)
          in
            if sectionId == (fst section)
            then ( sectionId, toggleStatus (snd section) )
            else section

        updatedModel =
          List.map (toggleSelectedSectionStatus section) model

      in
        ( updatedModel, Persistence.saveModel updatedModel )

