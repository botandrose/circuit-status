module Model (..) where

import Time exposing (Time)


type Action = Noop | FromServer (List Section) | ToggleSection SectionId | ToggleIsEditing


type Status = Open | Closed


type SectionId = CaveLeft | CaveRight | BoneBreaker | AlleyCave | AlleyNorthwest | AlleyNortheast | Entrance | Overhang | Staircase | Bottom1 | Bottom2 | Bottom3 | Bottom4 | Bottom5 | Bottom6 | Top1 | Top2 | Top3 | Top4 | Top5 | Right1 | Right2 | Right3 | Right4 | Right5 | Right6 | Right7 | Right8 | Right9


sectionIds : List SectionId
sectionIds =
  [ CaveLeft, CaveRight, BoneBreaker, AlleyCave, AlleyNorthwest, AlleyNortheast, Entrance, Overhang, Staircase, Bottom1, Bottom2, Bottom3, Bottom4, Bottom5, Bottom6, Top1, Top2, Top3, Top4, Top5, Right1, Right2, Right3, Right4, Right5, Right6, Right7, Right8, Right9 ]


type alias Section = { sectionId : SectionId, status : Status, updatedAt : Time }


type alias Model = { sections : List Section, isEditing : Bool }


initialModel : Model
initialModel =
  Model [] False

