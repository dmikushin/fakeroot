# Before glibc 2.33 the stat family of functions (and mknod)
# used to be inline wrappers around calls to xstat, fxstat,
# lxstat, xmknod, which all take a leading version number
# argument designating the data structure and bits used.
# Thus libfakeroot needs to wrap xstat, fxstat, xmknod only.
# 
# In glibc 2.33 inline wrapper functions have been removed.
# Instead libc.so.6 exports stat, stat64, etc symbols.
# xstat, fxstat, xmknod still exist (for compatibility reasons).
# Thus libfakeroot must wrap both stat (fstat, statat, fstatat, etc)
# and internal xstat (fxstat, etc) functions.
#
# However some new architectures (such as LoongArch lp64d ABI)
# decided to be 64-bit only since the day 0 and don't use any wrappers.
# Here libfakeroot should wrap only stat (statat, fstat, fstatat).
# A special care should be taken to avoid the double definition.

include(CheckFunctionExists)

# Default values that may be overriden below
set(WRAP_STAT                   __astat)
set(WRAP_STAT_QUOTE             __astat)
set(WRAP_STAT_RAW               __astat)
set(TMP_STAT                    __astat)
set(NEXT_STAT_NOARG             next___astat)

set(WRAP_LSTAT_QUOTE            __astat)
set(WRAP_LSTAT                  __astat)
set(WRAP_LSTAT_RAW              __astat)
set(TMP_LSTAT                   __astat)
set(NEXT_LSTAT_NOARG            next___astat)

set(WRAP_FSTAT_QUOTE            __astat)
set(WRAP_FSTAT                  __astat)
set(WRAP_FSTAT_RAW              __astat)
set(TMP_FSTAT                   __astat)
set(NEXT_FSTAT_NOARG            next___astat)

set(WRAP_FSTATAT_QUOTE          __astatat)
set(WRAP_FSTATAT                __astatat)
set(WRAP_FSTATAT_RAW            __astatat)
set(TMP_FSTATAT                 __astatat)
set(NEXT_FSTATAT_NOARG          next___astatat)

set(WRAP_STAT64_QUOTE           __astat64)
set(WRAP_STAT64                 __astat64)
set(WRAP_STAT64_RAW             __astat64)
set(TMP_STAT64                  __astat64)
set(NEXT_STAT64_NOARG           next___astat64)

set(WRAP_LSTAT64_QUOTE          __astat64)
set(WRAP_LSTAT64                __astat64)
set(WRAP_LSTAT64_RAW            __astat64)
set(TMP_LSTAT64                 __astat64)
set(NEXT_LSTAT64_NOARG          next___astat64)

set(WRAP_FSTAT64_QUOTE          __astat64)
set(WRAP_FSTAT64                __astat64)
set(WRAP_FSTAT64_RAW            __astat64)
set(TMP_FSTAT64                 __astat64)
set(NEXT_FSTAT64_NOARG          next___astat64)

set(WRAP_FSTATAT64_QUOTE        __astatat64)
set(WRAP_FSTATAT64              __astatat64)
set(WRAP_FSTATAT64_RAW          __astatat64)
set(TMP_FSTATAT64               __astatat64)
set(NEXT_FSTATAT64_NOARG        next___astatat64)

set(WRAP_MKNOD_QUOTE            __amknod)
set(WRAP_MKNOD                  __amknod)
set(WRAP_MKNOD_RAW              __amknod)
set(TMP_MKNOD                   __amknod)
set(NEXT_MKNOD_NOARG            next___amknod)

set(WRAP_MKNODAT_QUOTE          __amknodat)
set(WRAP_MKNODAT                __amknodat)
set(WRAP_MKNODAT_RAW            __amknodat)
set(TMP_MKNODAT                 __amknodat)
set(NEXT_MKNODAT_NOARG          next___amknodat)

set(WRAP_STAT64_TIME64_QUOTE    __astat64_time64)
set(WRAP_STAT64_TIME64          __astat64_time64)
set(WRAP_STAT64_TIME64_RAW      __astat64_time64)
set(TMP_STAT64_TIME64           __astat64_time64)
set(NEXT_STAT64_TIME64_NOARG    next___astat64_time64)

set(WRAP_LSTAT64_TIME64_QUOTE   __astat64_time64)
set(WRAP_LSTAT64_TIME64         __astat64_time64)
set(WRAP_LSTAT64_TIME64_RAW     __astat64_time64)
set(TMP_LSTAT64_TIME64          __astat64_time64)
set(NEXT_LSTAT64_TIME64_NOARG   next___astat64_time64)

set(WRAP_FSTAT64_TIME64_QUOTE   __astat64_time64)
set(WRAP_FSTAT64_TIME64         __astat64_time64)
set(WRAP_FSTAT64_TIME64_RAW     __astat64_time64)
set(TMP_FSTAT64_TIME64          __astat64_time64)
set(NEXT_FSTAT64_TIME64_NOARG   next___astat64_time64)

set(WRAP_FSTATAT64_TIME64_QUOTE __astatat64_time64)
set(WRAP_FSTATAT64_TIME64       __astat64_time64)
set(WRAP_FSTATAT64_TIME64_RAW   __astat64_time64)
set(TMP_FSTATAT64_TIME64        __astat64_time64)
set(NEXT_FSTATAT64_TIME64_NOARG next___astat64_time64)

# Initialize variables
set(time64_hack "yes")  # Set this based on your requirements

# Function search and wrapping logic
foreach(SEARCH IN ITEMS "%stat" "f%stat" "l%stat" "f%statat" "%stat64" "f%stat64" "l%stat64" "f%statat64" "%mknod" "%mknodat")
  string(REGEX REPLACE ".*%" "" FUNC ${SEARCH})
  string(REGEX REPLACE "%.*" "" PRE ${SEARCH})

  foreach(WRAPPED IN ITEMS "__${PRE}x${FUNC}" "_${PRE}x${FUNC}" "__${PRE}${FUNC}13" "${PRE}${FUNC}" "__${PRE}${FUNC}")
    check_function_exists(${WRAPPED} FOUND)
    if(FOUND)
      string(TOUPPER "${PRE}${FUNC}" PF)
      string(TOUPPER "wrap_${PRE}${FUNC}" DEFINE_WRAP)
      string(TOUPPER "wrap_${WRAPPED}" DEFINE_NEXT)
      string(TOUPPER "wrap_${WRAPPED}" DEFINE_ARG)

      # TODO: These settings should be visible to config.h.in
      set(WRAP_${PF} ${WRAPPED})
      set(WRAP_${PF}_RAW ${WRAPPED})
      set(WRAP_${PF}_QUOTE \"${WRAPPED}\")
      set(TMP_${PF} "tmp_${WRAPPED}")
      set(NEXT_${PF}_NOARG "next_${WRAPPED}")

      if(NOT "${WRAPPED}" STREQUAL "__${PRE}x${FUNC}" AND NOT "${WRAPPED}" STREQUAL "_${PRE}x${FUNC}")
        set(DEF_BEGIN "")
      else()
        set(DEF_BEGIN "a,")
      endif()

      if("${FUNC}" STREQUAL "mknod")
        set(DEF_END ",d")
      elseif("${FUNC}" STREQUAL "mknodat")
        set(DEF_END ",d,e")
      elseif("${FUNC}" STREQUAL "statat")
        set(DEF_END ",d,e")
      elseif("${FUNC}" STREQUAL "statat64")
        set(DEF_END ",d,e")
      else()
        set(DEF_END "")
      endif()

      file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/fakerootconfig.h"
        "#define NEXT_${PF}(a,b,c${DEF_END}) next_${WRAPPED}(${DEF_BEGIN}b,c${DEF_END})\n"
        "#define ${PF}_ARG(a,b,c${DEF_END}) (${DEF_BEGIN}b,c${DEF_END})\n"
      )

      if("${FOUND}" STREQUAL "${PRE}${FUNC}")
        #message(STATUS "Extra wrapper for ${PRE}${FUNC} is not necessary")
        set(NO_WRAP_${PF}_SYMBOL 1)
      else()
        #message(STATUS "Extra wrapper for ${PRE}${FUNC} is required")
      endif()
      break()
    endif()
  endforeach()
endforeach()

# Time64 hack logic
if(time64_hack STREQUAL "yes")
  foreach(SEARCH IN ITEMS "stat64_time64" "fstat64_time64" "lstat64_time64" "fstatat64_time64")
    foreach(WRAPPED IN ITEMS "__${SEARCH}" "${SEARCH}")
      check_function_exists(${WRAPPED} FOUND)
      if(FOUND)
        string(TOUPPER "${SEARCH}" PF)
        string(TOUPPER "wrap_${SEARCH}" DEFINE_WRAP)
        string(TOUPPER "wrap_${WRAPPED}" DEFINE_NEXT)
        string(TOUPPER "wrap_${WRAPPED}" DEFINE_ARG)

        set(WRAP_${PF} ${WRAPPED})
        set(WRAP_${PF}_RAW ${WRAPPED})
        set(WRAP_${PF}_QUOTE "${WRAPPED}")
        set(TMP_${PF} "tmp_${WRAPPED}")
        set(NEXT_${PF}_NOARG "next_${WRAPPED}")

        set(DEF_BEGIN "")
        if("${SEARCH}" MATCHES "statat64_time64")
          set(DEF_END ",d,e")
        else()
          set(DEF_END "")
        endif()

        file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/fakerootconfig.h"
          "#define NEXT_${PF}(a,b,c${DEF_END}) next_${WRAPPED}(${DEF_BEGIN}b,c${DEF_END})\n"
          "#define ${PF}_ARG(a,b,c${DEF_END}) (${DEF_BEGIN}b,c${DEF_END})\n"
        )
        break()
      endif()
    endforeach()
  endforeach()
endif()

