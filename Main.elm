import Html exposing (..)
import Html.Attributes exposing (..)
import StartApp.Simple as StartApp


type Status = Open | Closed


type Action = Noop


model = [ Open, Closed, Open, Closed ]


view address model =
  let
    sectionView status =
      let
        color =
          case status of
            Open -> "green"
            Closed -> "red"

      in 
        div
          [ style [( "background-color", color )] ]
          [ text "Section" ]

  in
    div [] (List.map sectionView model)


update action model =
  model


main =
  StartApp.start { model = model, view = view, update = update }

