module Model (..) where

import Dict


type Action = Noop | FromServer (Dict.Dict String Model) | Toggle Section


type Status = Open | Closed


type SectionId = CaveLeft | CaveRight | BoneBreaker | AlleyCave | AlleyNorthwest | AlleyNortheast | Entrance | Overhang | Staircase


type alias Section = ( SectionId, Status )


type alias Model = List Section


initialModel : Model
initialModel =
  [ ( CaveLeft, Open )
  , ( CaveRight, Open )
  , ( BoneBreaker, Open )
  , ( AlleyCave, Open )
  , ( AlleyNorthwest, Open )
  , ( AlleyNortheast, Open )
  , ( Entrance, Open )
  ]


