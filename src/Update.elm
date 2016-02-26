module Update (update) where

import Effects exposing (Effects)
import Model exposing (..)
import Persistence exposing (saveSections)
import Time exposing (Time)


update : Action -> Time -> Model -> ( Model, Effects Action )
update action currentTime model =
  case action of
    Noop ->
      ( model, Effects.none )

    FromServer sections ->
      ( { model | sections = sections }, Effects.none )

    ToggleIsEditing ->
      ( { model | isEditing = not model.isEditing }, Effects.none )

    ToggleSection sectionId ->
      let
        toggleStatus status =
          case status of
            Open -> Closed
            Closed -> Open

        toggleSelectedSectionStatus selectedSectionId section =
          if selectedSectionId == section.sectionId
            then { section | status = toggleStatus section.status, updatedAt = currentTime }
            else section

        updatedSections =
          List.map (toggleSelectedSectionStatus sectionId) model.sections

        updatedModel =
          { model | sections = updatedSections }

      in
        ( updatedModel, Persistence.saveSections updatedModel.sections )

