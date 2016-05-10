module TouchDrop exposing (onDragStart, onDragOver, onDrop
                  , onTouchStart, onTouchMove, onTouchEnd
                  , onGestureStart, onTouchDrop, dropTarget
                  ) 

{-| This exposes events for drag and drop on touch devices like iOS and Android.

# Drag and Drop with mouse
@docs onDragStart, onDragOver, onDrop

# Touches
@docs onTouchStart, onTouchMove, onTouchEnd, onTouchDrop, dropTarget

# Gestures
@docs onGestureStart

-}

import Json.Decode as Decode
import Html.Events exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Native.TouchDrop


messageOnWithOptions : String -> Options -> msg -> Attribute msg
messageOnWithOptions name options a = 
  onWithOptions name options Decode.value


point : Decoder (Float,Float)
point =
    object2 (,)
      ("clientX" := float)
      ("clientY" := float)



{-| GestureStart event -}
onGestureStart : msg -> Attribute msg
onGestureStart =
  messageOnWithOptions "gesturestart" { defaultOptions | preventDefault = True }

{-| TouchStart event -}
onTouchStart : msg -> Attribute msg
onTouchStart msg =
--  messageOnWithOptions "touchstart" { defaultOptions | preventDefault = True }
  onWithOptions "touchstart" 
                  { defaultOptions | preventDefault = True } 
                  Decode.value
                  (\evt -> 
                    Native.TouchDrop.createDragShadow evt
                    |> always msg
                  )


{-| TouchMove event -}
onTouchMove : msg -> Attribute msg
onTouchMove msg =
--  messageOnWithOptions "touchmove" { defaultOptions | preventDefault = True }
  onWithOptions "touchmove" 
                  { defaultOptions | preventDefault = True } 
                  value
                  (\evt -> 
                    Native.TouchDrop.moveDragShadow evt
                    |> always msg
                  )


{-| TouchEnd event -}
onTouchEnd : msg -> Attribute msg
onTouchEnd =
  messageOnWithOptions "touchend" { defaultOptions | preventDefault = True } 



{-| DragStart event -}
onDragStart : msg -> Attribute msg
onDragStart =
  messageOnWithOptions "dragstart" defaultOptions

{-| DragOver event -}
onDragOver : msg -> Attribute msg
onDragOver =
  messageOnWithOptions "dragover" { defaultOptions | preventDefault = True }

{-| Drop event. Note: you need to use onDragOver too, otherwise the droop event won't get fired -}
onDrop : msg -> Attribute msg
onDrop =
  messageOnWithOptions "drop" { defaultOptions | preventDefault = True } 


{-| Drop event. Note: you need to use onDragOver too, otherwise the droop event won't get fired -}
onTouchDrop : (Maybe String -> msg) -> Attribute msg
onTouchDrop handler =
  onWithOptions "touchend" 
                  { defaultOptions | preventDefault = True } 
                  Json.succeed
                  (\evt -> 
                    evt 
                    |> Native.TouchDrop.clearDragShadow
                    |> Native.TouchDrop.dropTarget
                    |> handler 
                  )



{-| The returning value after the touc drop happened.
    TouchDrop will only return an attribute if this is set on the targetted object.
  -}
dropTarget : String -> Attribute msg
dropTarget value = 
  attribute "droptarget" value





