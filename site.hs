{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid ((<>))
import Hakyll

main :: IO ()
main =
  hakyllWith config $ do
    match ("images/*" .||. "bower_components/**") $ do
      route idRoute
      compile copyFileCompiler
    match "css/*" $ do
      route idRoute
      compile compressCssCompiler
    match "contact.md" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>=
        loadAndApplyTemplate "templates/default.html" defaultContext >>=
        relativizeUrls
    match "talks.md" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>=
        loadAndApplyTemplate "templates/default.html" defaultContext >>=
        relativizeUrls
    match "posts/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>=
        loadAndApplyTemplate "templates/post.html" postCtx >>=
        saveSnapshot "content" >>=
        loadAndApplyTemplate "templates/default.html" postCtx >>=
        relativizeUrls
    create ["blog.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let blogCtx =
              listField "posts" postCtx (return posts) <>
              constField "title" "Blog" <>
              defaultContext
        makeItem "" >>= loadAndApplyTemplate "templates/blog.html" blogCtx >>=
          loadAndApplyTemplate "templates/default.html" blogCtx >>=
          relativizeUrls
    match "index.md" $ do
      route $ setExtension "html"
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let indexCtx =
              listField "posts" postCtx (return posts) <>
              constField "title" "Home" <>
              defaultContext
        pandocCompiler >>= applyAsTemplate indexCtx >>=
          loadAndApplyTemplate "templates/default.html" indexCtx >>=
          relativizeUrls
    match "templates/*" $ compile templateCompiler
    create ["atom.xml"] $ do
      route idRoute
      compile $ do
        let feedCtx = postCtx <> bodyField "description"
        posts <-
          fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
        renderAtom myFeedConfiguration feedCtx posts
    match "keybase.txt" $ do
      route idRoute
      compile copyFileCompiler

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" <> defaultContext

config :: Configuration
config =
  defaultConfiguration
  { deployCommand =
      "rsync --checksum -ave ssh _site/* root@willsewell.com:/var/www/willsewell.com"
  }

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration =
  FeedConfiguration
  { feedTitle = "Will Sewell"
  , feedDescription = "The blog of Will Sewell."
  , feedAuthorName = "Will Sewell"
  , feedAuthorEmail = "me@willsewell.com"
  , feedRoot = "http://willsewell.com"
  }
