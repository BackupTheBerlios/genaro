{-# OPTIONS -#include "config.h" #-}
{-# LINE 1 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}
-----------------------------------------------------------------------------
{-# LINE 2 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}
-- |
-- Module      :  Text.Regex.Posix
-- Copyright   :  (c) The University of Glasgow 2002
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  non-portable (needs POSIX regexps)
--
-- Interface to the POSIX regular expression library.
--
-----------------------------------------------------------------------------

-- ToDo: should have an interface using PackedStrings.

{-# LINE 17 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}

module Text.Regex.Posix (
	-- * The @Regex@ type
	Regex,	 	-- abstract


{-# LINE 40 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}
  ) where


{-# LINE 46 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}

import Prelude

import Foreign
import Foreign.C

type CRegex    = ()

-- | A compiled regular expression
newtype Regex = Regex (ForeignPtr CRegex)


{-# LINE 179 "fptools\libraries\base\Text\Regex\Posix.hsc" #-}
