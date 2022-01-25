{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Amazonka hiding (Header)
import Amazonka.S3
import Amazonka.S3.Lens
import Configuration.Dotenv
import Control.Lens
import Control.Monad (void)
import Control.Monad.Trans.Resource
import Control.Monad.IO.Class
import Data.Conduit
import qualified Data.Conduit.Binary as CB
import Data.Conduit.Combinators
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.Conduit ()
import qualified Servant.Types.SourceT as S

main :: IO ()
main = loadFile defaultConfig >> run 3030 app

app :: Application
app = serve (Proxy @API) server

type API =
  "one-step" :> StreamGet NoFraming OctetStream (ConduitT () ByteString (ResourceT IO) ())
    :<|> "two-steps" :> StreamGet NoFraming OctetStream (Headers '[ Header "Content-Disposition" Text] (SourceIO ByteString))

server :: Server API
server = oneStepHandler :<|> twoStepsHandler

getObjectRequest :: GetObject
getObjectRequest = newGetObject (BucketName "amazonka-servant-streaming") (ObjectKey "haskell.png")

-- forwarding the stream
oneStepHandler :: Handler (ConduitT () ByteString (ResourceT IO) ())
oneStepHandler = do
  awsEnv <- newEnv Discover
  resourceState <- createInternalState
  res <- flip runInternalState resourceState $ do
    awsRes <- send awsEnv getObjectRequest
    pure . _streamBody $ awsRes ^. getObjectResponse_body

  -- It took me a long time to understand what this was doing.
  -- Because ConduitT is a monad transformer and we have
  -- closeInternalState :: MonadIO m => InternalState -> m ()
  -- this attaches the `closeInternalState resourceState` action to the
  -- end of the conduit, just before it returns its final value
  -- (which was () anyway).
  pure $ res *> closeInternalState resourceState

-- first downloading then sending the file
twoStepsHandler :: Handler (Headers '[ Header "Content-Disposition" Text] (SourceIO ByteString))
twoStepsHandler = do
  awsEnv <- newEnv Discover
  liftIO $
    runResourceT $ do
      res <- send awsEnv getObjectRequest
      void $ (res ^. getObjectResponse_body) `sinkBody` CB.sinkFile "haskell.png"
  pure $ addHeader "attachment; filename=\"haskell.png\"" $ S.readFile "haskell.png"
