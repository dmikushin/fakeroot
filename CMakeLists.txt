cmake_minimum_required(VERSION 3.18)

set(VERSION 1.32.2)

project(fakeroot VERSION ${VERSION} LANGUAGES C)

# Define options
option(WITH_TCP "Method of IPC to use: either sysv (default) or tcp" OFF)
option(WITH_DB_PATH "Database format to use: either inode (default) or path" OFF)

add_definitions(-DHAVE_CONFIG_H)
if (WITH_TCP)
add_definitions(-DFAKEROOT_FAKENET)
endif()
if (WITH_DB_PATH)
add_definitions(-DFAKEROOT_DB_PATH)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckLibraryExists)
include(CheckTypeSize)
include(GetTargetTriple)

include(GenerateGlibcWrappers)

# Compiler flags handling
set(CMAKE_C_STANDARD 99)

# Check for headers
check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(endian.h HAVE_ENDIAN_H)
check_include_file(fcntl.h HAVE_FCNTL_H)
check_include_file(features.h HAVE_FEATURES_H)
check_include_file(fts.h HAVE_FTS_H)
check_include_file(grp.h HAVE_GRP_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(ndir.h HAVE_NDIR_H)
check_include_file(pthread.h HAVE_PTHREAD_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdio.h HAVE_STDIO_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/acl.h HAVE_SYS_ACL_H)
check_include_file(sys/capability.h HAVE_SYS_CAPABILITY_H)
check_include_file(sys/dir.h HAVE_SYS_DIR_H)
check_include_file(sys/feature_tests.h HAVE_SYS_FEATURE_TESTS_H)
check_include_file(sys/ndir.h HAVE_SYS_NDIR_H)
check_include_file(sys/socket.h HAVE_SYS_SOCKET_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(sys/xattr.h HAVE_SYS_XATTR_H)
check_include_file(unistd.h HAVE_UNISTD_H)

# Check for functions
check_function_exists(acl_get_fd HAVE_ACL_GET_FD)
check_function_exists(acl_trivial HAVE_ACL_TRIVIAL)
check_function_exists(fchmodat HAVE_FCHMODAT)
check_function_exists(fchownat HAVE_FCHOWNAT)
check_function_exists(fgetattrlist HAVE_FGETATTRLIST)
check_function_exists(fgetxattr HAVE_FGETXATTR)
check_function_exists(flistxattr HAVE_FLISTXATTR)
check_function_exists(fremovexattr HAVE_FREMOVEXATTR)
check_function_exists(fsetxattr HAVE_FSETXATTR)
check_function_exists(fstatat HAVE_FSTATAT)
check_function_exists(fts_children HAVE_FTS_CHILDREN)
check_function_exists(fts_read HAVE_FTS_READ)
check_function_exists(getresgid HAVE_GETRESGID)
check_function_exists(getresuid HAVE_GETRESUID)
check_function_exists(getxattr HAVE_GETXATTR)
check_function_exists(lchmod HAVE_LCHMOD)
check_function_exists(lgetxattr HAVE_LGETXATTR)
check_function_exists(listxattr HAVE_LISTXATTR)
check_function_exists(llistxattr HAVE_LLISTXATTR)
check_function_exists(lremovexattr HAVE_LREMOVEXATTR)
check_function_exists(lsetxattr HAVE_LSETXATTR)
check_function_exists(mkdirat HAVE_MKDIRAT)
check_function_exists(mknodat HAVE_MKNODAT)
check_function_exists(openat HAVE_OPENAT)
check_function_exists(removexattr HAVE_REMOVEXATTR)
check_function_exists(renameat HAVE_RENAMEAT)
check_function_exists(setenv HAVE_SETENV)
check_function_exists(setfsgid HAVE_SETFSGID)
check_function_exists(setfsuid HAVE_SETFSUID)
check_function_exists(setresgid HAVE_SETRESGID)
check_function_exists(setresuid HAVE_SETRESUID)
check_function_exists(setxattr HAVE_SETXATTR)
check_function_exists(statx HAVE_STATX)
check_function_exists(strdup HAVE_STRDUP)
check_function_exists(strstr HAVE_STRSTR)
check_function_exists(unlinkat HAVE_UNLINKAT)

# Check for libraries
check_library_exists(dl dlopen "" HAVE_LIBDL)
check_library_exists(pthread pthread_create "" HAVE_LIBPTHREAD)
check_library_exists(socket socket "" HAVE_LIBSOCKET)

# Check for type of argument of setreuid
check_type_size("uid_t" UID_T_SIZE LANGUAGE C)
if(UID_T_SIZE)
  set(SETREUID_ARG "uid_t")
else()
  set(SETREUID_ARG "int")
endif()
message(STATUS "Type of argument of setreuid: ${SETREUID_ARG}")

# Check for type of argument of setregid
check_type_size("gid_t" GID_T_SIZE LANGUAGE C)
if(GID_T_SIZE)
  set(SETREGID_ARG "gid_t")
  set(INITGROUPS_SECOND_ARG "gid_t")
else()
  set(SETREGID_ARG "int")
  set(INITGROUPS_SECOND_ARG "int")
endif()
message(STATUS "Type of argument of setregid: ${SETREGID_ARG}")
message(STATUS "Type of second argument of initgroups: ${INITGROUPS_SECOND_ARG}")

# Check for type of first argument of setgroups
set(SETGROUPS_SIZE_TYPE "unknown")
foreach(first "size_t" "int")
  set(CMAKE_REQUIRED_DEFINITIONS "-D_BSD_SOURCE")
  check_include_files("sys/types.h;unistd.h;stdio.h;grp.h" HAVE_ALL_HEADERS)
  
  if(HAVE_ALL_HEADERS)
    set(CMAKE_REQUIRED_INCLUDES "/usr/include")
    set(CMAKE_REQUIRED_LIBRARIES "c")
    
    set(SOURCE_CODE "
      #include <sys/types.h>
      #include <unistd.h>
      #include <stdio.h>
      #include <grp.h>
      int setgroups(${first} size, const gid_t *list);
      int main() { puts(\"hello, world\"); return 0; }
    ")
    
    check_c_source_compiles("${SOURCE_CODE}" COMPILES)
    
    if(COMPILES)
      set(SETGROUPS_SIZE_TYPE "${first}")
      break()
    endif()
  endif()
endforeach()
message(STATUS "Type of first argument of setgroups: ${SETGROUPS_SIZE_TYPE}")

check_function_exists(__xmknod HAVE___XMKOD)

if(HAVE___XMKOD)
    message(STATUS "Checking for type of forth arg of __xmknod")
    set(CMAKE_REQUIRED_INCLUDES "/usr/include")
    set(CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE")
    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>

        int main() {
            #ifndef __GLIBC__
            #error no extra *
            #endif
            int __xmknod(int ver, const char *pathname, mode_t mode, dev_t *dev);
            return 0;
        }
    " XMKNOD_NEEDS_POINTER)

    if(XMKNOD_NEEDS_POINTER)
        message(STATUS "XMKNOD_FRTH_ARG needs *")
        set(XMKNOD_FRTH_ARG *)
    else()
        message(STATUS "XMKNOD_FRTH_ARG no extra *")
    endif()
else()
    message(STATUS "XMKNOD_FRTH_ARG no extra *")
endif()

check_function_exists(__xmknodat HAVE_XMKNODAT)
if(HAVE_XMKNODAT)
    message(STATUS "Checking for type of second arg of __xmknodat")
    set(CMAKE_REQUIRED_INCLUDES "/usr/include")
    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>
        
        int main() {
            #ifndef __GLIBC__
            #error no extra *
            #endif
            int __xmknodat(int ver, int dirfd, const char *pathname, mode_t mode, dev_t *dev);
            return 0;
        }
    " XMKNODAT_FIFTH_ARG_POINTER)

    if(XMKNODAT_FIFTH_ARG_POINTER)
        message(STATUS "XMKNODAT_FIFTH_ARG needs *")
        set(XMKNODAT_FIFTH_ARG *)
    else()
        message(STATUS "XMKNODAT_FIFTH_ARG no extra *")
    endif()
else()
    message(STATUS "XMKNODAT_FIFTH_ARG no extra *")
endif()

check_c_source_compiles("
  #include <sys/stat.h>
  #include <sys/types.h>
  #include <unistd.h>

  int main() {
    struct stat buf;
    return stat(\"/\", &buf);
  }
" HAVE_STRUCT_STAT_PTR)

if(HAVE_STRUCT_STAT_PTR)
  set(STAT_SECOND_ARG "struct stat *")
  message(STATUS "Second argument of stat is struct stat *")
else()
  check_c_source_compiles("
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <unistd.h>

    int main() {
      stat buf;
      return stat(\"/\", &buf);
    }
  " HAVE_STAT_PTR)

  if(HAVE_STAT_PTR)
    set(STAT_SECOND_ARG "stat *")
    message(STATUS "Second argument of stat is stat *")
  else()
    message(FATAL_ERROR "Cannot determine second stat argument")
  endif()
endif()

# Configure config.h
configure_file(
    config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    @ONLY
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(communicate STATIC communicate.c)

add_executable(faked faked.c)
target_link_options(faked PRIVATE -static)
target_link_libraries(faked PRIVATE communicate ${CMAKE_DL_LIBS})

add_executable(simple simple.c)
target_link_libraries(simple PRIVATE ${CMAKE_DL_LIBS})

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/wrapped.h
           ${CMAKE_CURRENT_BINARY_DIR}/wrapdef.h
           ${CMAKE_CURRENT_BINARY_DIR}/wrapstruct.h
           ${CMAKE_CURRENT_BINARY_DIR}/wraptmpf.h
    COMMAND awk -f ${CMAKE_CURRENT_SOURCE_DIR}/wrapawk < ${CMAKE_CURRENT_SOURCE_DIR}/wrapfunc.inp
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/wrapawk ${CMAKE_CURRENT_SOURCE_DIR}/wrapfunc.inp
    COMMENT "Generating header files using AWK"
)

add_custom_target(generate_wraps ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/wrapped.h
            ${CMAKE_CURRENT_BINARY_DIR}/wrapdef.h
            ${CMAKE_CURRENT_BINARY_DIR}/wrapstruct.h
            ${CMAKE_CURRENT_BINARY_DIR}/wraptmpf.h
)

add_library(fakeroot_time64 STATIC libfakeroot_time64.c) 
target_compile_definitions(fakeroot_time64 PRIVATE _FILE_OFFSET_BITS=64 _TIME_BITS=64)
add_dependencies(fakeroot_time64 generate_wraps)

add_library(fakeroot SHARED libfakeroot.c)
target_link_libraries(fakeroot PRIVATE fakeroot_time64 ${CMAKE_DL_LIBS})
add_dependencies(fakeroot generate_wraps)

if (CMAKE_C_COMPILER_TARGET_DARWIN)
    add_library(fakeroot_macosx STATIC libfakeroot_inode64.c libfakeroot_unix2003.c)
    add_dependencies(fakeroot_macosx generate_wraps)
    target_link_libraries(fakeroot PRIVATE fakeroot_macosx)
    target_link_options(fakeroot PRIVATE "-undefined dynamic_lookup")
endif()

include(GNUInstallDirs)
install(TARGETS faked fakeroot
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
