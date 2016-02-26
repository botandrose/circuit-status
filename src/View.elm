module View (view) where

import Html exposing (Html)
import Html.Events exposing (onClick)
import Model exposing (..)
import String
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
        [ confidenceBoulder
        , bigTopoutBoulder
        , smallTopoutBoulder
        , wallBoulder
        ]
      , g
        []
        (List.map (sectionView address model.isEditing) model.sections)
      , editButton address model.isEditing
      ]


editButton : Signal.Address Action -> Bool -> Svg
editButton address isEditing =
  circle
    [ fill (if isEditing then "blue" else "grey")
    , onClick address ToggleIsEditing
    , cx "500"
    , cy "60"
    , r "40"
    ]
    []


confidenceBoulder : Svg
confidenceBoulder =
  g
    []
    [ Svg.path
      [ fill "grey"
      , stroke "#000000"
      , strokeMiterlimit "10"
      , d "M167.537,49.782l14.828,14.829v3.053l-75.886,10.903v20.062 l75.014-10.031v2.181h10.031l3.489,45.793l-46.229,3.489l-36.199,20.062l-75.886,20.498l-14.392,27.476l57.132,75.45l78.067-61.494 l83.3-5.233l79.812,17.009l29.657-7.85l42.741,13.956l54.079-20.062l-1.744-20.934l-22.679-16.137l-82.864,3.489l-27.476-17.445 l-80.248,16.137l-12.647-49.718h-6.542l-3.053-44.485l5.233-0.436V0.5H36.699c0,0-36.199,0.436-36.199,41.432h27.04l23.987,12.212 l27.912-12.212L167.537,49.782z"
      ]
      []
    , normalLine "34.451,224.134 35.325,221.265"
    , dashedLine "37.224,215.031 43.872,193.213"
    , normalLine "44.821,190.096 45.696,187.226"
    , normalLine "45.696,187.226 48.57,186.367"
    , dashedPoly "53.991,184.747 75.099,178.439 103.293,163.904"
    , normalLine "105.808,162.607 108.474,161.233"
    , dashedPoly "79.439,283.546 120.048,199.393 238.673,209.87 320.618,233.828 364.058,221.022 364.058,203.448 340.062,187.226 308.294,179.453 232.083,184.982"
    , dashedLine "195.013,136.572 212.894,135.264"
    , dashedLine "191.524,90.778 209.841,90.778"
    , dashedLine "181.493,88.598 182.365,67.664"
    ]


bigTopoutBoulder : Svg
bigTopoutBoulder =
  g
    []
    [ outline "575.332,373.477 556.083,320.798 590.528,217.974 620.414,208.856 654.35,230.637 711.082,234.182 718.679,286.355 739.447,320.292 735.395,365.879 760.721,532.02 738.94,554.813 633.076,553.8 608.256,535.565 593.567,501.628 533.797,453.508 527.719,389.179 546.967,389.179 548.487,374.997"
    , dashedPoly "546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 682.195,554.285"
    , dashedPoly "740.859,401.728 716.417,356.082 720.1,315.104 692.935,272.285 652.417,261.695 621.57,307.061 599.469,373.118 575.332,373.477"
    , dashedPoly "760.721,532.02 740.359,521.375 696.619,407.649 741.762,407.649"
    ]


smallTopoutBoulder : Svg
smallTopoutBoulder =
  g
    []
    [ outline "797.191,239.754 798.71,186.062 835.18,176.944 906.094,181.503 932.94,192.647 945.603,192.647 944.59,281.795 930.408,304.083 941.551,324.344 960.292,395.257 945.096,423.117 953.201,507.707 913.692,496.563 853.921,496.563 855.948,432.234 826.063,345.618 850.882,270.652"
    , dashedPoly "850.882,270.652 850.882,226.5 906.094,181.503"
    , dashedPoly "932.94,192.647 920.774,246.124 889.812,277.958 871.496,325.056 919.466,355.583 941.271,392.214 945.096,423.117 913.692,496.563"
    , dashedLine "878.742,496.563 855.948,432.234"
    ]


wallBoulder : Svg
wallBoulder =
  g
    []
    [ outline "367.15,679.925 367.15,605.466 456.298,623.701 464.91,607.999 548.993,618.635 559.63,641.43 601.166,637.883 608.763,621.168 668.027,646.495 778.45,640.923 837.713,584.699 922.809,581.153 985.619,666.756"
    , dashedPoly "367.15,626.491 506.438,653.947 618.296,643.269 620.875,672.992 668.027,646.495"
    , dashedPoly "778.45,640.923 809.472,649.741 867.344,598.526 880.273,598.526 925.427,668.038"
    ]


sectionPoints : SectionId -> String
sectionPoints sectionId =
  case sectionId of
    CaveLeft -> "527.719,389.179 546.967,389.179 546.967,394.757 663.468,413.634 683.726,433.433 683.0,493.0 593.567,501.628 533.797,453.508"
    CaveRight -> "683.0,493.0 682.195,554.285 633.076,553.8 608.256,535.565 593.567,501.628"
    BoneBreaker -> "683.185,534.285 682.195,554.285 738.94,554.813 760.721,532.02 740.359,521.375 728.94,534.813"
    AlleyCave -> "760.721,532.02 740.359,521.375 696.619,407.649 741.762,407.649"
    AlleyNorthwest -> "740.859,401.728 716.417,356.082 720.1,315.104 739.447,320.292 735.395,365.879"
    AlleyNortheast -> "720.1,315.104 739.447,320.292 718.679,286.355 711.082,234.182 692.935,272.285"
    Entrance -> "654.35,230.637 711.082,234.182 692.935,272.285 652.417,261.695"
    Overhang -> "573.305,269.386 590.528,217.974 620.414,208.856 654.35,230.637 652.417,261.695 621.57,307.061"
    Staircase -> "575.332,373.477 556.083,320.798 573.305,269.386 621.57,307.061 599.469,373.118"


sectionView : Signal.Address Action -> Bool -> Section -> Svg
sectionView address isEditing { sectionId, status } =
  polygon
    [ onClick address (if isEditing then ToggleSection sectionId else Noop)
    , fill (statusToColor status)
    , stroke "none"
    , points (sectionPoints sectionId)
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


normalLine : String -> Svg
normalLine points =
  case List.concatMap (String.split ",") <| String.split " " points of
    [x1',y1',x2',y2'] ->
      line
        [ fill "none"
        , stroke "#000000"
        , strokeMiterlimit "10"
        , x1 x1'
        , y1 y1'
        , x2 x2'
        , y2 y2'
        ]
        []
    _ -> Debug.crash points


dashedLine : String -> Svg
dashedLine points =
  case List.concatMap (String.split ",") <| String.split " " points of
    [x1',y1',x2',y2'] ->
      line
        [ fill "none"
        , stroke "#000000"
        , strokeMiterlimit "10"
        , strokeDasharray "6,6"
        , x1 x1'
        , y1 y1'
        , x2 x2'
        , y2 y2'
        ]
        []
    _ -> Debug.crash points


dashedPoly : String -> Svg
dashedPoly points' =
  polyline
    [ fill "none"
    , stroke "#000000"
    , strokeMiterlimit "10"
    , strokeDasharray "6,6"
    , points points'
    ]
    []


statusToColor : Status -> String
statusToColor status =
  case status of
    Open -> "green"
    Closed -> "red"


