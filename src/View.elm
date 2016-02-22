module View where

import Html exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


view : Signal.Address Action -> Model -> Html
view address model =
    Svg.svg
      [ version "1.1"
      , Svg.Attributes.width "100%"
      , Svg.Attributes.height "100%"
      , viewBox "0 0 1000 680"
      ]
      [ g
        []
        [ outline "575.332,373.477 556.083,320.798 590.528,217.974 620.414,208.856 654.35,230.637 711.082,234.182 718.679,286.355 739.447,320.292 735.395,365.879 760.721,532.02 738.94,554.813 633.076,553.8 608.256,535.565 593.567,501.628 533.797,453.508 527.719,389.179 546.967,389.179 548.487,374.997"
        , dashedLine "546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 682.195,554.285"
        , dashedLine "740.859,401.728 716.417,356.082 720.1,315.104 692.935,272.285 652.417,261.695 621.57,307.061 599.469,373.118 575.332,373.477"
        , dashedLine "760.721,532.02 740.359,521.375 696.619,407.649 741.762,407.649"
        ]
      , g
        []
        (List.map (sectionView address) model)
      ]


statusToColor : Status -> String
statusToColor status =
  case status of
    Open -> "green"
    Closed -> "red"


sectionView : Signal.Address Action -> Section -> Svg
sectionView address section =
  case section of
    (CaveLeft, status) -> caveLeft address section
    (CaveRight, status) -> caveRight address section


caveLeft : Signal.Address Action -> Section -> Svg
caveLeft address section =
  polygon
    [ onClick address (Toggle section)
    , fill (statusToColor (snd section))
    , stroke "none"
    , points "
        527.719,389.179 546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 683.726,493.0 593.567,501.628 533.797,453.508
      "
    ]
    []


caveRight : Signal.Address Action -> Section -> Svg
caveRight address section =
  polygon
    [ onClick address (Toggle section)
    , fill (statusToColor (snd section))
    , stroke "none"
    , points "
        683.726,493.0 683.726,554.285 633.076,553.8 608.256,535.565 593.567,501.628
      "
    ]
    []


outline : String -> Svg
outline points' =
  polygon
    [ fill "grey"
    , stroke "#000000"
    , strokeMiterlimit "10"
    , points points'
    ]
    []


dashedLine : String -> Svg
dashedLine points' =
  polyline
    [ fill "none"
    , stroke "#000000"
    , strokeMiterlimit "10"
    , strokeDasharray "6,6"
    , points points'
    ]
    []

