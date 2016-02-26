module Model (..) where

import Time exposing (Time)


type Action = Noop | FromServer (List Section) | ToggleSection SectionId | ToggleIsEditing


type Status = Open | Closed


type SectionId = CaveLeft | CaveRight | BoneBreaker | AlleyCave | AlleyNorthwest | AlleyNortheast | Entrance | Overhang | Staircase


sectionIds : List SectionId
sectionIds =
  [ CaveLeft, CaveRight, BoneBreaker, AlleyCave, AlleyNorthwest, AlleyNortheast, Entrance, Overhang, Staircase ]


type alias Section = { sectionId : SectionId, status : Status, updatedAt : Time }


type alias Model = { sections : List Section, isEditing : Bool }


initialModel : Model
initialModel =
  Model [] False

