{-# LINE 1 "fptools\libraries\network\Network\BSD.hsc" #-}
{-# LINE 2 "fptools\libraries\network\Network\BSD.hsc" #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Network.BSD
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/net/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  non-portable
--
-- The "Network.BSD" module defines Haskell bindings to functionality
-- provided by BSD Unix derivatives. Currently this covers
-- network programming functionality and symbolic links.
-- (OK, so the latter is pretty much supported by most Unixes
-- today, but it was BSD that introduced them.)  
--
-- The symlink stuff is really in the wrong place, at some point it will move
-- to a generic Unix library somewhere else in the module tree.
--
-----------------------------------------------------------------------------


{-# LINE 24 "fptools\libraries\network\Network\BSD.hsc" #-}

module Network.BSD (
       
    -- * Host names
    HostName,
    getHostName,	    -- :: IO HostName

    HostEntry(..),
    getHostByName,	    -- :: HostName -> IO HostEntry
    getHostByAddr,	    -- :: HostAddress -> Family -> IO HostEntry
    hostAddress,	    -- :: HostEntry -> HostAddress


{-# LINE 42 "fptools\libraries\network\Network\BSD.hsc" #-}

    -- * Service names
    ServiceEntry(..),
    ServiceName,
    getServiceByName,	    -- :: ServiceName -> ProtocolName -> IO ServiceEntry
    getServiceByPort,       -- :: PortNumber  -> ProtocolName -> IO ServiceEntry
    getServicePortNumber,   -- :: ServiceName -> IO PortNumber


{-# LINE 56 "fptools\libraries\network\Network\BSD.hsc" #-}

    -- * Protocol names
    ProtocolName,
    ProtocolNumber,
    ProtocolEntry(..),
    getProtocolByName,	    -- :: ProtocolName   -> IO ProtocolEntry
    getProtocolByNumber,    -- :: ProtocolNumber -> IO ProtcolEntry
    getProtocolNumber,	    -- :: ProtocolName   -> ProtocolNumber


{-# LINE 71 "fptools\libraries\network\Network\BSD.hsc" #-}

    -- * Port numbers
    PortNumber,

    -- * Network names
    NetworkName,
    NetworkAddr,
    NetworkEntry(..)


{-# LINE 88 "fptools\libraries\network\Network\BSD.hsc" #-}


{-# LINE 93 "fptools\libraries\network\Network\BSD.hsc" #-}

{-# LINE 96 "fptools\libraries\network\Network\BSD.hsc" #-}

    ) where


{-# LINE 100 "fptools\libraries\network\Network\BSD.hsc" #-}
import Hugs.Prelude

{-# LINE 102 "fptools\libraries\network\Network\BSD.hsc" #-}
import Network.Socket

import Foreign.C.Error ( throwErrnoIfMinus1, throwErrnoIfMinus1_ )
import Foreign.C.String ( CString, peekCString, peekCStringLen, withCString )
import Foreign.C.Types ( CInt, CULong, CChar, CSize, CShort )
import Foreign.Ptr ( Ptr, nullPtr )
import Foreign.Storable ( Storable(..) )
import Foreign.Marshal.Array ( allocaArray0, peekArray0 )
import Foreign.Marshal.Utils ( with, fromBool )


{-# LINE 115 "fptools\libraries\network\Network\BSD.hsc" #-}

import Control.Monad ( liftM )

-- ---------------------------------------------------------------------------
-- Basic Types

type HostName     = String
type ProtocolName = String
type ServiceName  = String

-- ---------------------------------------------------------------------------
-- Service Database Access

-- Calling getServiceByName for a given service and protocol returns
-- the systems service entry.  This should be used to find the port
-- numbers for standard protocols such as SMTP and FTP.  The remaining
-- three functions should be used for browsing the service database
-- sequentially.

-- Calling setServiceEntry with True indicates that the service
-- database should be left open between calls to getServiceEntry.  To
-- close the database a call to endServiceEntry is required.  This
-- database file is usually stored in the file /etc/services.

data ServiceEntry  = 
  ServiceEntry  {
     serviceName     :: ServiceName,	-- Official Name
     serviceAliases  :: [ServiceName],	-- aliases
     servicePort     :: PortNumber,	-- Port Number  ( network byte order )
     serviceProtocol :: ProtocolName	-- Protocol
  } deriving (Show)

instance Storable ServiceEntry where
   sizeOf    _ = 16
{-# LINE 149 "fptools\libraries\network\Network\BSD.hsc" #-}
   alignment _ = alignment (undefined :: CInt) -- ???

   peek p = do
	s_name    <- ((\hsc_ptr -> peekByteOff hsc_ptr 0)) p >>= peekCString
{-# LINE 153 "fptools\libraries\network\Network\BSD.hsc" #-}
	s_aliases <- ((\hsc_ptr -> peekByteOff hsc_ptr 4)) p
{-# LINE 154 "fptools\libraries\network\Network\BSD.hsc" #-}
			   >>= peekArray0 nullPtr
			   >>= mapM peekCString
	s_port    <- ((\hsc_ptr -> peekByteOff hsc_ptr 8)) p
{-# LINE 157 "fptools\libraries\network\Network\BSD.hsc" #-}
	s_proto   <- ((\hsc_ptr -> peekByteOff hsc_ptr 12)) p >>= peekCString
{-# LINE 158 "fptools\libraries\network\Network\BSD.hsc" #-}
	return (ServiceEntry {
			serviceName     = s_name,
			serviceAliases  = s_aliases,

{-# LINE 162 "fptools\libraries\network\Network\BSD.hsc" #-}
			servicePort     = PortNum (fromIntegral (s_port :: CShort)),

{-# LINE 168 "fptools\libraries\network\Network\BSD.hsc" #-}
			serviceProtocol = s_proto
		})

   poke p = error "Storable.poke(BSD.ServiceEntry) not implemented"


getServiceByName :: ServiceName 	-- Service Name
		 -> ProtocolName 	-- Protocol Name
		 -> IO ServiceEntry	-- Service Entry
getServiceByName name proto = do
 withCString name  $ \ cstr_name  -> do
 withCString proto $ \ cstr_proto -> do
 throwNoSuchThingIfNull "getServiceByName" "no such service entry"
   $ (trySysCall (c_getservbyname cstr_name cstr_proto))
 >>= peek

foreign import ccall unsafe "HsNet.h getservbyname" 
  c_getservbyname :: CString -> CString -> IO (Ptr ServiceEntry)

getServiceByPort :: PortNumber -> ProtocolName -> IO ServiceEntry
getServiceByPort (PortNum port) proto = do
 withCString proto $ \ cstr_proto -> do
 throwNoSuchThingIfNull "getServiceByPort" "no such service entry"
   $ (trySysCall (c_getservbyport (fromIntegral port) cstr_proto))
 >>= peek

foreign import ccall unsafe "HsNet.h getservbyport" 
  c_getservbyport :: CInt -> CString -> IO (Ptr ServiceEntry)

getServicePortNumber :: ServiceName -> IO PortNumber
getServicePortNumber name = do
    (ServiceEntry _ _ port _) <- getServiceByName name "tcp"
    return port


{-# LINE 226 "fptools\libraries\network\Network\BSD.hsc" #-}

-- ---------------------------------------------------------------------------
-- Protocol Entries

-- The following relate directly to the corresponding UNIX C
-- calls for returning the protocol entries. The protocol entry is
-- represented by the Haskell type ProtocolEntry.

-- As for setServiceEntry above, calling setProtocolEntry.
-- determines whether or not the protocol database file, usually
-- @/etc/protocols@, is to be kept open between calls of
-- getProtocolEntry. Similarly, 

data ProtocolEntry = 
  ProtocolEntry  {
     protoName    :: ProtocolName,	-- Official Name
     protoAliases :: [ProtocolName],	-- aliases
     protoNumber  :: ProtocolNumber	-- Protocol Number
  } deriving (Read, Show)

instance Storable ProtocolEntry where
   sizeOf    _ = 12
{-# LINE 248 "fptools\libraries\network\Network\BSD.hsc" #-}
   alignment _ = alignment (undefined :: CInt) -- ???

   peek p = do
	p_name    <- ((\hsc_ptr -> peekByteOff hsc_ptr 0)) p >>= peekCString
{-# LINE 252 "fptools\libraries\network\Network\BSD.hsc" #-}
	p_aliases <- ((\hsc_ptr -> peekByteOff hsc_ptr 4)) p
{-# LINE 253 "fptools\libraries\network\Network\BSD.hsc" #-}
			   >>= peekArray0 nullPtr
			   >>= mapM peekCString

{-# LINE 256 "fptools\libraries\network\Network\BSD.hsc" #-}
         -- With WinSock, the protocol number is only a short;
	 -- hoist it in as such, but represent it on the Haskell side
	 -- as a CInt.
	p_proto_short  <- ((\hsc_ptr -> peekByteOff hsc_ptr 8)) p 
{-# LINE 260 "fptools\libraries\network\Network\BSD.hsc" #-}
	let p_proto = fromIntegral (p_proto_short :: CShort)

{-# LINE 264 "fptools\libraries\network\Network\BSD.hsc" #-}
	return (ProtocolEntry { 
			protoName    = p_name,
			protoAliases = p_aliases,
			protoNumber  = p_proto
		})

   poke p = error "Storable.poke(BSD.ProtocolEntry) not implemented"

getProtocolByName :: ProtocolName -> IO ProtocolEntry
getProtocolByName name = do
 withCString name $ \ name_cstr -> do
 throwNoSuchThingIfNull "getServiceEntry" "no such service entry"
   $ (trySysCall.c_getprotobyname) name_cstr
 >>= peek

foreign import  ccall unsafe  "HsNet.h getprotobyname" 
   c_getprotobyname :: CString -> IO (Ptr ProtocolEntry)


getProtocolByNumber :: ProtocolNumber -> IO ProtocolEntry
getProtocolByNumber num = do
 throwNoSuchThingIfNull "getServiceEntry" "no such service entry"
   $ (trySysCall.c_getprotobynumber) (fromIntegral num)
 >>= peek

foreign import ccall unsafe  "HsNet.h getprotobynumber"
   c_getprotobynumber :: CInt -> IO (Ptr ProtocolEntry)


getProtocolNumber :: ProtocolName -> IO ProtocolNumber
getProtocolNumber proto = do
 (ProtocolEntry _ _ num) <- getProtocolByName proto
 return num


{-# LINE 322 "fptools\libraries\network\Network\BSD.hsc" #-}

-- ---------------------------------------------------------------------------
-- Host lookups

data HostEntry = 
  HostEntry  {
     hostName      :: HostName,  	-- Official Name
     hostAliases   :: [HostName],	-- aliases
     hostFamily    :: Family,	        -- Host Type (currently AF_INET)
     hostAddresses :: [HostAddress]	-- Set of Network Addresses  (in network byte order)
  } deriving (Read, Show)

instance Storable HostEntry where
   sizeOf    _ = 16
{-# LINE 336 "fptools\libraries\network\Network\BSD.hsc" #-}
   alignment _ = alignment (undefined :: CInt) -- ???

   peek p = do
	h_name       <- ((\hsc_ptr -> peekByteOff hsc_ptr 0)) p >>= peekCString
{-# LINE 340 "fptools\libraries\network\Network\BSD.hsc" #-}
	h_aliases    <- ((\hsc_ptr -> peekByteOff hsc_ptr 4)) p
{-# LINE 341 "fptools\libraries\network\Network\BSD.hsc" #-}
				>>= peekArray0 nullPtr
				>>= mapM peekCString
	h_addrtype   <- ((\hsc_ptr -> peekByteOff hsc_ptr 8)) p
{-# LINE 344 "fptools\libraries\network\Network\BSD.hsc" #-}
	-- h_length       <- (#peek struct hostent, h_length) p
	h_addr_list  <- ((\hsc_ptr -> peekByteOff hsc_ptr 12)) p
{-# LINE 346 "fptools\libraries\network\Network\BSD.hsc" #-}
				>>= peekArray0 nullPtr
				>>= mapM peek
	return (HostEntry {
			hostName       = h_name,
			hostAliases    = h_aliases,
			hostFamily     = unpackFamily h_addrtype,
			hostAddresses  = h_addr_list
		})

   poke p = error "Storable.poke(BSD.ServiceEntry) not implemented"


-- convenience function:
hostAddress :: HostEntry -> HostAddress
hostAddress (HostEntry nm _ _ ls) =
 case ls of
   []    -> error ("BSD.hostAddress: empty network address list for " ++ nm)
   (x:_) -> x

getHostByName :: HostName -> IO HostEntry
getHostByName name = do
  withCString name $ \ name_cstr -> do
   ent <- throwNoSuchThingIfNull "getHostByName" "no such host entry"
    		$ trySysCall $ c_gethostbyname name_cstr
   peek ent

foreign import ccall unsafe "HsNet.h gethostbyname" 
   c_gethostbyname :: CString -> IO (Ptr HostEntry)

getHostByAddr :: Family -> HostAddress -> IO HostEntry
getHostByAddr family addr = do
 with addr $ \ ptr_addr -> do
 throwNoSuchThingIfNull 	"getHostByAddr" "no such host entry"
   $ trySysCall $ c_gethostbyaddr ptr_addr (fromIntegral (sizeOf addr)) (packFamily family)
 >>= peek

foreign import ccall unsafe "HsNet.h gethostbyaddr"
   c_gethostbyaddr :: Ptr HostAddress -> CInt -> CInt -> IO (Ptr HostEntry)


{-# LINE 409 "fptools\libraries\network\Network\BSD.hsc" #-}

-- ---------------------------------------------------------------------------
-- Accessing network information

-- Same set of access functions as for accessing host,protocol and
-- service system info, this time for the types of networks supported.

-- network addresses are represented in host byte order.
type NetworkAddr = CULong

type NetworkName = String

data NetworkEntry =
  NetworkEntry {
     networkName	:: NetworkName,   -- official name
     networkAliases	:: [NetworkName], -- aliases
     networkFamily	:: Family,	   -- type
     networkAddress	:: NetworkAddr
   } deriving (Read, Show)

instance Storable NetworkEntry where
   sizeOf    _ = 16
{-# LINE 431 "fptools\libraries\network\Network\BSD.hsc" #-}
   alignment _ = alignment (undefined :: CInt) -- ???

   peek p = do
	n_name         <- ((\hsc_ptr -> peekByteOff hsc_ptr 0)) p >>= peekCString
{-# LINE 435 "fptools\libraries\network\Network\BSD.hsc" #-}
	n_aliases      <- ((\hsc_ptr -> peekByteOff hsc_ptr 4)) p
{-# LINE 436 "fptools\libraries\network\Network\BSD.hsc" #-}
			 	>>= peekArray0 nullPtr
			   	>>= mapM peekCString
	n_addrtype     <- ((\hsc_ptr -> peekByteOff hsc_ptr 8)) p
{-# LINE 439 "fptools\libraries\network\Network\BSD.hsc" #-}
	n_net          <- ((\hsc_ptr -> peekByteOff hsc_ptr 12)) p
{-# LINE 440 "fptools\libraries\network\Network\BSD.hsc" #-}
	return (NetworkEntry {
			networkName      = n_name,
			networkAliases   = n_aliases,
			networkFamily    = unpackFamily (fromIntegral 
					    (n_addrtype :: CInt)),
			networkAddress   = n_net
		})

   poke p = error "Storable.poke(BSD.NetEntry) not implemented"



{-# LINE 494 "fptools\libraries\network\Network\BSD.hsc" #-}

-- ---------------------------------------------------------------------------
-- Miscellaneous Functions

-- Calling getHostName returns the standard host name for the current
-- processor, as set at boot time.

getHostName :: IO HostName
getHostName = do
  let size = 256
  allocaArray0 size $ \ cstr -> do
    throwSocketErrorIfMinus1_ "getHostName" $ c_gethostname cstr (fromIntegral size)
    peekCString cstr

foreign import ccall unsafe "HsNet.h gethostname" 
   c_gethostname :: CString -> CSize -> IO CInt

-- Helper function used by the exported functions that provides a
-- Haskellised view of the enumerator functions:

getEntries :: IO a  -- read
           -> IO () -- at end
	   -> IO [a]
getEntries getOne atEnd = loop
  where
    loop = do
      vv <- catch (liftM Just getOne) ((const.return) Nothing)
      case vv of
        Nothing -> return []
        Just v  -> loop >>= \ vs -> atEnd >> return (v:vs)


-- ---------------------------------------------------------------------------
-- Symbolic links


{-# LINE 540 "fptools\libraries\network\Network\BSD.hsc" #-}


{-# LINE 554 "fptools\libraries\network\Network\BSD.hsc" #-}

-- ---------------------------------------------------------------------------
-- Winsock only:
--   The BSD API networking calls made locally return NULL upon failure.
--   That failure may very well be due to WinSock not being initialised,
--   so if NULL is seen try init'ing and repeat the call.

{-# LINE 563 "fptools\libraries\network\Network\BSD.hsc" #-}
trySysCall act = do
  ptr <- act
  if (ptr == nullPtr)
   then withSocketsDo act
   else return ptr

{-# LINE 569 "fptools\libraries\network\Network\BSD.hsc" #-}

throwNoSuchThingIfNull :: String -> String -> IO (Ptr a) -> IO (Ptr a)
throwNoSuchThingIfNull loc desc act = do
  ptr <- act
  if (ptr == nullPtr)
   then ioError (IOError Nothing NoSuchThing
	loc desc Nothing)
   else return ptr
