{-# OPTIONS -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Foreign.StablePtr
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  ffi@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- This module is part of the Foreign Function Interface (FFI) and will usually
-- be imported via the module "Foreign".
--
-----------------------------------------------------------------------------


module Foreign.StablePtr
        ( -- * Stable references to Haskell values
	  StablePtr          -- abstract
        , newStablePtr       -- :: a -> IO (StablePtr a)
        , deRefStablePtr     -- :: StablePtr a -> IO a
        , freeStablePtr      -- :: StablePtr a -> IO ()
        , castStablePtrToPtr -- :: StablePtr a -> Ptr ()
        , castPtrToStablePtr -- :: Ptr () -> StablePtr a
	, -- ** The C-side interface

	  -- $cinterface
        ) where




import Hugs.StablePtr




-- $cinterface
--
-- The following definition is available to C programs inter-operating with
-- Haskell code when including the header @HsFFI.h@.
--
-- > typedef void *HsStablePtr;  
--
-- Note that no assumptions may be made about the values representing stable
-- pointers.  In fact, they need not even be valid memory addresses.  The only
-- guarantee provided is that if they are passed back to Haskell land, the
-- function 'deRefStablePtr' will be able to reconstruct the
-- Haskell value refereed to by the stable pointer.
