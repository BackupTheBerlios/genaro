{-# OPTIONS -#include "config.h" #-}
{-# OPTIONS -#include "HsBase.h" #-}
{-# LINE 1 "fptools\libraries\base\System\Posix\Signals.hsc" #-}
-----------------------------------------------------------------------------
{-# LINE 2 "fptools\libraries\base\System\Posix\Signals.hsc" #-}
-- |
-- Module      :  System.Posix.Signals
-- Copyright   :  (c) The University of Glasgow 2002
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  non-portable (requires POSIX)
--
-- POSIX signal support
--
-----------------------------------------------------------------------------


{-# LINE 16 "fptools\libraries\base\System\Posix\Signals.hsc" #-}

module System.Posix.Signals (

{-# LINE 92 "fptools\libraries\base\System\Posix\Signals.hsc" #-}
  ) where


{-# LINE 97 "fptools\libraries\base\System\Posix\Signals.hsc" #-}

{-# LINE 98 "fptools\libraries\base\System\Posix\Signals.hsc" #-}

{-# LINE 99 "fptools\libraries\base\System\Posix\Signals.hsc" #-}

import Foreign
import Foreign.C
import System.IO.Unsafe
import System.Posix.Types
import System.Posix.Internals


{-# LINE 504 "fptools\libraries\base\System\Posix\Signals.hsc" #-}

