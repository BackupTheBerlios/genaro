{-# LINE 1 "fptools\libraries\network\Network\Socket.hsc" #-}
{-# LINE 2 "fptools\libraries\network\Network\Socket.hsc" #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Network.Socket
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/core/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- The "Network.Socket" module is for when you want full control over
-- sockets.  Essentially the entire C socket API is exposed through
-- this module; in general the operations follow the behaviour of the C
-- functions of the same name (consult your favourite Unix networking book).
--
-- A higher level interface to networking operations is provided
-- through the module "Network".
--
-----------------------------------------------------------------------------


{-# LINE 23 "fptools\libraries\network\Network\Socket.hsc" #-}


{-# LINE 25 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 26 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 27 "fptools\libraries\network\Network\Socket.hsc" #-}


{-# LINE 31 "fptools\libraries\network\Network\Socket.hsc" #-}


{-# LINE 39 "fptools\libraries\network\Network\Socket.hsc" #-}

-- In order to process this file, you need to have CALLCONV defined.

module Network.Socket (

    -- * Types
    Socket(..),		-- instance Eq, Show
    Family(..),		
    SocketType(..),
    SockAddr(..),
    SocketStatus(..),
    HostAddress,
    ShutdownCmd(..),
    ProtocolNumber,
    PortNumber(..),

    -- * Socket Operations
    socket,		-- :: Family -> SocketType -> ProtocolNumber -> IO Socket 

{-# LINE 60 "fptools\libraries\network\Network\Socket.hsc" #-}
    connect,		-- :: Socket -> SockAddr -> IO ()
    bindSocket,		-- :: Socket -> SockAddr -> IO ()
    listen,		-- :: Socket -> Int -> IO ()
    accept,		-- :: Socket -> IO (Socket, SockAddr)
    getPeerName,	-- :: Socket -> IO SockAddr
    getSocketName,	-- :: Socket -> IO SockAddr


{-# LINE 71 "fptools\libraries\network\Network\Socket.hsc" #-}

    socketPort,		-- :: Socket -> IO PortNumber

    socketToHandle,	-- :: Socket -> IOMode -> IO Handle

    sendTo,		-- :: Socket -> String -> SockAddr -> IO Int
    recvFrom,		-- :: Socket -> Int -> IO (String, Int, SockAddr)
    
    send,		-- :: Socket -> String -> IO Int
    recv,		-- :: Socket -> Int    -> IO String
    recvLen,            -- :: Socket -> Int    -> IO (String, Int)

    inet_addr,		-- :: String -> IO HostAddress
    inet_ntoa,		-- :: HostAddress -> IO String

    shutdown,		-- :: Socket -> ShutdownCmd -> IO ()
    sClose,		-- :: Socket -> IO ()

    -- ** Predicates on sockets
    sIsConnected,	-- :: Socket -> IO Bool
    sIsBound,		-- :: Socket -> IO Bool
    sIsListening,	-- :: Socket -> IO Bool 
    sIsReadable,	-- :: Socket -> IO Bool
    sIsWritable,	-- :: Socket -> IO Bool

    -- * Socket options
    SocketOption(..),
    getSocketOption,     -- :: Socket -> SocketOption -> IO Int
    setSocketOption,     -- :: Socket -> SocketOption -> Int -> IO ()

    -- * File descriptor transmission

{-# LINE 111 "fptools\libraries\network\Network\Socket.hsc" #-}

    -- * Special Constants
    aNY_PORT,		-- :: PortNumber
    iNADDR_ANY,		-- :: HostAddress
    sOMAXCONN,		-- :: Int
    sOL_SOCKET,         -- :: Int

{-# LINE 120 "fptools\libraries\network\Network\Socket.hsc" #-}
    maxListenQueue,	-- :: Int

    -- * Initialisation
    withSocketsDo,	-- :: IO a -> IO a
    
    -- * Very low level operations
     -- in case you ever want to get at the underlying file descriptor..
    fdSocket,           -- :: Socket -> CInt
    mkSocket,           -- :: CInt   -> Family 
    			-- -> SocketType
			-- -> ProtocolNumber
			-- -> SocketStatus
			-- -> IO Socket

    -- * Internal

    -- | The following are exported ONLY for use in the BSD module and
    -- should not be used anywhere else.

    packFamily, unpackFamily,
    packSocketType,
    throwSocketErrorIfMinus1_

) where


{-# LINE 146 "fptools\libraries\network\Network\Socket.hsc" #-}
import Hugs.Prelude
import Hugs.IO ( openFd )

{-# CBITS HsNet.c initWinSock.c ancilData.c winSockErr.c #-}

{-# LINE 151 "fptools\libraries\network\Network\Socket.hsc" #-}

import Data.Word ( Word8, Word16, Word32 )
import Foreign.Ptr ( Ptr, castPtr, plusPtr )
import Foreign.Storable ( Storable(..) )
import Foreign.C.Error
import Foreign.C.String ( withCString, peekCString, peekCStringLen, castCharToCChar )
import Foreign.C.Types ( CInt, CUInt, CChar, CSize )
import Foreign.Marshal.Alloc ( alloca, allocaBytes )
import Foreign.Marshal.Array ( peekArray, pokeArray0 )
import Foreign.Marshal.Utils ( with )

import System.IO
import Control.Monad ( liftM, when )
import Data.Ratio ( (%) )

import qualified Control.Exception
import Control.Concurrent.MVar


{-# LINE 179 "fptools\libraries\network\Network\Socket.hsc" #-}

-----------------------------------------------------------------------------
-- Socket types

-- There are a few possible ways to do this.  The first is convert the
-- structs used in the C library into an equivalent Haskell type. An
-- other possible implementation is to keep all the internals in the C
-- code and use an Int## and a status flag. The second method is used
-- here since a lot of the C structures are not required to be
-- manipulated.

-- Originally the status was non-mutable so we had to return a new
-- socket each time we changed the status.  This version now uses
-- mutable variables to avoid the need to do this.  The result is a
-- cleaner interface and better security since the application
-- programmer now can't circumvent the status information to perform
-- invalid operations on sockets.

data SocketStatus
  -- Returned Status	Function called
  = NotConnected	-- socket
  | Bound		-- bindSocket
  | Listening		-- listen
  | Connected		-- connect/accept
    deriving (Eq, Show)

data Socket
  = MkSocket
	    CInt	         -- File Descriptor
	    Family				  
	    SocketType				  
	    ProtocolNumber	 -- Protocol Number
	    (MVar SocketStatus)  -- Status Flag

mkSocket :: CInt
	 -> Family
	 -> SocketType
	 -> ProtocolNumber
	 -> SocketStatus
	 -> IO Socket
mkSocket fd fam sType pNum stat = do
   mStat <- newMVar stat
   return (MkSocket fd fam sType pNum mStat)

instance Eq Socket where
  (MkSocket _ _ _ _ m1) == (MkSocket _ _ _ _ m2) = m1 == m2

instance Show Socket where
  showsPrec n (MkSocket fd _ _ _ _) = 
	showString "<socket: " . shows fd . showString ">"


fdSocket :: Socket -> CInt
fdSocket (MkSocket fd _ _ _ _) = fd

type ProtocolNumber = CInt

-- NOTE: HostAddresses are represented in network byte order.
--       Functions that expect the address in machine byte order
--       will have to perform the necessary translation.
type HostAddress = Word32

----------------------------------------------------------------------------
-- Port Numbers
--
-- newtyped to prevent accidental use of sane-looking
-- port numbers that haven't actually been converted to
-- network-byte-order first.
--
newtype PortNumber = PortNum Word16 deriving ( Eq, Ord )

instance Show PortNumber where
  showsPrec p pn = showsPrec p (portNumberToInt pn)

intToPortNumber :: Int -> PortNumber
intToPortNumber v = PortNum (htons (fromIntegral v))

portNumberToInt :: PortNumber -> Int
portNumberToInt (PortNum po) = fromIntegral (ntohs po)

foreign import stdcall unsafe "HsNet.h ntohs" ntohs :: Word16 -> Word16
foreign import stdcall unsafe "HsNet.h htons" htons :: Word16 -> Word16
--foreign import CALLCONV unsafe "ntohl" ntohl :: Word32 -> Word32
foreign import stdcall unsafe "HsNet.h htonl" htonl :: Word32 -> Word32

instance Enum PortNumber where
    toEnum   = intToPortNumber
    fromEnum = portNumberToInt

instance Num PortNumber where
   fromInteger i = intToPortNumber (fromInteger i)
    -- for completeness.
   (+) x y   = intToPortNumber (portNumberToInt x + portNumberToInt y)
   (-) x y   = intToPortNumber (portNumberToInt x - portNumberToInt y)
   negate x  = intToPortNumber (-portNumberToInt x)
   (*) x y   = intToPortNumber (portNumberToInt x * portNumberToInt y)
   abs n     = intToPortNumber (abs (portNumberToInt n))
   signum n  = intToPortNumber (signum (portNumberToInt n))

instance Real PortNumber where
    toRational x = toInteger x % 1

instance Integral PortNumber where
    quotRem a b = let (c,d) = quotRem (portNumberToInt a) (portNumberToInt b) in
		  (intToPortNumber c, intToPortNumber d)
    toInteger a = toInteger (portNumberToInt a)

instance Storable PortNumber where
   sizeOf    _ = sizeOf    (undefined :: Word16)
   alignment _ = alignment (undefined :: Word16)
   poke p (PortNum po) = poke (castPtr p) po
   peek p = PortNum `liftM` peek (castPtr p)

-----------------------------------------------------------------------------
-- SockAddr

-- The scheme used for addressing sockets is somewhat quirky. The
-- calls in the BSD socket API that need to know the socket address
-- all operate in terms of struct sockaddr, a `virtual' type of
-- socket address.

-- The Internet family of sockets are addressed as struct sockaddr_in,
-- so when calling functions that operate on struct sockaddr, we have
-- to type cast the Internet socket address into a struct sockaddr.
-- Instances of the structure for different families might *not* be
-- the same size. Same casting is required of other families of
-- sockets such as Xerox NS. Similarly for Unix domain sockets.

-- To represent these socket addresses in Haskell-land, we do what BSD
-- didn't do, and use a union/algebraic type for the different
-- families. Currently only Unix domain sockets and the Internet family
-- are supported.

data SockAddr		-- C Names				
  = SockAddrInet
	PortNumber	-- sin_port  (network byte order)
	HostAddress	-- sin_addr  (ditto)

{-# LINE 320 "fptools\libraries\network\Network\Socket.hsc" #-}
  deriving (Eq)


{-# LINE 323 "fptools\libraries\network\Network\Socket.hsc" #-}
type CSaFamily = (Word16)
{-# LINE 324 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 329 "fptools\libraries\network\Network\Socket.hsc" #-}

-- we can't write an instance of Storable for SockAddr, because the Storable
-- class can't easily handle alternatives.


{-# LINE 339 "fptools\libraries\network\Network\Socket.hsc" #-}
pokeSockAddr p (SockAddrInet (PortNum port) addr) = do
	((\hsc_ptr -> pokeByteOff hsc_ptr 0)) p ((2) :: CSaFamily)
{-# LINE 341 "fptools\libraries\network\Network\Socket.hsc" #-}
	((\hsc_ptr -> pokeByteOff hsc_ptr 2)) p port
{-# LINE 342 "fptools\libraries\network\Network\Socket.hsc" #-}
	((\hsc_ptr -> pokeByteOff hsc_ptr 4)) p addr	
{-# LINE 343 "fptools\libraries\network\Network\Socket.hsc" #-}

peekSockAddr p = do
  family <- ((\hsc_ptr -> peekByteOff hsc_ptr 0)) p
{-# LINE 346 "fptools\libraries\network\Network\Socket.hsc" #-}
  case family :: CSaFamily of

{-# LINE 352 "fptools\libraries\network\Network\Socket.hsc" #-}
	(2) -> do
{-# LINE 353 "fptools\libraries\network\Network\Socket.hsc" #-}
		addr <- ((\hsc_ptr -> peekByteOff hsc_ptr 4)) p
{-# LINE 354 "fptools\libraries\network\Network\Socket.hsc" #-}
		port <- ((\hsc_ptr -> peekByteOff hsc_ptr 2)) p
{-# LINE 355 "fptools\libraries\network\Network\Socket.hsc" #-}
		return (SockAddrInet (PortNum port) addr)

-- size of struct sockaddr by family

{-# LINE 361 "fptools\libraries\network\Network\Socket.hsc" #-}
sizeOfSockAddr_Family AF_INET = 16
{-# LINE 362 "fptools\libraries\network\Network\Socket.hsc" #-}

-- size of struct sockaddr by SockAddr

{-# LINE 367 "fptools\libraries\network\Network\Socket.hsc" #-}
sizeOfSockAddr (SockAddrInet _ _) = 16
{-# LINE 368 "fptools\libraries\network\Network\Socket.hsc" #-}

withSockAddr :: SockAddr -> (Ptr SockAddr -> Int -> IO a) -> IO a
withSockAddr addr f = do
 let sz = sizeOfSockAddr addr
 allocaBytes sz $ \p -> pokeSockAddr p addr >> f (castPtr p) sz

withNewSockAddr :: Family -> (Ptr SockAddr -> Int -> IO a) -> IO a
withNewSockAddr family f = do
 let sz = sizeOfSockAddr_Family family
 allocaBytes sz $ \ptr -> f ptr sz

-----------------------------------------------------------------------------
-- Connection Functions

-- In the following connection and binding primitives.  The names of
-- the equivalent C functions have been preserved where possible. It
-- should be noted that some of these names used in the C library,
-- \tr{bind} in particular, have a different meaning to many Haskell
-- programmers and have thus been renamed by appending the prefix
-- Socket.

-- Create an unconnected socket of the given family, type and
-- protocol.  The most common invocation of $socket$ is the following:
--    ...
--    my_socket <- socket AF_INET Stream 6
--    ...

socket :: Family 	 -- Family Name (usually AF_INET)
       -> SocketType 	 -- Socket Type (usually Stream)
       -> ProtocolNumber -- Protocol Number (getProtocolByName to find value)
       -> IO Socket	 -- Unconnected Socket

socket family stype protocol = do
    fd <- throwSocketErrorIfMinus1Retry "socket" $
		c_socket (packFamily family) (packSocketType stype) protocol

{-# LINE 406 "fptools\libraries\network\Network\Socket.hsc" #-}
    socket_status <- newMVar NotConnected
    return (MkSocket fd family stype protocol socket_status)

-- Create an unnamed pair of connected sockets, given family, type and
-- protocol. Differs from a normal pipe in being a bi-directional channel
-- of communication.


{-# LINE 439 "fptools\libraries\network\Network\Socket.hsc" #-}

-----------------------------------------------------------------------------
-- Binding a socket
--
-- Given a port number this {\em binds} the socket to that port. This
-- means that the programmer is only interested in data being sent to
-- that port number. The $Family$ passed to $bindSocket$ must
-- be the same as that passed to $socket$.	 If the special port
-- number $aNY\_PORT$ is passed then the system assigns the next
-- available use port.
-- 
-- Port numbers for standard unix services can be found by calling
-- $getServiceEntry$.  These are traditionally port numbers below
-- 1000; although there are afew, namely NFS and IRC, which used higher
-- numbered ports.
-- 
-- The port number allocated to a socket bound by using $aNY\_PORT$ can be
-- found by calling $port$

bindSocket :: Socket	-- Unconnected Socket
	   -> SockAddr	-- Address to Bind to
	   -> IO ()

bindSocket (MkSocket s _family _stype _protocol socketStatus) addr = do
 modifyMVar_ socketStatus $ \ status -> do
 if status /= NotConnected 
  then
   ioError (userError ("bindSocket: can't peform bind on socket in status " ++
	 show status))
  else do
   withSockAddr addr $ \p_addr sz -> do
   status <- throwSocketErrorIfMinus1Retry "bind" $ c_bind s p_addr (fromIntegral sz)
   return Bound

-----------------------------------------------------------------------------
-- Connecting a socket
--
-- Make a connection to an already opened socket on a given machine
-- and port.  assumes that we have already called createSocket,
-- otherwise it will fail.
--
-- This is the dual to $bindSocket$.  The {\em server} process will
-- usually bind to a port number, the {\em client} will then connect
-- to the same port number.  Port numbers of user applications are
-- normally agreed in advance, otherwise we must rely on some meta
-- protocol for telling the other side what port number we have been
-- allocated.

connect :: Socket	-- Unconnected Socket
	-> SockAddr 	-- Socket address stuff
	-> IO ()

connect sock@(MkSocket s _family _stype _protocol socketStatus) addr = do
 modifyMVar_ socketStatus $ \currentStatus -> do
 if currentStatus /= NotConnected 
  then
   ioError (userError ("connect: can't peform connect on socket in status " ++
         show currentStatus))
  else do
   withSockAddr addr $ \p_addr sz -> do

   let  connectLoop = do
       	   r <- c_connect s p_addr (fromIntegral sz)
       	   if r == -1
       	       then do 

{-# LINE 512 "fptools\libraries\network\Network\Socket.hsc" #-}
		       rc <- c_getLastError
		       case rc of
		         10093 -> do -- WSANOTINITIALISED
			   withSocketsDo (return ())
	       	           r <- c_connect s p_addr (fromIntegral sz)
	       	           if r == -1
			    then (c_getLastError >>= throwSocketError "connect")
			    else return r
			 _ -> throwSocketError "connect" rc

{-# LINE 522 "fptools\libraries\network\Network\Socket.hsc" #-}
       	       else return r

	connectBlocked = do 

{-# LINE 528 "fptools\libraries\network\Network\Socket.hsc" #-}
	   err <- getSocketOption sock SoError
	   if (err == 0)
	   	then return 0
	   	else do ioError (errnoToIOError "connect" 
	   			(Errno (fromIntegral err))
	   			Nothing Nothing)

   connectLoop
   return Connected

-----------------------------------------------------------------------------
-- Listen
--
-- The programmer must call $listen$ to tell the system software that
-- they are now interested in receiving data on this port.  This must
-- be called on the bound socket before any calls to read or write
-- data are made.

-- The programmer also gives a number which indicates the length of
-- the incoming queue of unread messages for this socket. On most
-- systems the maximum queue length is around 5.  To remove a message
-- from the queue for processing a call to $accept$ should be made.

listen :: Socket  -- Connected & Bound Socket
       -> Int 	  -- Queue Length
       -> IO ()

listen (MkSocket s _family _stype _protocol socketStatus) backlog = do
 modifyMVar_ socketStatus $ \ status -> do
 if status /= Bound 
   then
    ioError (userError ("listen: can't peform listen on socket in status " ++
          show status))
   else do
    throwSocketErrorIfMinus1Retry "listen" (c_listen s (fromIntegral backlog))
    return Listening

-----------------------------------------------------------------------------
-- Accept
--
-- A call to `accept' only returns when data is available on the given
-- socket, unless the socket has been set to non-blocking.  It will
-- return a new socket which should be used to read the incoming data and
-- should then be closed. Using the socket returned by `accept' allows
-- incoming requests to be queued on the original socket.

accept :: Socket			-- Queue Socket
       -> IO (Socket,			-- Readable Socket
	      SockAddr)			-- Peer details

accept sock@(MkSocket s family stype protocol status) = do
 currentStatus <- readMVar status
 okay <- sIsAcceptable sock
 if not okay
   then
     ioError (userError ("accept: can't perform accept on socket (" ++ (show (family,stype,protocol)) ++") in status " ++
	 show currentStatus))
   else do
     let sz = sizeOfSockAddr_Family family
     allocaBytes sz $ \ sockaddr -> do

{-# LINE 596 "fptools\libraries\network\Network\Socket.hsc" #-}
     with (fromIntegral sz) $ \ ptr_len -> do
     new_sock <- 

{-# LINE 602 "fptools\libraries\network\Network\Socket.hsc" #-}
			(c_accept s sockaddr ptr_len)

{-# LINE 606 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 607 "fptools\libraries\network\Network\Socket.hsc" #-}
     addr <- peekSockAddr sockaddr
     new_status <- newMVar Connected
     return ((MkSocket new_sock family stype protocol new_status), addr)


{-# LINE 621 "fptools\libraries\network\Network\Socket.hsc" #-}

-----------------------------------------------------------------------------
-- sendTo & recvFrom

sendTo :: Socket	-- (possibly) bound/connected Socket
       -> String	-- Data to send
       -> SockAddr
       -> IO Int	-- Number of Bytes sent

sendTo (MkSocket s _family _stype _protocol status) xs addr = do
 withSockAddr addr $ \p_addr sz -> do
 withCString xs $ \str -> do
   liftM fromIntegral $

{-# LINE 638 "fptools\libraries\network\Network\Socket.hsc" #-}
	c_sendto s str (fromIntegral $ length xs) 0{-flags-} 
			p_addr (fromIntegral sz)

recvFrom :: Socket -> Int -> IO (String, Int, SockAddr)
recvFrom sock@(MkSocket s _family _stype _protocol status) nbytes
 | nbytes <= 0 = ioError (mkInvalidRecvArgError "Network.Socket.recvFrom")
 | otherwise   = 
  allocaBytes nbytes $ \ptr -> do
    withNewSockAddr AF_INET $ \ptr_addr sz -> do
      alloca $ \ptr_len -> do
      	poke ptr_len (fromIntegral sz)
        len <- 

{-# LINE 654 "fptools\libraries\network\Network\Socket.hsc" #-}
        	   c_recvfrom s ptr (fromIntegral nbytes) 0{-flags-} 
				ptr_addr ptr_len
        let len' = fromIntegral len
	if len' == 0
	 then ioError (mkEOFError "Network.Socket.recvFrom")
	 else do
   	   flg <- sIsConnected sock
	     -- For at least one implementation (WinSock 2), recvfrom() ignores
	     -- filling in the sockaddr for connected TCP sockets. Cope with 
	     -- this by using getPeerName instead.
	   sockaddr <- 
		if flg then
		   getPeerName sock
		else
		   peekSockAddr ptr_addr 
           str <- peekCStringLen (ptr,len')
           return (str, len', sockaddr)

-----------------------------------------------------------------------------
-- send & recv

send :: Socket	-- Bound/Connected Socket
     -> String	-- Data to send
     -> IO Int	-- Number of Bytes sent
send (MkSocket s _family _stype _protocol status) xs = do
 withCString xs $ \str -> do
   liftM fromIntegral $

{-# LINE 685 "fptools\libraries\network\Network\Socket.hsc" #-}
	c_send s str (fromIntegral $ length xs) 0{-flags-} 

recv :: Socket -> Int -> IO String
recv sock l = recvLen sock l >>= \ (s,_) -> return s

recvLen :: Socket -> Int -> IO (String, Int)
recvLen sock@(MkSocket s _family _stype _protocol status) nbytes 
 | nbytes <= 0 = ioError (mkInvalidRecvArgError "Network.Socket.recv")
 | otherwise   = do
     allocaBytes nbytes $ \ptr -> do
        len <- 

{-# LINE 700 "fptools\libraries\network\Network\Socket.hsc" #-}
        	   c_recv s ptr (fromIntegral nbytes) 0{-flags-} 
        let len' = fromIntegral len
	if len' == 0
	 then ioError (mkEOFError "Network.Socket.recv")
	 else do
	   s <- peekCStringLen (ptr,len')
	   return (s, len')

-- ---------------------------------------------------------------------------
-- socketPort
--
-- The port number the given socket is currently connected to can be
-- determined by calling $port$, is generally only useful when bind
-- was given $aNY\_PORT$.

socketPort :: Socket		-- Connected & Bound Socket
	   -> IO PortNumber	-- Port Number of Socket
socketPort sock@(MkSocket _ AF_INET _ _ _) = do
    (SockAddrInet port _) <- getSocketName sock
    return port
socketPort (MkSocket _ family _ _ _) =
    ioError (userError ("socketPort: not supported for Family " ++ show family))


-- ---------------------------------------------------------------------------
-- getPeerName

-- Calling $getPeerName$ returns the address details of the machine,
-- other than the local one, which is connected to the socket. This is
-- used in programs such as FTP to determine where to send the
-- returning data.  The corresponding call to get the details of the
-- local machine is $getSocketName$.

getPeerName   :: Socket -> IO SockAddr
getPeerName (MkSocket s family _ _ _) = do
 withNewSockAddr family $ \ptr sz -> do
   with (fromIntegral sz) $ \int_star -> do
   throwSocketErrorIfMinus1Retry "getPeerName" $ c_getpeername s ptr int_star
   sz <- peek int_star
   peekSockAddr ptr
    
getSocketName :: Socket -> IO SockAddr
getSocketName (MkSocket s family _ _ _) = do
 withNewSockAddr family $ \ptr sz -> do
   with (fromIntegral sz) $ \int_star -> do
   throwSocketErrorIfMinus1Retry "getSocketName" $ c_getsockname s ptr int_star
   peekSockAddr ptr

-----------------------------------------------------------------------------
-- Socket Properties

data SocketOption
    = DummySocketOption__

{-# LINE 754 "fptools\libraries\network\Network\Socket.hsc" #-}
    | Debug         {- SO_DEBUG     -}

{-# LINE 756 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 757 "fptools\libraries\network\Network\Socket.hsc" #-}
    | ReuseAddr     {- SO_REUSEADDR -}

{-# LINE 759 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 760 "fptools\libraries\network\Network\Socket.hsc" #-}
    | Type          {- SO_TYPE      -}

{-# LINE 762 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 763 "fptools\libraries\network\Network\Socket.hsc" #-}
    | SoError       {- SO_ERROR     -}

{-# LINE 765 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 766 "fptools\libraries\network\Network\Socket.hsc" #-}
    | DontRoute     {- SO_DONTROUTE -}

{-# LINE 768 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 769 "fptools\libraries\network\Network\Socket.hsc" #-}
    | Broadcast     {- SO_BROADCAST -}

{-# LINE 771 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 772 "fptools\libraries\network\Network\Socket.hsc" #-}
    | SendBuffer    {- SO_SNDBUF    -}

{-# LINE 774 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 775 "fptools\libraries\network\Network\Socket.hsc" #-}
    | RecvBuffer    {- SO_RCVBUF    -}

{-# LINE 777 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 778 "fptools\libraries\network\Network\Socket.hsc" #-}
    | KeepAlive     {- SO_KEEPALIVE -}

{-# LINE 780 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 781 "fptools\libraries\network\Network\Socket.hsc" #-}
    | OOBInline     {- SO_OOBINLINE -}

{-# LINE 783 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 786 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 789 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 790 "fptools\libraries\network\Network\Socket.hsc" #-}
    | NoDelay       {- TCP_NODELAY  -}

{-# LINE 792 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 793 "fptools\libraries\network\Network\Socket.hsc" #-}
    | Linger        {- SO_LINGER    -}

{-# LINE 795 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 798 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 799 "fptools\libraries\network\Network\Socket.hsc" #-}
    | RecvLowWater  {- SO_RCVLOWAT  -}

{-# LINE 801 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 802 "fptools\libraries\network\Network\Socket.hsc" #-}
    | SendLowWater  {- SO_SNDLOWAT  -}

{-# LINE 804 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 805 "fptools\libraries\network\Network\Socket.hsc" #-}
    | RecvTimeOut   {- SO_RCVTIMEO  -}

{-# LINE 807 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 808 "fptools\libraries\network\Network\Socket.hsc" #-}
    | SendTimeOut   {- SO_SNDTIMEO  -}

{-# LINE 810 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 811 "fptools\libraries\network\Network\Socket.hsc" #-}
    | UseLoopBack   {- SO_USELOOPBACK -}

{-# LINE 813 "fptools\libraries\network\Network\Socket.hsc" #-}

socketOptLevel :: SocketOption -> CInt
socketOptLevel so = 
  case so of

{-# LINE 820 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 823 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 824 "fptools\libraries\network\Network\Socket.hsc" #-}
    NoDelay      -> 6
{-# LINE 825 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 826 "fptools\libraries\network\Network\Socket.hsc" #-}
    _            -> 65535
{-# LINE 827 "fptools\libraries\network\Network\Socket.hsc" #-}

packSocketOption :: SocketOption -> CInt
packSocketOption so =
  case so of

{-# LINE 832 "fptools\libraries\network\Network\Socket.hsc" #-}
    Debug         -> 1
{-# LINE 833 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 834 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 835 "fptools\libraries\network\Network\Socket.hsc" #-}
    ReuseAddr     -> 4
{-# LINE 836 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 837 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 838 "fptools\libraries\network\Network\Socket.hsc" #-}
    Type          -> 4104
{-# LINE 839 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 840 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 841 "fptools\libraries\network\Network\Socket.hsc" #-}
    SoError       -> 4103
{-# LINE 842 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 843 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 844 "fptools\libraries\network\Network\Socket.hsc" #-}
    DontRoute     -> 16
{-# LINE 845 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 846 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 847 "fptools\libraries\network\Network\Socket.hsc" #-}
    Broadcast     -> 32
{-# LINE 848 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 849 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 850 "fptools\libraries\network\Network\Socket.hsc" #-}
    SendBuffer    -> 4097
{-# LINE 851 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 852 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 853 "fptools\libraries\network\Network\Socket.hsc" #-}
    RecvBuffer    -> 4098
{-# LINE 854 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 855 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 856 "fptools\libraries\network\Network\Socket.hsc" #-}
    KeepAlive     -> 8
{-# LINE 857 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 858 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 859 "fptools\libraries\network\Network\Socket.hsc" #-}
    OOBInline     -> 256
{-# LINE 860 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 861 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 864 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 867 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 868 "fptools\libraries\network\Network\Socket.hsc" #-}
    NoDelay       -> 1
{-# LINE 869 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 870 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 871 "fptools\libraries\network\Network\Socket.hsc" #-}
    Linger	  -> 128
{-# LINE 872 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 873 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 876 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 877 "fptools\libraries\network\Network\Socket.hsc" #-}
    RecvLowWater  -> 4100
{-# LINE 878 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 879 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 880 "fptools\libraries\network\Network\Socket.hsc" #-}
    SendLowWater  -> 4099
{-# LINE 881 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 882 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 883 "fptools\libraries\network\Network\Socket.hsc" #-}
    RecvTimeOut   -> 4102
{-# LINE 884 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 885 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 886 "fptools\libraries\network\Network\Socket.hsc" #-}
    SendTimeOut   -> 4101
{-# LINE 887 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 888 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 889 "fptools\libraries\network\Network\Socket.hsc" #-}
    UseLoopBack   -> 64
{-# LINE 890 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 891 "fptools\libraries\network\Network\Socket.hsc" #-}

setSocketOption :: Socket 
		-> SocketOption -- Option Name
		-> Int		-- Option Value
		-> IO ()
setSocketOption (MkSocket s _ _ _ _) so v = do
   with (fromIntegral v) $ \ptr_v -> do
   throwErrnoIfMinus1_ "setSocketOption" $
       c_setsockopt s (socketOptLevel so) (packSocketOption so) ptr_v 
	  (fromIntegral (sizeOf v))
   return ()


getSocketOption :: Socket
		-> SocketOption  -- Option Name
		-> IO Int	 -- Option Value
getSocketOption (MkSocket s _ _ _ _) so = do
   alloca $ \ptr_v ->
     with (fromIntegral (sizeOf (undefined :: CInt))) $ \ptr_sz -> do
       throwErrnoIfMinus1 "getSocketOption" $
	 c_getsockopt s (socketOptLevel so) (packSocketOption so) ptr_v ptr_sz
       fromIntegral `liftM` peek ptr_v



{-# LINE 933 "fptools\libraries\network\Network\Socket.hsc" #-}


{-# LINE 1014 "fptools\libraries\network\Network\Socket.hsc" #-}


{-
A calling sequence table for the main functions is shown in the table below.

\begin{figure}[h]
\begin{center}
\begin{tabular}{|l|c|c|c|c|c|c|c|}d
\hline
{\bf A Call to} & socket & connect & bindSocket & listen & accept & read & write \\
\hline
{\bf Precedes} & & & & & & & \\
\hline 
socket &	&	  &	       &	&	 &	& \\
\hline
connect & +	&	  &	       &	&	 &	& \\
\hline
bindSocket & +	&	  &	       &	&	 &	& \\
\hline
listen &	&	  & +	       &	&	 &	& \\
\hline
accept &	&	  &	       &  +	&	 &	& \\
\hline
read   &	&   +	  &	       &  +	&  +	 &  +	& + \\
\hline
write  &	&   +	  &	       &  +	&  +	 &  +	& + \\
\hline
\end{tabular}
\caption{Sequence Table for Major functions of Socket}
\label{tab:api-seq}
\end{center}
\end{figure}
-}

-- ---------------------------------------------------------------------------
-- OS Dependent Definitions
    
unpackFamily	:: CInt -> Family
packFamily	:: Family -> CInt

packSocketType	:: SocketType -> CInt

-- | Address Families.
--
-- This data type might have different constructors depending on what is
-- supported by the operating system.
data Family
	= AF_UNSPEC	-- unspecified

{-# LINE 1063 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_UNIX	-- local to host (pipes, portals

{-# LINE 1065 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1066 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_INET	-- internetwork: UDP, TCP, etc

{-# LINE 1068 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1069 "fptools\libraries\network\Network\Socket.hsc" #-}
        | AF_INET6	-- Internet Protocol version 6

{-# LINE 1071 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1072 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_IMPLINK	-- arpanet imp addresses

{-# LINE 1074 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1075 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_PUP	-- pup protocols: e.g. BSP

{-# LINE 1077 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1078 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_CHAOS	-- mit CHAOS protocols

{-# LINE 1080 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1081 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_NS		-- XEROX NS protocols 

{-# LINE 1083 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1086 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1087 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_ECMA	-- european computer manufacturers

{-# LINE 1089 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1090 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_DATAKIT	-- datakit protocols

{-# LINE 1092 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1093 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_CCITT	-- CCITT protocols, X.25 etc

{-# LINE 1095 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1096 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_SNA	-- IBM SNA

{-# LINE 1098 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1099 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_DECnet	-- DECnet

{-# LINE 1101 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1102 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_DLI	-- Direct data link interface

{-# LINE 1104 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1105 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_LAT	-- LAT

{-# LINE 1107 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1108 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_HYLINK	-- NSC Hyperchannel

{-# LINE 1110 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1111 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_APPLETALK	-- Apple Talk

{-# LINE 1113 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1116 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1117 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_NETBIOS	-- NetBios-style addresses

{-# LINE 1119 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1122 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1125 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1126 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_ISO	-- ISO protocols

{-# LINE 1128 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1129 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_OSI	-- umbrella of all families used by OSI

{-# LINE 1131 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1134 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1137 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1140 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1143 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1146 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1147 "fptools\libraries\network\Network\Socket.hsc" #-}
	| AF_IPX	-- Novell Internet Protocol

{-# LINE 1149 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1152 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1155 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1158 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1161 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1164 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1167 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1170 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1173 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1176 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1179 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1182 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1185 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1188 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1191 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1194 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1197 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1200 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1203 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1206 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1209 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1212 "fptools\libraries\network\Network\Socket.hsc" #-}
	deriving (Eq, Ord, Read, Show)

------ ------
			
packFamily f = case f of
	AF_UNSPEC -> 0
{-# LINE 1218 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1219 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_UNIX -> 1
{-# LINE 1220 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1221 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1222 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_INET -> 2
{-# LINE 1223 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1224 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1225 "fptools\libraries\network\Network\Socket.hsc" #-}
        AF_INET6 -> 23
{-# LINE 1226 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1227 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1228 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_IMPLINK -> 3
{-# LINE 1229 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1230 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1231 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_PUP -> 4
{-# LINE 1232 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1233 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1234 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_CHAOS -> 5
{-# LINE 1235 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1236 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1237 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_NS -> 6
{-# LINE 1238 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1239 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1242 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1243 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_ECMA -> 8
{-# LINE 1244 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1245 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1246 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_DATAKIT -> 9
{-# LINE 1247 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1248 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1249 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_CCITT -> 10
{-# LINE 1250 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1251 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1252 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_SNA -> 11
{-# LINE 1253 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1254 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1255 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_DECnet -> 12
{-# LINE 1256 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1257 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1258 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_DLI -> 13
{-# LINE 1259 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1260 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1261 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_LAT -> 14
{-# LINE 1262 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1263 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1264 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_HYLINK -> 15
{-# LINE 1265 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1266 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1267 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_APPLETALK -> 16
{-# LINE 1268 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1269 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1272 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1273 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_NETBIOS -> 17
{-# LINE 1274 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1275 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1278 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1281 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1282 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_ISO -> 7
{-# LINE 1283 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1284 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1285 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_OSI -> 7
{-# LINE 1286 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1287 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1290 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1293 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1296 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1299 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1302 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1303 "fptools\libraries\network\Network\Socket.hsc" #-}
	AF_IPX -> 6
{-# LINE 1304 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1305 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1308 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1311 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1314 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1317 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1320 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1323 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1326 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1329 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1332 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1335 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1338 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1341 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1344 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1347 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1350 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1353 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1356 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1359 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1362 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1365 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1368 "fptools\libraries\network\Network\Socket.hsc" #-}

--------- ----------

unpackFamily f = case f of
	(0) -> AF_UNSPEC
{-# LINE 1373 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1374 "fptools\libraries\network\Network\Socket.hsc" #-}
	(1) -> AF_UNIX
{-# LINE 1375 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1376 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1377 "fptools\libraries\network\Network\Socket.hsc" #-}
	(2) -> AF_INET
{-# LINE 1378 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1379 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1380 "fptools\libraries\network\Network\Socket.hsc" #-}
        (23) -> AF_INET6
{-# LINE 1381 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1382 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1383 "fptools\libraries\network\Network\Socket.hsc" #-}
	(3) -> AF_IMPLINK
{-# LINE 1384 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1385 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1386 "fptools\libraries\network\Network\Socket.hsc" #-}
	(4) -> AF_PUP
{-# LINE 1387 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1388 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1389 "fptools\libraries\network\Network\Socket.hsc" #-}
	(5) -> AF_CHAOS
{-# LINE 1390 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1391 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1392 "fptools\libraries\network\Network\Socket.hsc" #-}
	(6) -> AF_NS
{-# LINE 1393 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1394 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1397 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1398 "fptools\libraries\network\Network\Socket.hsc" #-}
	(8) -> AF_ECMA
{-# LINE 1399 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1400 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1401 "fptools\libraries\network\Network\Socket.hsc" #-}
	(9) -> AF_DATAKIT
{-# LINE 1402 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1403 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1404 "fptools\libraries\network\Network\Socket.hsc" #-}
	(10) -> AF_CCITT
{-# LINE 1405 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1406 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1407 "fptools\libraries\network\Network\Socket.hsc" #-}
	(11) -> AF_SNA
{-# LINE 1408 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1409 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1410 "fptools\libraries\network\Network\Socket.hsc" #-}
	(12) -> AF_DECnet
{-# LINE 1411 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1412 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1413 "fptools\libraries\network\Network\Socket.hsc" #-}
	(13) -> AF_DLI
{-# LINE 1414 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1415 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1416 "fptools\libraries\network\Network\Socket.hsc" #-}
	(14) -> AF_LAT
{-# LINE 1417 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1418 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1419 "fptools\libraries\network\Network\Socket.hsc" #-}
	(15) -> AF_HYLINK
{-# LINE 1420 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1421 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1422 "fptools\libraries\network\Network\Socket.hsc" #-}
	(16) -> AF_APPLETALK
{-# LINE 1423 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1424 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1427 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1428 "fptools\libraries\network\Network\Socket.hsc" #-}
	(17) -> AF_NETBIOS
{-# LINE 1429 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1430 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1433 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1436 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1437 "fptools\libraries\network\Network\Socket.hsc" #-}
	(7) -> AF_ISO
{-# LINE 1438 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1439 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1440 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1443 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1444 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1447 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1450 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1453 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1456 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1459 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1460 "fptools\libraries\network\Network\Socket.hsc" #-}
	(6) -> AF_IPX
{-# LINE 1461 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1462 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1465 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1468 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1471 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1474 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1477 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1480 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1483 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1486 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1489 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1492 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1495 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1498 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1501 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1504 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1507 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1510 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1513 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1516 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1519 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1522 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1525 "fptools\libraries\network\Network\Socket.hsc" #-}

-- Socket Types.

-- | Socket Types.
--
-- This data type might have different constructors depending on what is
-- supported by the operating system.
data SocketType
	= NoSocketType

{-# LINE 1535 "fptools\libraries\network\Network\Socket.hsc" #-}
	| Stream 

{-# LINE 1537 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1538 "fptools\libraries\network\Network\Socket.hsc" #-}
	| Datagram

{-# LINE 1540 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1541 "fptools\libraries\network\Network\Socket.hsc" #-}
	| Raw 

{-# LINE 1543 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1544 "fptools\libraries\network\Network\Socket.hsc" #-}
	| RDM 

{-# LINE 1546 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1547 "fptools\libraries\network\Network\Socket.hsc" #-}
	| SeqPacket

{-# LINE 1549 "fptools\libraries\network\Network\Socket.hsc" #-}
	deriving (Eq, Ord, Read, Show)
	
packSocketType stype = case stype of
	NoSocketType -> 0

{-# LINE 1554 "fptools\libraries\network\Network\Socket.hsc" #-}
	Stream -> 1
{-# LINE 1555 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1556 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1557 "fptools\libraries\network\Network\Socket.hsc" #-}
	Datagram -> 2
{-# LINE 1558 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1559 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1560 "fptools\libraries\network\Network\Socket.hsc" #-}
	Raw -> 3
{-# LINE 1561 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1562 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1563 "fptools\libraries\network\Network\Socket.hsc" #-}
	RDM -> 4
{-# LINE 1564 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1565 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1566 "fptools\libraries\network\Network\Socket.hsc" #-}
	SeqPacket -> 5
{-# LINE 1567 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1568 "fptools\libraries\network\Network\Socket.hsc" #-}

-- ---------------------------------------------------------------------------
-- Utility Functions

aNY_PORT :: PortNumber 
aNY_PORT = 0

iNADDR_ANY :: HostAddress
iNADDR_ANY = htonl (0)
{-# LINE 1577 "fptools\libraries\network\Network\Socket.hsc" #-}

sOMAXCONN :: Int
sOMAXCONN = 5
{-# LINE 1580 "fptools\libraries\network\Network\Socket.hsc" #-}

sOL_SOCKET :: Int
sOL_SOCKET = 65535
{-# LINE 1583 "fptools\libraries\network\Network\Socket.hsc" #-}


{-# LINE 1588 "fptools\libraries\network\Network\Socket.hsc" #-}

maxListenQueue :: Int
maxListenQueue = sOMAXCONN

-- -----------------------------------------------------------------------------

data ShutdownCmd 
 = ShutdownReceive
 | ShutdownSend
 | ShutdownBoth

sdownCmdToInt :: ShutdownCmd -> CInt
sdownCmdToInt ShutdownReceive = 0
sdownCmdToInt ShutdownSend    = 1
sdownCmdToInt ShutdownBoth    = 2

shutdown :: Socket -> ShutdownCmd -> IO ()
shutdown (MkSocket s _ _ _ _) stype = do
  throwSocketErrorIfMinus1Retry "shutdown" (c_shutdown s (sdownCmdToInt stype))
  return ()

-- -----------------------------------------------------------------------------

sClose	 :: Socket -> IO ()
sClose (MkSocket s _ _ _ _) = do c_close s; return ()

-- -----------------------------------------------------------------------------

sIsConnected :: Socket -> IO Bool
sIsConnected (MkSocket _ _ _ _ status) = do
    value <- readMVar status
    return (value == Connected)	

-- -----------------------------------------------------------------------------
-- Socket Predicates

sIsBound :: Socket -> IO Bool
sIsBound (MkSocket _ _ _ _ status) = do
    value <- readMVar status
    return (value == Bound)	

sIsListening :: Socket -> IO Bool
sIsListening (MkSocket _ _ _  _ status) = do
    value <- readMVar status
    return (value == Listening)	

sIsReadable  :: Socket -> IO Bool
sIsReadable (MkSocket _ _ _ _ status) = do
    value <- readMVar status
    return (value == Listening || value == Connected)

sIsWritable  :: Socket -> IO Bool
sIsWritable = sIsReadable -- sort of.

sIsAcceptable :: Socket -> IO Bool

{-# LINE 1649 "fptools\libraries\network\Network\Socket.hsc" #-}
sIsAcceptable (MkSocket _ _ _ _ status) = do
    value <- readMVar status
    return (value == Connected || value == Listening)
    
-- -----------------------------------------------------------------------------
-- Internet address manipulation routines:

inet_addr :: String -> IO HostAddress
inet_addr ipstr = do
   withCString ipstr $ \str -> do
   had <- c_inet_addr str
   if had == -1
    then ioError (userError ("inet_addr: Malformed address: " ++ ipstr))
    else return had  -- network byte order

inet_ntoa :: HostAddress -> IO String
inet_ntoa haddr = do
  pstr <- c_inet_ntoa haddr
  peekCString pstr

-- socketHandle turns a Socket into a Haskell IO Handle. By default, the new
-- handle is unbuffered. Use hSetBuffering to alter this.


{-# LINE 1673 "fptools\libraries\network\Network\Socket.hsc" #-}
socketToHandle :: Socket -> IOMode -> IO Handle
socketToHandle s@(MkSocket fd _ _ _ _) mode = do

{-# LINE 1678 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1679 "fptools\libraries\network\Network\Socket.hsc" #-}
    openFd (fromIntegral fd) True{-is a socket-} mode True{-bin-}

{-# LINE 1681 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1685 "fptools\libraries\network\Network\Socket.hsc" #-}

mkInvalidRecvArgError :: String -> IOError
mkInvalidRecvArgError loc = IOError Nothing 

{-# LINE 1691 "fptools\libraries\network\Network\Socket.hsc" #-}
				    IllegalOperation

{-# LINE 1693 "fptools\libraries\network\Network\Socket.hsc" #-}
				    loc "non-positive length" Nothing

mkEOFError :: String -> IOError
mkEOFError loc = IOError Nothing EOF loc "end of file" Nothing

-- ---------------------------------------------------------------------------
-- WinSock support

{-| On Windows operating systems, the networking subsystem has to be
initialised using 'withSocketsDo' before any networking operations can
be used.  eg.

> main = withSocketsDo $ do {...}

Although this is only strictly necessary on Windows platforms, it is
harmless on other platforms, so for portability it is good practice to
use it all the time.
-}
withSocketsDo :: IO a -> IO a

{-# LINE 1715 "fptools\libraries\network\Network\Socket.hsc" #-}
withSocketsDo act = do
   x <- initWinSock
   if ( x /= 0 ) then
     ioError (userError "Failed to initialise WinSock")
    else do
      act `Control.Exception.finally` shutdownWinSock

foreign import ccall unsafe "HsNet.h initWinSock" initWinSock :: IO Int
foreign import ccall unsafe "HsNet.h shutdownWinSock" shutdownWinSock :: IO ()


{-# LINE 1726 "fptools\libraries\network\Network\Socket.hsc" #-}

-- ---------------------------------------------------------------------------
-- foreign imports from the C library

foreign import ccall unsafe "HsNet.h my_inet_ntoa"
  c_inet_ntoa :: HostAddress -> IO (Ptr CChar)

foreign import stdcall unsafe "HsNet.h inet_addr"
  c_inet_addr :: Ptr CChar -> IO HostAddress

foreign import stdcall unsafe "HsNet.h shutdown"
  c_shutdown :: CInt -> CInt -> IO CInt 


{-# LINE 1743 "fptools\libraries\network\Network\Socket.hsc" #-}
foreign import stdcall unsafe "HsNet.h closesocket"
  c_close :: CInt -> IO CInt

{-# LINE 1746 "fptools\libraries\network\Network\Socket.hsc" #-}

foreign import stdcall unsafe "HsNet.h socket"
  c_socket :: CInt -> CInt -> CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h bind"
  c_bind :: CInt -> Ptr SockAddr -> CInt{-CSockLen???-} -> IO CInt
foreign import stdcall unsafe "HsNet.h connect"
  c_connect :: CInt -> Ptr SockAddr -> CInt{-CSockLen???-} -> IO CInt
foreign import stdcall unsafe "HsNet.h accept"
  c_accept :: CInt -> Ptr SockAddr -> Ptr CInt{-CSockLen???-} -> IO CInt
foreign import stdcall unsafe "HsNet.h listen"
  c_listen :: CInt -> CInt -> IO CInt

foreign import stdcall unsafe "HsNet.h send"
  c_send :: CInt -> Ptr CChar -> CSize -> CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h sendto"
  c_sendto :: CInt -> Ptr CChar -> CSize -> CInt -> Ptr SockAddr -> CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h recv"
  c_recv :: CInt -> Ptr CChar -> CSize -> CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h recvfrom"
  c_recvfrom :: CInt -> Ptr CChar -> CSize -> CInt -> Ptr SockAddr -> Ptr CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h getpeername"
  c_getpeername :: CInt -> Ptr SockAddr -> Ptr CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h getsockname"
  c_getsockname :: CInt -> Ptr SockAddr -> Ptr CInt -> IO CInt

foreign import stdcall unsafe "HsNet.h getsockopt"
  c_getsockopt :: CInt -> CInt -> CInt -> Ptr CInt -> Ptr CInt -> IO CInt
foreign import stdcall unsafe "HsNet.h setsockopt"
  c_setsockopt :: CInt -> CInt -> CInt -> Ptr CInt -> CInt -> IO CInt

-----------------------------------------------------------------------------
-- Support for thread-safe blocking operations in GHC.


{-# LINE 1808 "fptools\libraries\network\Network\Socket.hsc" #-}

throwErrnoIfMinus1Retry_mayBlock name _ act
  = throwSocketErrorIfMinus1Retry name act

throwErrnoIfMinus1Retry_repeatOnBlock name _ act
  = throwSocketErrorIfMinus1Retry name act

throwSocketErrorIfMinus1_ :: Num a => String -> IO a -> IO ()
throwSocketErrorIfMinus1_ name act = do
  throwSocketErrorIfMinus1Retry name act
  return ()


{-# LINE 1821 "fptools\libraries\network\Network\Socket.hsc" #-}
throwSocketErrorIfMinus1Retry name act = do
  r <- act
  if (r == -1) 
   then do
    rc   <- c_getLastError
    case rc of
      10093 -> do -- WSANOTINITIALISED
        withSocketsDo (return ())
	r <- act
	if (r == -1)
	 then (c_getLastError >>= throwSocketError name)
	 else return r
      _ -> throwSocketError name rc
   else return r

throwSocketError name rc = do
    pstr <- c_getWSError rc
    str  <- peekCString pstr

{-# LINE 1842 "fptools\libraries\network\Network\Socket.hsc" #-}
    ioError (userError (name ++ ": socket error - " ++ str))

{-# LINE 1844 "fptools\libraries\network\Network\Socket.hsc" #-}
foreign import stdcall unsafe "HsNet.h WSAGetLastError"
  c_getLastError :: IO CInt

foreign import ccall unsafe "HsNet.h getWSErrorDescr"
  c_getWSError :: CInt -> IO (Ptr CChar)



{-# LINE 1854 "fptools\libraries\network\Network\Socket.hsc" #-}

{-# LINE 1855 "fptools\libraries\network\Network\Socket.hsc" #-}

