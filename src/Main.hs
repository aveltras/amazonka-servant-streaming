{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Amazonka
import Amazonka.S3
import Amazonka.S3.Lens
import Control.Lens
import Control.Monad (void)
import Control.Monad.Trans.Resource
import Control.Monad.IO.Class
import Data.Conduit
import Data.Conduit.Combinators
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.Conduit ()
import Configuration.Dotenv

main :: IO ()
main = do
  void $ loadFile defaultConfig
  run 3030 app

app :: Application
app = serve (Proxy @API) server

type API = StreamGet NoFraming OctetStream (ConduitT () ByteString (ResourceT IO) ())

server :: Server API
server = handler

handler :: Handler (ConduitT () ByteString (ResourceT IO) ())
handler = do
  awsEnv <- newEnv Discover
  liftIO $
    runResourceT $ do
      res <- send awsEnv getObjectRequest
      let streamBody = _streamBody $ res ^. getObjectResponse_body
      -- uncommenting this correctly downloads the file locally
      -- liftIO $ runConduitRes $ streamBody .| sinkFile "downloaded_haskell.png"
      pure streamBody

getObjectRequest :: GetObject
getObjectRequest = newGetObject (BucketName "amazonka-servant-streaming") (ObjectKey "haskell.png")


