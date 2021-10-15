{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Frontend where

import Control.Monad
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Language.Javascript.JSaddle (eval, liftJSM)

import Obelisk.Frontend
import Obelisk.Configs
import Obelisk.Route
import Obelisk.Generated.Static

import Reflex.Dom.Core

import Common.Api
import Common.Route


-- This runs in a monad that can be run on the client or the server.
-- To run code in a pure client or pure server context, use one of the
-- `prerender` functions.
frontend :: Frontend (R FrontendRoute)
frontend = Frontend
  { _frontend_head = do
      el "title" $ text "Obelisk Minimal Example"
      elAttr "link" ("href" =: static @"main.css" <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
      el "script" $ text "var CardanoWasm = null;"
      elAttr "script" ("src" =: (static @"import-lib.js") <> "type" =: "module") blank
  , _frontend_body = do
      el "h1" $ text "Welcome to Obelisk!"
      el "p" $ text $ T.pack commonStuff
      prerender_ blank $ do
        pb <- delay 1 =<< getPostBuild
        widgetHold_ blank $ ffor pb $ \_ -> liftJSM $ do
          void $ eval ("console.log('Hello, World!')" :: T.Text)
          void $ eval ("console.log(CardanoWasm.TransactionInputs.new())" :: T.Text)

      elAttr "img" ("src" =: static @"obelisk.jpg") blank
      el "div" $ do
        exampleConfig <- getConfig "common/example"
        case exampleConfig of
          Nothing -> text "No config file found in config/common/example"
          Just s -> text $ T.decodeUtf8 s
      return ()
  }
