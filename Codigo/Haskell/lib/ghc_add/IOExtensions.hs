-----------------------------------------------------------------------------
-- 
-- Replacement for IOExtensions.hs of hugs for ghc
--
-- Implements only the functions necessary for Haskore!
--
-- Does not work under Windows (where there is a difference between 
-- binary and text files)
--
-- Suitable for use with Hugs 98
-----------------------------------------------------------------------------

module IOExtensions(
        writeBinaryFile,
	openBinaryFile, readBinaryFile
	) where

import System( getArgs )
import IO( Handle, IOMode(WriteMode), openFile, hPutStr, hClose )
import IOExts

openBinaryFile         :: FilePath -> IOMode -> IO Handle
openBinaryFile path mode = openFileEx path (BinaryMode mode)

writeBinaryFile   	 :: FilePath -> String -> IO ()
writeBinaryFile = writeFile                     -- this does not work on Windows!!!

readBinaryFile    	 :: FilePath -> IO String
readBinaryFile = readFile                       -- this does not work on Windows!!!


