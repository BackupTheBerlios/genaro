%
% (c) The AQUA Project, Glasgow University, 1998
%

\section[NumExts]{Misc numeric bits}

\begin{code}
module NumExts

       (
         doubleToFloat   -- :: Double -> Float
       , floatToDouble   -- :: Float -> Double

       , showHex         -- :: Integral a => a -> ShowS
       , showOct         -- :: Integral a => a -> ShowS
       , showBin         -- :: Integral a => a -> ShowS

	 -- general purpose number->string converter.
       , showIntAtBase   -- :: Integral a 
			 -- => a		-- base
			 -- -> (a -> Char)      -- digit to char
			 -- -> a                -- number to show.
			 -- -> ShowS
       , showListWith    -- :: (a -> ShowS)
			 -- -> [a]
			 -- -> ShowS
       ) where

import Data.Char ( intToDigit )
import Numeric   ( showHex, showOct, showIntAtBase )
import Text.Show ( showListWith )

\end{code}

\begin{code}

primitive doubleToFloat :: Double -> Float
primitive floatToDouble :: Float -> Double




showBin :: Integral a => a -> ShowS
showBin = showIntAtBase 2 (intToDigit.fromIntegral)
\end{code}
