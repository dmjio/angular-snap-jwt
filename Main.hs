{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}

module Main where

import           Control.Concurrent.MVar
import           Control.Exception       hiding (Handler)
import           Control.Lens
import qualified Data.Aeson as A
import qualified Data.ByteString.Char8 as B8
import           Data.Aeson (FromJSON, ToJSON)
import qualified Data.Map                as M
import           Data.Text               (Text)
import Data.Maybe
import qualified Data.Text               as T
import qualified Data.Text.IO            as T
import qualified Data.Map as M
import qualified Data.Text.Lazy          as T
import Data.Default
import           Web.JWT
import           Data.CaseInsensitive

import qualified Data.Text.Encoding      as T
import           System.IO

import           GHC.Generics
import           Snap
import           Snap.Core
import           Snap.Loader.Static
import           Snap.Snaplet
import           Snap.Snaplet.Auth hiding (verify)
import           Snap.Snaplet.Config
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Session
import           Snap.Util.FileServe
import           System.Random

------------------------------------------------------------------------------
-- | Types
type UserLogin = Text
type SecretKey = Text
type Token     = Text

data App = App {
      _heist     :: Snaplet (Heist App)
    , _users     :: MVar [User]
    , _secretJWT :: Text
 }

data User = User
    { username :: !Text
    , password :: !Text
    } deriving (Show, Eq, Generic)

instance FromJSON User
instance ToJSON User

$(makeLenses ''App)

instance HasHeist App where heistLens = subSnaplet heist

main :: IO ()
main = do (logs, app, cleanup) <- runSnaplet Nothing initSite
          T.hPutStrLn stdout logs
          quickHttpServe app
          cleanup

initSite :: SnapletInit App App
initSite = makeSnaplet "angie" "angie" Nothing $ do
             addRoutes routes
             _heist <- nestSnaplet "" heist $ heistInit "templates"
             _users <- liftIO $ newMVar []
             _secretJWT <- return "secret"
             return App {..}
  where
    routes = [ ("/", ifTop $ render "index")
             , ("/api/login", handleLogin)
             , ("/api/register", handleRegister)
             , ("/api/login", handleLogin)
             , ("/api/data", handleData)
             , ("/static", serveDirectory "static")
             , ("/temps", heistServe)
             , ("", writeBS "the404")
             ]


------------------------------------------------------------------------------
-- | Current User JWT
-- Middleware layer for processing Authorization header and JWT token 
-- Like `currentUser` from Snap.Snaplet.Auth
--
currentUserJWT :: Handler App App (Maybe User)
currentUserJWT = do
      result <- getHeader (mk "Authorization") <$> getRequest 
      case result of
        Nothing     -> failJWT
        Just header -> do 
            liftIO $ print header
            key <- withTop' id $ view secretJWT
            liftIO $ do print (key, secret key)
                        print $ B8.split ' ' header
            let [_, jwt] = B8.split ' ' header
            liftIO $ B8.putStrLn jwt
            case decodeAndVerifySignature (secret key) (T.decodeUtf8 jwt) of
              Nothing -> failJWT
              Just verifiedJWT  -> 
                do liftIO $ print verifiedJWT
                   mvar <- withTop' id $ view users
                   users <- liftIO $ takeMVar mvar
                   liftIO $ putMVar mvar users
                   let Just (A.String username) = M.lookup "user" (getClaims verifiedJWT)
                   case listToMaybe $ filter (\(User name pass) -> name == username) users of
                     Nothing -> failJWT
                     Just user -> return (Just user)
  where
    failJWT = do
      modifyResponse $ setResponseCode 401 
      return Nothing
    getClaims = unregisteredClaims . claims
  
------------------------------------------------------------------------------
-- | Handlers
handleData :: Handler App App ()
handleData = method GET $ currentUserJWT >>= maybe pass handleUser
  where
    handleUser _ = do 
      mvar <- withTop' id $ view users
      users <- liftIO $ takeMVar mvar
      liftIO $ putMVar mvar users 
      writeJSON users

handleRegister :: Handler App App ()
handleRegister = do
  method POST $ do
      Just user <- getJSON
      mvar <- withTop' id $ view users
      liftIO $ modifyMVar_ mvar $ \db -> do
                   let newDB = user : db
                   print newDB
                   return newDB
      secretKey <- withTop' id $ view secretJWT
      let token = makeToken (username user) secretKey
      liftIO $ print token
      writeBS (T.encodeUtf8 token)

handleLogin :: Handler App App ()
handleLogin =
    method POST $ do
      Just User{..} <- getJSON
      mvar <- withTop' id $ view users
      users <- liftIO $ takeMVar mvar
      liftIO $ putMVar mvar users
      if User username password `notElem` users
        then unAuthorized
        else do
          secretKey <- withTop' id $ view secretJWT
          writeBS $ T.encodeUtf8 (makeToken username secretKey)
  where
    unAuthorized = do modifyResponse $ setResponseStatus 401 "UnAuthorized"
                      pass

------------------------------------------------------------------------------
-- | Utils
writeJSON
    :: (MonadSnap m, ToJSON a)
    => a 
    -> m ()
writeJSON a = do
  modifyResponse $ setHeader "Content-Type" "application/json"
  writeLBS . A.encode $ a

getJSON 
    :: (FromJSON a, MonadSnap m) 
    => m (Maybe a)
getJSON = A.decode <$> readRequestBody 50000

------------------------------------------------------------------------------
-- | Token creation
makeToken
    :: UserLogin
    -> SecretKey
    -> Text
makeToken userLogin secretKey = 
    encodeSigned HS256 (secret secretKey) def { 
                       unregisteredClaims = 
                           M.fromList [("user", A.String userLogin)]
                     }
