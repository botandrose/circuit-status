module Model (..) where


type Action = Noop | FromServer Model | Toggle SectionId


type Status = Open | Closed


type SectionId = CaveLeft | CaveRight | BoneBreaker | AlleyCave | AlleyNorthwest | AlleyNortheast | Entrance | Overhang | Staircase


sectionIds : List SectionId
sectionIds =
  [ CaveLeft, CaveRight, BoneBreaker, AlleyCave, AlleyNorthwest, AlleyNortheast, Entrance, Overhang, Staircase ]


type alias Section = ( SectionId, Status )


type alias Model = { sections : List Section }


initialModel : Model
initialModel =
  Model
    [ ( CaveLeft, Open )
    , ( CaveRight, Open )
    , ( BoneBreaker, Open )
    , ( AlleyCave, Open )
    , ( AlleyNorthwest, Open )
    , ( AlleyNortheast, Open )
    , ( Entrance, Open )
    ]

