/* Machine generated file, do not modify */
#include "HsFFI.h"
static HugsAPI5 *hugs = 0;
#include "string.h"

static void hugsprim_strerror_1(HugsStackPtr);
static void hugsprim_strerror_1(HugsStackPtr hugs_root)
{
    HsInt32 arg1;
    HsPtr res1;
    arg1 = hugs->getInt32();
    res1 = strerror(arg1);
    hugs->putPtr(res1);
    hugs->returnIO(hugs_root,1);
}
#include "HsBase.h"

static void hugsprim_ghcErrno_0(HugsStackPtr);
static void hugsprim_ghcErrno_0(HugsStackPtr hugs_root)
{
    HsPtr res1;
    res1 = ghcErrno();
    hugs->putPtr(res1);
}

static struct hugs_primitive hugs_primTable[] = {
    {"strerror", 2, hugsprim_strerror_1},
    {"_errno", 0, hugsprim_ghcErrno_0},
};

static void hugs_primControl(int);
static void hugs_primControl(what)
int what; {
}

#ifdef STATIC_LINKAGE
#define initModule initFCError
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

