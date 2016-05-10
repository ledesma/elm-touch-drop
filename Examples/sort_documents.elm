module DragDrop

import Html exposing (Html, Attribute, text, div, input)
import Html.Attributes exposing (..)
import Debug
import StartApp
import List
import Effects exposing (Effects, Never)
import Task exposing (Task)
import Maybe exposing (..)
import Dict
import TouchDrop exposing (..)
--import Touch
import Signal 

-- VIEW

type alias Page = 
  { id: String
  }

type alias Model =
  {
    pages:List Page
  , dragging: Maybe String
  , msg: Msg
  }

model : Model
model = 
  { pages =
      [
        {id = "Page 1"}
      , {id = "Page 2"}
      , {id = "Page 3"}
      ]
  , dragging = Nothing
  , msg = None 
  }

view : Signal.Address Msg -> Model -> Html
view address model =
  div []
      ( div [ ] [ text (toString model.msg) ] 
        :: (List.map (\p -> page address p.id) model.pages))

page : Signal.Address Msg -> String -> Html
page address identifier =
  div[ 
      draggable "true"
    , dragStyle

    , onDragStart address (DragStart identifier)
    , onDragOver address DragOver
    --, onDragEnter address DragEnter
    --, onDragLeave address DragLeave
    , onDrop address (Drop identifier)
    --, onDragEnd address DragEnd
    , onTouchStart address (TouchStart identifier)
    , onTouchMove address (TouchMove identifier)
    --, onTouchEnd address (TouchEnd identifier)
    , onTouchDrop address (\target -> 
                              case target of 
                                Just page -> TouchDrop page
                                Nothing -> None
                          )
    , dropTarget identifier
    , id identifier
    , dropzone "move"
  ][text identifier]

dragStyle : Attribute
dragStyle =
  style 
  [ ("width" , "100px")
  , ("height" , "100px")
  , ("line-style", "dashed")
  , ("background", "lightgrey")
  , ("border", "solid 1px grey")
  , ("display", "inline-block")
  , ("margin", "5px")
  ]




app : StartApp.App Model
app =
  StartApp.start  { init = (model, Effects.none)
                  , view = view
                  , update = update 
                  , inputs = [] 
                  }

main : Signal Html
main = app.html 


-- SIGNALS

type Msg = None | DragStart String | DragLeave | DragEnter | DragEnd | Drop String | DragOver
              | TouchStart String
              | TouchMove String
              | TouchEnd String
              | TouchDrop String


port tasks : Signal (Task Never ())
port tasks = app.tasks

update : Msg -> Model -> (Model, Effects Msg)   
update msg model = 
  (
  case (Debug.log "msg" msg) of
    DragStart pageId ->
      {model | dragging = Just pageId}
    Drop toPageId ->
      case model.dragging of
        Just fromPageId -> 
          {model | dragging = Nothing, pages = (sortPages fromPageId toPageId model.pages)}
        Nothing ->
          model 
    TouchMove pageId -> 
      {model | dragging = Just pageId}
    TouchDrop toPageId -> 
      case model.dragging of
        Just fromPageId -> 
          {model | dragging = Nothing, pages = (sortPages fromPageId toPageId model.pages)}
        Nothing ->
          model           
    _ ->  
      model
  )
  |> updateMsg msg
  |> nofx




updateMsg : Msg -> Model -> Model
updateMsg act model =
  { model | msg = act }

nofx : Model -> (Model, Effects Msg) 
nofx model = 
  (model, Effects.none)


sortPages : String -> String -> List Page -> List Page
sortPages from to pages =
  let 
    pagePositions = 
      Dict.fromList (List.indexedMap (\ix p -> (p.id, ((toFloat ix), p))) pages)
    position id =
      case (Dict.get id pagePositions) of
        Just tuple -> fst tuple
        Nothing -> toFloat 999999
  in
    pagePositions
    |> Dict.update from (Maybe.map (\from_tupel -> ( ((position to) - 0.1), (snd from_tupel)))) 
    |> Dict.values
    |> List.sortBy (\tuple -> fst tuple)
    |> List.map (\tuple -> snd tuple) 
    |> Debug.log "Sorted Pages: " 


