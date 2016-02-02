module TouchDrop  (onDragStart, onDragOver, onDrop
                  , onTouchStart, onTouchMove, onTouchEnd
                  , onGestureStart, onTouchDrop, dropTarget
                  ) where

{-| This exposes events for drag and drop on touch devices like iOS and Android.

# Drag and Drop with mouse
@docs onDragStart, onDragOver, onDrop

# Touches
@docs onTouchStart, onTouchMove, onTouchEnd, onTouchDrop, dropTarget

# Gestures
@docs onGestureStart

-}

import Json.Decode as Decode exposing (..)
import Html.Events exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Native.TouchDrop


messageOnWithOptions : String -> Options -> Signal.Address a -> a -> Attribute
messageOnWithOptions name options addr msg =
  onWithOptions name options Decode.value (\_ -> Signal.message addr msg)


point : Decoder (Float,Float)
point =
    object2 (,)
      ("clientX" := float)
      ("clientY" := float)



{-| GestureStart event -}
onGestureStart : Signal.Address a -> a -> Attribute
onGestureStart =
  messageOnWithOptions "gesturestart" { defaultOptions | preventDefault = True }

{-| TouchStart event -}
onTouchStart : Signal.Address a -> a -> Attribute
onTouchStart addr msg =
--  messageOnWithOptions "touchstart" { defaultOptions | preventDefault = True }
  onWithOptions "touchstart" 
                  { defaultOptions | preventDefault = True } 
                  value
                  (\evt -> 
                    Native.TouchDrop.createDragShadow evt
                    |> always msg
                    |> Signal.message addr
                  )


{-| TouchMove event -}
onTouchMove : Signal.Address a -> a -> Attribute
onTouchMove addr msg =
--  messageOnWithOptions "touchmove" { defaultOptions | preventDefault = True }
  onWithOptions "touchmove" 
                  { defaultOptions | preventDefault = True } 
                  value
                  (\evt -> 
                    Native.TouchDrop.moveDragShadow evt
                    |> always msg
                    |> Signal.message addr
                  )


{-| TouchEnd event -}
onTouchEnd : Signal.Address a -> a -> Attribute
onTouchEnd =
  messageOnWithOptions "touchend" { defaultOptions | preventDefault = True } 



{-| DragStart event -}
onDragStart : Signal.Address a -> a -> Attribute
onDragStart =
  messageOnWithOptions "dragstart" defaultOptions

{-| DragOver event -}
onDragOver : Signal.Address a -> a -> Attribute
onDragOver =
  messageOnWithOptions "dragover" { defaultOptions | preventDefault = True }

{-| Drop event. Note: you need to use onDragOver too, otherwise the droop event won't get fired -}
onDrop : Signal.Address a -> a -> Attribute
onDrop =
  messageOnWithOptions "drop" { defaultOptions | preventDefault = True } 


{-| Drop event. Note: you need to use onDragOver too, otherwise the droop event won't get fired -}
onTouchDrop : Signal.Address a -> (Maybe String -> a) -> Attribute
onTouchDrop addr handler =
  onWithOptions "touchend" 
                  { defaultOptions | preventDefault = True } 
                  value
                  (\evt -> 
                    evt 
                    |> Native.TouchDrop.clearDragShadow
                    |> Native.TouchDrop.dropTarget
                    |> handler 
                    |> Signal.message addr 
                  )



{-| The returning value after the touc drop happened.
    TouchDrop will only return an attribute if this is set on the targetted object.
  -}
dropTarget : String -> Attribute
dropTarget value = 
  attribute "droptarget" value





