module Update (update) where

import Effects exposing (Effects)
import Model exposing (..)
import Persistence exposing (saveSections)


update : Action -> Model -> ( Model, Effects Action )
update action model =
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

        toggleSelectedSectionStatus selectedSectionId ( sectionId, status ) =
          ( sectionId, if selectedSectionId == sectionId then toggleStatus status else status )

        updatedSections =
          List.map (toggleSelectedSectionStatus sectionId) model.sections

        updatedModel =
          { model | sections = updatedSections }

      in
        ( updatedModel, Persistence.saveSections updatedModel.sections )

