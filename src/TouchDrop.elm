module TouchDrop  (onDragStart, onDragOver, onDrop
                  , onTouchStart, onTouchMove, onTouchEnd
                  , onTouchDrop, dropTarget
                  ) where

{-| This exposes events for drag and drop on touch devices like iOS and Android.

# Drag and Drop with mouse
@docs onDragStart, onDragOver, onDrop

# Touches
@docs onTouchStart, onTouchMove, onTouchEnd, onTouchDrop, dropTarget

-}

import Json.Decode as Json exposing (..)
import Html.Events exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Native.TouchDrop


messageOnWithOptions : String -> Options -> Signal.Address a -> a -> Attribute
messageOnWithOptions name options addr msg =
  onWithOptions name options Json.value (\_ -> Signal.message addr msg)


onTouchWithOptions : String -> TouchOptions -> Json.Decoder a -> (a -> Signal.Message) -> Attribute
onTouchWithOptions name options addr toMessage =
  Native.TouchDrop.onTouch name options Json.value toMessage


type alias TouchOptions = 
  { stopPropagation : Bool
  , preventDefault : Bool
  , fingers : Int
  }

{-| Everything is `False` by default.
    defaultOptions =
        { stopPropagation = False
        , preventDefault = False
        }
-}
defaultTouchOptions : TouchOptions
defaultTouchOptions =
    { stopPropagation = False
    , preventDefault = False
    , fingers = -1
    }


point : Decoder (Float,Float)
point =
    object2 (,)
      ("clientX" := float)
      ("clientY" := float)



{-| TouchStart event -}
onTouchStart : Signal.Address a -> a -> Attribute
onTouchStart addr msg =
  onTouchWithOptions "touchstart" 
                  { defaultTouchOptions | preventDefault = True , fingers = 1 } 
                  value
                  (\evt -> 
                    Native.TouchDrop.createDragShadow evt
                    |> always msg
                    |> Signal.message addr
                  )


{-| TouchMove event -}
onTouchMove : Signal.Address a -> a -> Attribute
onTouchMove addr msg =
  onTouchWithOptions "touchmove" 
                  { defaultTouchOptions | preventDefault = True , fingers = 1 } 
                  value
                  (\evt -> 
                    Native.TouchDrop.moveDragShadow evt
                    |> always msg
                    |> Signal.message addr
                  )


{-| TouchEnd event -}
onTouchEnd : Signal.Address a -> a -> Attribute
onTouchEnd addr msg =
  onTouchWithOptions "touchend" 
                  { defaultTouchOptions | preventDefault = True , fingers = 1 } 
                  value 
                  (\evt -> 
                    Native.TouchDrop.clearDragShadow evt 
                    |> always msg
                    |> Signal.message addr
                  )



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
  onTouchWithOptions "touchend" 
                  { defaultTouchOptions | preventDefault = True , fingers = 0 } 
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





