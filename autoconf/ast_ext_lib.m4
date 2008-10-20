# AST_EXT_LIB_SETUP([package symbol name], [package friendly name], [package option name], [additional help text])

AC_DEFUN([AST_EXT_LIB_SETUP],
[
$1_DESCRIP="$2"
$1_OPTION="$3"
AC_ARG_WITH([$3], AC_HELP_STRING([--with-$3=PATH],[use $2 files in PATH $4]),[
case ${withval} in
     n|no)
     USE_$1=no
     ;;
     y|ye|yes)
     $1_MANDATORY="yes"
     ;;
     *)
     $1_DIR="${withval}"
     $1_MANDATORY="yes"
     ;;
esac
])
PBX_$1=0
AC_SUBST([$1_LIB])
AC_SUBST([$1_INCLUDE])
AC_SUBST([$1_DIR])
AC_SUBST([PBX_$1])
])

# AST_EXT_LIB_CHECK([package symbol name], [package library name], [function to check], [package header], [additional LIB data], [additional INCLUDE data])

AC_DEFUN([AST_EXT_LIB_CHECK],
[
if test "${USE_$1}" != "no"; then
   pbxlibdir=""
   if test "x${$1_DIR}" != "x"; then
      if test -d ${$1_DIR}/lib; then
      	 pbxlibdir="-L${$1_DIR}/lib"
      else
      	 pbxlibdir="-L${$1_DIR}"
      fi
   fi
   AC_CHECK_LIB([$2], [$3], [AST_$1_FOUND=yes], [AST_$1_FOUND=no], ${pbxlibdir} $5)

   if test "${AST_$1_FOUND}" = "yes"; then
      $1_LIB="-l$2 $5"
      $1_HEADER_FOUND="1"
      if test "x${$1_DIR}" != "x"; then
         $1_LIB="${pbxlibdir} ${$1_LIB}"
	 $1_INCLUDE="-I${$1_DIR}/include"
      fi
      $1_INCLUDE="${$1_INCLUDE} $6"
      saved_cppflags="${CPPFLAGS}"
      CPPFLAGS="${CPPFLAGS} ${$1_INCLUDE}"
      if test "x$4" != "x" ; then
         AC_CHECK_HEADER([$4], [$1_HEADER_FOUND=1], [$1_HEADER_FOUND=0])
      fi
      CPPFLAGS="${saved_cppflags}"
      if test "x${$1_HEADER_FOUND}" = "x0" ; then
         if test -n "${$1_MANDATORY}" ;
         then
            AC_MSG_NOTICE([***])
            AC_MSG_NOTICE([*** It appears that you do not have the $2 development package installed.])
            AC_MSG_NOTICE([*** Please install it to include ${$1_DESCRIP} support, or re-run configure])
            AC_MSG_NOTICE([*** without explicitly specifying --with-${$1_OPTION}])
            exit 1
         fi
         $1_LIB=""
         $1_INCLUDE=""
         PBX_$1=0
      else
         PBX_$1=1
         AC_DEFINE_UNQUOTED([HAVE_$1], 1, [Define to indicate the ${$1_DESCRIP} library])
      fi
   elif test -n "${$1_MANDATORY}";
   then
      AC_MSG_NOTICE([***])
      AC_MSG_NOTICE([*** The ${$1_DESCRIP} installation on this system appears to be broken.])
      AC_MSG_NOTICE([*** Either correct the installation, or run configure])
      AC_MSG_NOTICE([*** without explicitly specifying --with-${$1_OPTION}])
      exit 1
   fi
fi
])
