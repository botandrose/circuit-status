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

    Toggle sectionId ->
      let
        toggleStatus status =
          case status of
            Open -> Closed
            Closed -> Open

        toggleSelectedSectionStatus selectedSectionId ( sectionId, status ) =
          ( sectionId, if selectedSectionId == sectionId then toggleStatus status else status )

        updatedModel =
          List.map (toggleSelectedSectionStatus sectionId) model

      in
        ( updatedModel, Persistence.saveModel updatedModel )

