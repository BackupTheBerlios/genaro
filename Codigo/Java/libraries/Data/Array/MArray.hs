-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Array.MArray
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  non-portable
--
-- An overloaded interface to mutable arrays.  For array types which can be
-- used with this interface, see "Data.Array.IO", "Data.Array.ST", 
-- and "Data.Array.Storable".
--
-----------------------------------------------------------------------------

module Data.Array.MArray ( 
    -- * Class of mutable array types
    MArray,       -- :: (* -> * -> *) -> * -> (* -> *) -> class

    -- * Class of array types with bounds
    HasBounds,    -- :: (* -> * -> *) -> class

    -- * The @Ix@ class and operations
    module Data.Ix,

    -- * Constructing mutable arrays
    newArray,     -- :: (MArray a e m, Ix i) => (i,i) -> e -> m (a i e)
    newArray_,    -- :: (MArray a e m, Ix i) => (i,i) -> m (a i e)
    newListArray, -- :: (MArray a e m, Ix i) => (i,i) -> [e] -> m (a i e)

    -- * Reading and writing mutable arrays
    readArray,    -- :: (MArray a e m, Ix i) => a i e -> i -> m e
    writeArray,   -- :: (MArray a e m, Ix i) => a i e -> i -> e -> m ()

    -- * Derived arrays
    mapArray,     -- :: (MArray a e' m, MArray a e m, Ix i) => (e' -> e) -> a i e' -> m (a i e)
    mapIndices,   -- :: (MArray a e m, Ix i, Ix j) => (i,i) -> (i -> j) -> a j e -> m (a i e)

    -- * Deconstructing mutable arrays
    bounds,       -- :: (HasBounds a, Ix i) => a i e -> (i,i)
    indices,      -- :: (HasBounds a, Ix i) => a i e -> [i]
    getElems,     -- :: (MArray a e m, Ix i) => a i e -> m [e]
    getAssocs,    -- :: (MArray a e m, Ix i) => a i e -> m [(i, e)]

    -- * Conversions between mutable and immutable arrays
    freeze,       -- :: (Ix i, MArray a e m, IArray b e) => a i e -> m (b i e)
    unsafeFreeze, -- :: (Ix i, MArray a e m, IArray b e) => a i e -> m (b i e)
    thaw,         -- :: (Ix i, IArray a e, MArray b e m) => a i e -> m (b i e)
    unsafeThaw,   -- :: (Ix i, IArray a e, MArray b e m) => a i e -> m (b i e)
  ) where

import Prelude

import Data.Ix
import Data.Array.Base
