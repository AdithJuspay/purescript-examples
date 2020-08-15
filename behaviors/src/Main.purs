module Main where

import Data.Maybe
import FRP.Behavior
import Prelude

import Effect (Effect)
import Effect.Class.Console 
import Control.Plus ((<|>))
import FRP.Behavior (behavior, sample_, step)
import FRP.Event (Event, subscribe, create)

newtype Id = Id String
newtype Direction = Direction String

foreign import rotate ::  Id -> Direction -> Effect  Unit
foreign import attachEvents :: forall a b .  Id ->  (b ->  Effect Unit) -> Unit

rotateAll = do
  rotate (Id "gear1") (Direction "clockwise")
  rotate (Id "gear2") (Direction "anti-clockwise")
  rotate (Id "gear3") (Direction "clockwise")

stopAll = do
  rotate (Id "gear1") (Direction "stop")
  rotate (Id "gear2") (Direction "stop")
  rotate (Id "gear3") (Direction "stop")

getSig id = do
  o <- create
  let behavior = step true o.event
  let x = attachEvents id o.push
  pure $ {behavior : behavior , event : o.event}

runSystem :: Boolean -> Boolean -> Boolean -> Boolean
runSystem a b c = a && b && c

main = do
  sig1 <- getSig (Id "gear1")
  sig2 <- getSig (Id "gear2")
  sig3 <- getSig (Id "gear3")

  log "hello"

  let behavior = runSystem <$> sig1.behavior <*> sig2.behavior <*> sig3.behavior
  sample_ behavior (sig1.event <|> sig2.event <|> sig3.event) `subscribe` (\x -> if x then
                                                                                   rotateAll
                                                                                 else
                                                                                   stopAll)
