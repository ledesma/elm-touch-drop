module TouchDrop  (onDragStart, onDragOver, onDrop
                  , onTouchStart, onTouchMove, onTouchEnd
                  , onGestureStart, onTouchDrop
                  ) where

{-| This exposes events for drag and drop on touch devices like iOS and Android.

# Drag and Drop with mouse
@docs onDragStart, onDragOver, onDrop

# Touches
@docs onTouchStart, onTouchMove, onTouchEnd, onTouchDrop

# Gestures
@docs onGestureStart

-}


--import Native.TouchDrop
import Json.Decode as Json exposing (..)
import Html.Events exposing (..)
import Html exposing (Attribute)
import Native.TouchDrop
import Debug 


messageOnWithOptions : String -> Options -> Signal.Address a -> a -> Attribute
messageOnWithOptions name options addr msg =
  onWithOptions name options Json.value (\_ -> Signal.message addr msg)


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
onTouchStart =
  messageOnWithOptions "touchstart" { defaultOptions | preventDefault = True }

{-| TouchMove event -}
onTouchMove : Signal.Address a -> a -> Attribute
onTouchMove =
  messageOnWithOptions "touchmove" { defaultOptions | preventDefault = True }


{-| TouchEnd event -}
onTouchEnd : Signal.Address a -> a -> Attribute
onTouchEnd =
  messageOnWithOptions "touchend" { defaultOptions | preventDefault = True } 



{-| DragStart event -}
onDragStart : Signal.Address a -> a -> Attribute
onDragStart =
  messageOnWithOptions "dragstart" { defaultOptions | preventDefault = True }

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
                    |> Native.TouchDrop.dropTarget
                    |> handler 
                    |> Signal.message addr 
                  )







