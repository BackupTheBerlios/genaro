/* Machine generated file, do not modify */
#include "HsFFI.h"
static HugsAPI5 *hugs = 0;
#include "HsNet.h"

static void hugsprim_getWSErrorDescr_23(HugsStackPtr);
static void hugsprim_getWSErrorDescr_23(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr res1;
    arg1 = hugs->getInt32();
    res1 = getWSErrorDescr(arg1);
    hugs->putPtr(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_WSAGetLastError_22(HugsStackPtr);
static void hugsprim_WSAGetLastError_22(HugsStackPtr hugs_root)
{
    HsInt32 res1;
    res1 = WSAGetLastError();
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_setsockopt_21(HugsStackPtr);
static void hugsprim_setsockopt_21(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 arg2;
    HsInt32 arg3;
    HsPtr arg4;
    HsInt32 arg5;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getInt32();
    arg3 = hugs->getInt32();
    arg4 = hugs->getPtr();
    arg5 = hugs->getInt32();
    res1 = setsockopt(arg1, arg2, arg3, arg4, arg5);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_getsockopt_20(HugsStackPtr);
static void hugsprim_getsockopt_20(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 arg2;
    HsInt32 arg3;
    HsPtr arg4;
    HsPtr arg5;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getInt32();
    arg3 = hugs->getInt32();
    arg4 = hugs->getPtr();
    arg5 = hugs->getPtr();
    res1 = getsockopt(arg1, arg2, arg3, arg4, arg5);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_getsockname_19(HugsStackPtr);
static void hugsprim_getsockname_19(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsPtr arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getPtr();
    res1 = getsockname(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_getpeername_18(HugsStackPtr);
static void hugsprim_getpeername_18(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsPtr arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getPtr();
    res1 = getpeername(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_recvfrom_17(HugsStackPtr);
static void hugsprim_recvfrom_17(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsWord32 arg3;
    HsInt32 arg4;
    HsPtr arg5;
    HsPtr arg6;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getWord32();
    arg4 = hugs->getInt32();
    arg5 = hugs->getPtr();
    arg6 = hugs->getPtr();
    res1 = recvfrom(arg1, arg2, arg3, arg4, arg5, arg6);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_recv_16(HugsStackPtr);
static void hugsprim_recv_16(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsWord32 arg3;
    HsInt32 arg4;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getWord32();
    arg4 = hugs->getInt32();
    res1 = recv(arg1, arg2, arg3, arg4);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_sendto_15(HugsStackPtr);
static void hugsprim_sendto_15(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsWord32 arg3;
    HsInt32 arg4;
    HsPtr arg5;
    HsInt32 arg6;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getWord32();
    arg4 = hugs->getInt32();
    arg5 = hugs->getPtr();
    arg6 = hugs->getInt32();
    res1 = sendto(arg1, arg2, arg3, arg4, arg5, arg6);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_send_14(HugsStackPtr);
static void hugsprim_send_14(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsWord32 arg3;
    HsInt32 arg4;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getWord32();
    arg4 = hugs->getInt32();
    res1 = send(arg1, arg2, arg3, arg4);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_listen_13(HugsStackPtr);
static void hugsprim_listen_13(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 arg2;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getInt32();
    res1 = listen(arg1, arg2);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_accept_12(HugsStackPtr);
static void hugsprim_accept_12(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsPtr arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getPtr();
    res1 = accept(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_connect_11(HugsStackPtr);
static void hugsprim_connect_11(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsInt32 arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getInt32();
    res1 = connect(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_bind_10(HugsStackPtr);
static void hugsprim_bind_10(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr arg2;
    HsInt32 arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getPtr();
    arg3 = hugs->getInt32();
    res1 = bind(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_socket_9(HugsStackPtr);
static void hugsprim_socket_9(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 arg2;
    HsInt32 arg3;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getInt32();
    arg3 = hugs->getInt32();
    res1 = socket(arg1, arg2, arg3);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_closesocket_8(HugsStackPtr);
static void hugsprim_closesocket_8(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    res1 = closesocket(arg1);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_shutdown_7(HugsStackPtr);
static void hugsprim_shutdown_7(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsInt32 arg2;
    HsInt32 res1;
    arg1 = hugs->getInt32();
    arg2 = hugs->getInt32();
    res1 = shutdown(arg1, arg2);
    hugs->putInt32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_inet_addr_6(HugsStackPtr);
static void hugsprim_inet_addr_6(HugsStackPtr hugs_root)
{
    HsPtr arg1;
    HsWord32 res1;
    arg1 = hugs->getPtr();
    res1 = inet_addr(arg1);
    hugs->putWord32(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_my_inet_ntoa_5(HugsStackPtr);
static void hugsprim_my_inet_ntoa_5(HugsStackPtr hugs_root)
{
    HsWord32 arg1;
    HsPtr res1;
    arg1 = hugs->getWord32();
    res1 = my_inet_ntoa(arg1);
    hugs->putPtr(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_shutdownWinSock_4(HugsStackPtr);
static void hugsprim_shutdownWinSock_4(HugsStackPtr hugs_root)
{
    shutdownWinSock();
    
    hugs->returnIO(hugs_root,0);
}

static void hugsprim_initWinSock_3(HugsStackPtr);
static void hugsprim_initWinSock_3(HugsStackPtr hugs_root)
{
    HsInt res1;
    res1 = initWinSock();
    hugs->putInt(res1);
    hugs->returnIO(hugs_root,1);
}

static void hugsprim_htonl_2(HugsStackPtr);
static void hugsprim_htonl_2(HugsStackPtr hugs_root)
{
    HsWord32 arg1;
    HsWord32 res1;
    arg1 = hugs->getWord32();
    res1 = htonl(arg1);
    hugs->putWord32(res1);
    hugs->returnId(hugs_root,1);
}

static void hugsprim_htons_1(HugsStackPtr);
static void hugsprim_htons_1(HugsStackPtr hugs_root)
{
    HsWord16 arg1;
    HsWord16 res1;
    arg1 = hugs->getWord16();
    res1 = htons(arg1);
    hugs->putWord16(res1);
    hugs->returnId(hugs_root,1);
}

static void hugsprim_ntohs_0(HugsStackPtr);
static void hugsprim_ntohs_0(HugsStackPtr hugs_root)
{
    HsWord16 arg1;
    HsWord16 res1;
    arg1 = hugs->getWord16();
    res1 = ntohs(arg1);
    hugs->putWord16(res1);
    hugs->returnId(hugs_root,1);
}

static struct hugs_primitive hugs_primTable[] = {
    {"c_getWSError", 2, hugsprim_getWSErrorDescr_23},
    {"c_getLastError", 1, hugsprim_WSAGetLastError_22},
    {"c_setsockopt", 6, hugsprim_setsockopt_21},
    {"c_getsockopt", 6, hugsprim_getsockopt_20},
    {"c_getsockname", 4, hugsprim_getsockname_19},
    {"c_getpeername", 4, hugsprim_getpeername_18},
    {"c_recvfrom", 7, hugsprim_recvfrom_17},
    {"c_recv", 5, hugsprim_recv_16},
    {"c_sendto", 7, hugsprim_sendto_15},
    {"c_send", 5, hugsprim_send_14},
    {"c_listen", 3, hugsprim_listen_13},
    {"c_accept", 4, hugsprim_accept_12},
    {"c_connect", 4, hugsprim_connect_11},
    {"c_bind", 4, hugsprim_bind_10},
    {"c_socket", 4, hugsprim_socket_9},
    {"c_close", 2, hugsprim_closesocket_8},
    {"c_shutdown", 3, hugsprim_shutdown_7},
    {"c_inet_addr", 2, hugsprim_inet_addr_6},
    {"c_inet_ntoa", 2, hugsprim_my_inet_ntoa_5},
    {"shutdownWinSock", 1, hugsprim_shutdownWinSock_4},
    {"initWinSock", 1, hugsprim_initWinSock_3},
    {"htonl", 1, hugsprim_htonl_2},
    {"htons", 1, hugsprim_htons_1},
    {"ntohs", 1, hugsprim_ntohs_0},
};

static void hugs_primControl(int);
static void hugs_primControl(what)
int what; {
}

#ifdef STATIC_LINKAGE
#define initModule initNSocket
#endif

static struct hugs_primInfo hugs_prims = { hugs_primControl, hugs_primTable, 0 };

#ifdef __cplusplus
extern "C" {
#endif
#ifndef __cplusplus
DLLEXPORT(int)  HugsAPIVersion(void);
#endif
DLLEXPORT(int)  HugsAPIVersion() {return (5);}
DLLEXPORT(void) initModule(HugsAPI5 *);
DLLEXPORT(void) initModule(HugsAPI5 *hugsAPI) {
    hugs = hugsAPI;
    hugs->registerPrims(&hugs_prims);
}
#ifdef __cplusplus
}
#endif

