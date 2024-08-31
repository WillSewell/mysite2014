---
title: Unit testing IO in Haskell (revisited)
description: >-
  An approach to unit testing IO in Haskell.
---

A couple of months back I posted an [article](https://pusher.com/blog/unit-testing-io-in-haskell/) on the Pusher blog about a technique
we had tried for unit testing `IO` in Haskell. Essentially it involved switching
out `IO` for typeclasses, and then making IO an instance of those typeclasses,
as well as mocks.

This generated a lot of interesting discussion in the comments, on [reddit](https://www.reddit.com/r/haskell/comments/3omsmx/unit_testing_io_in_haskell/)
and [Hacker News](https://news.ycombinator.com/item?id=10392044). After reading
Gregory Collins' [comment](https://pusher.com/blog/unit-testing-io-in-haskell/#comment-2280443222)
we decided to try out his approach and so far it has worked out much better for us.
Here is an example of how this would work for mocking a socket:

```
data Socket =
  Socket {
    send :: B.ByteString -> IO (),
    receive :: Int -> IO B.ByteString,
    close :: IO ()
  }

-- Create a real socket by partially applying IO actions to
-- a real socket
fromNetworkSocket :: NS.Socket -> Socket
fromNetworkSocket socket =
  Socket
    (NS.sendAll socket)
    (flip NS.recv socket)
    (NS.close socket)

-- Create a mock by defining up front what it will respond
-- with, and a callback that will be called with data
-- written to it (could also use an MVar instead)
mkMockSocket
  :: B.ByteString
  -> (B.ByteString -> IO ())
  -> IO Socket
mkMockSocket input outputCB = do
  leftOver <- newMVar input
  return $
    Socket
      outputCB
      (recv' leftOver)
      (error "Did not expect socket to be closed")
 where
  recv' leftOver i =
    modifyMVar
      (\input -> swap $ B.splitAt i input)
      leftOver
```

We really liked this technique because it avoids creating lots of typeclesses,
and having to do a lot of `newtype` gymnastics when creating mocks. We gradually
used it throughout our codebase and it turned out to be a great way of defining
the interfaces of all modules that perform IO actions.

Hopefully the example provided you with a gist of how this would work. As always,
let me know if you have any questions/suggestions/corrections.
