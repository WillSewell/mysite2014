---
title: 3 part series on Haskell performance
description: >-
  3 part series on improving performance of Haskell programs.
---

Over the last couple of months I have been writing up tips and techniques I have
come across while optimising our Haskell-based message bus. These appear as
a series of three posts on the Pusher blog, and you can dive into whichever you
like depending on what you are trying to do.

[Top tips and tools for optimising Haskell](http://blog.pusher.com/top-tips-and-tools-for-optimising-haskell/)

This post goes into some simple tricks that can improve performance, as well as
tools you will likely want to try when investigating CPU usage.

[Memory profiling in Haskell](http://blog.pusher.com/memory-profiling-in-haskell/)

This post looks at tools that you can use to get an insight into the memory
usage of your program. There are two reasons why you would want to do this:

1. to find performance bottlenecks
2. to track down memory leaks

[Making Efficient use of memory in Haskell](http://blog.pusher.com/making-efficient-use-of-memory-in-haskell/)

Finally I present all the ways I have found so far for making as efficient use
of memory as possible.

This is by no means the end of our journey with optimising this codebase -- we
still have issues with both 99th percentile latency in our store and throughout
in the serialisation. If I find other other techniques, I will post them up
here.
