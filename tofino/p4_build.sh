#!/bin/bash
#
# p4_build.sh
#
# This script utilizes p4-build system to build user's P4 program within
# the framework of the chosen SDE
#
# Directory Organization:
#
# $P4_PATH ---> points to the "main" p4 file that constitutes user program
#
# Recommended organization of user directories:
#
# $YOUR_DIR \
#    p4src     -- P4 code
#    ptf-tests -- PTF tests
#
# $SDE \
#    build/p4-build/${P4_NAME}${P4_SUFFIX} -- p4-build directory for the program
#    logs/p4-build/${P4_NAME}${P4_SUFFIX}  -- log files for the build    
#    install             -- programs are installed according to p4-build
#                           If you build the program multiple times, then
#                           the last build overwrites the previous ones, even
#                           when you use suffix. I might revisit that later
#
# The build should be done using the tools in $SDE and $SDE_INSTALL
# Similarly, when test is going to be run, the model, the drivers, PTF, etc. 
# should be coming from $SDE and $SDE_INSTALL
#
############################################################################
#
# Supporting multiple compilers, language versions, architectures and targets
# (LACT)
#
# The script can be used to compile the same program for a given
# language-architecture-compiler combination, potentially for multiple targets
# (provided that there are multiple targets supporting the given LAC
# combination).
#
# While it is certainly possible to envision programs that can be compiled for
# multiple architectures (e.g. they will have a lot of #ifdefs), I do not
# believe this is practical. I am not going to write those and I'd strongly
# advise others from doing so too -- it is too much hassle and the programs
# will be sub-optimal anyway. Current P4_16 architectures are so different, that
# a reasonable reconciliation is probably impractical to begin with.
#
# The canonical way to compile is:
#  p4_build.sh                                                    \
#        [--with-p4c[=<p4-compiler>]]                             \
#        [--with-target1 ... -with-targetN]                       \
#        [ other flags ]                                          \
#        p4_program [extra-variables-for-p4-build/configure]      \
#        [ -- other-flags-to-p4-build/configure ]
#
# By default, the script should be able to figure out
#   1. The language version used (p4_16 or p4_16)
#   2. The architecture used:
#          p4_14: tofino
#          p4_16: v1model, tna, t2na, psa, etc.
#   3. The compiler to use:
#          p4_14: p4c-tofino(default) or p4c (bf-p4c)
#          p4_16: p4c (bf-p4c)
#
# Target "tofino" is assumed by default. More targets (e.g. tofino2) will
# appear later.
#
# Not all combinations are supported...
#############################################################################

# Since this script is supposed to be executed and not sourced, we put a check
# here to prevent stupid errors
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "This script is supposed to be executed and not sourced"
else
#
# Error handling:
#        Just stop if there is any problem
#
set -e

# Uncomment the line below for debug purposes
#set -x

#
# The following parameters are controlled through the command line
#
jobs=0                          # Number of jobs to run in parallel (0 is auto)

with_p4c=                       # Compiler to use: use default
with_p4c_14="bf-p4c"            #       Default for p4_14 programs
with_p4c_16="bf-p4c"            #       Default for p4_16 programs

                                # P4 Target
with_tofino="--with-tofino"     # Compile for Tofino/Tofino-model

default_with_thrift="--enable-thrift"   # Build Thrift Client/Server Code
                                        # (p4_14 only)
                                    
with_graphs="no"               # Build graphs using p4-graphs (p4_14 only)
p4graphs="p4-graphs"

# Default compiler flags for p4c-tofino. 
# Other useful but more dangerous/time-consuming flags:
# --print-pa-constraints --parser-timing-report.
# --create-graphs requires the presence of 'dot' in the path
default_p4flags_tofino="-g --verbose 2"    

# Default compiler flags for p4c.
# We'll keep separate versions for P4_14 and P4_16

# The last parameter is a workaround that should be gone by SDE-9.1.0
default_p4flags_p4_14="-g --verbose 2"
default_p4flags_p4_16="-g --verbose 2"

# Default P4_14 translation arch
default_arch_p4_14="v1model" # Soon to be replaced with TNA

# Normally the default flags above should be added to the user-specified
# P4FLAGS, but in some cases user-provided flags can override ours
p4flags_override=0

#
# Various parameters/constants
#
packages=packages         # The SDE subdirectory SDE where package tarballs are
pkgsrc=pkgsrc             # The SDE subdirectory, where tarbals are untarred
build=build               # The SDE subdirectory, where the builds are done
logs=logs                 # The SDE subdirectory, where build logs are stored
install=install

sde_min_gb=4              # We recommend at least 4GB RAM for the build
log_lines=20              # How many lines from the log to show on error

print_help() {
    cat <<EOF | less

Usage: p4_build.sh [options] <p4-program> [p4-build-vars] [-- <p4-build-flags>]"

Supported options:
  General:
  ========
    -h, --help    -- Print this help
    -v, --version -- Print this script version
    -j jobs       -- Specify maximum jobs for parallelization. Default is 0,
                     meaning that the script will determine the optimal value
                     automatically
    -Iincdir
    -Dcppvar[=value]
    -Ucppvar
                  -- Standard CPP flags that will be added to P4PPFLAGS

    -p, --p4flags-override
                     If specified, the value of P4FLAGS will be passed to the
                     compiler "as-is" thus overriding the default flags instead
                     of simply being added to them.

    --with-p4c[=<path-to-P4-compiler>]
                     Specify the compiler:
                        Default for P4_14 is p4c-tofino
                        Default for P4_16 is p4c
                     --with-p4c is the same as --with-p4c=p4c

    --with-graphs[=<path-to-p4-graphs]
                     Automatically invoke p4-graphs to build the parser, flow
                     and dependency graphs (this is the default for P4_14)
                     --with-p4-graphs is the same as --with-p4-graphs=p4-graphs
                     Also use --create-graphs if the compiler supports that.

    --without-graphs 
                     Do not automatically invoke p4-graphs and do not create
                     compiler graphs (p4c-graphs) either

    --with-suffix=suffix 
                     Append the suffix to the build and logs directory name.
                     Usually starts with ".", e.g. ".p4c"
                     Indeed, if you use --with-p4c flag, the suffix is by
                     default set to basename of the compiler

    --with-thrift    
                     Automatically generate Thrift bindings and Thrift server
                     for PD APIs (this is the default for P4_14)
    --without-thrift 
                     Do not automatically generate Thrift bindings and server
                     (this is the default for P4_16)

    --with-p4graphs=<path-to-P4-graph-generator>
                     You can override the path to P4 graphs generator.
                     
 P4 Language Version / P4 Architecture support
 =============================================
    The tool automatically detects the language version and the architecture
    of the program you are trying to compile. If it can't do it, most probably
    something is not right. In that case they can be explictily specifies via
    P4_VERSION and P4_ARCHITECTURE variables, e.g.

         p4_build.sh weird.p4 P4_VERSION=p4_16 P4_ARCHITECTURE=tna
            
 Targets:
 ========
    For each supported target T, you can specify the following flags:
      --with-T    -- do compile for the target T 
      --without-T -- do not compile for the target T (--no-T is an alias)
    Supported targets are:
      tofino   -- Tofino(tm) ASIC and its register-accurate model (default)

  Most important P4-Build Variables:
  ==================================
  P4_NAME         Name of the P4 program. By default that's the basename of the 
                  file you pass to the script
  P4_PREFIX       Prefix for the PD APIs. By default, that's the basename of the
                  file you pass to the script
  P4_VERSION      P4 language version (p4_14 or p4_16). Usually NOT NEEDED, 
                  since the script is capable of determining the language 
                  version automatically
  P4_ARCHITECTURE P4 Architecture (tna, v1model, psa). Ignored for P4_14.
                  Usually NOT NEEDED, since the script is capable of determining
                  the language version automatically
  P4PPFLAGS       Preprocessor flags for P4 program
  P4FLAGS         Compiler flags for p4c-tofino compiler. Only specify the flags
                  that you need and the tool will add some additional flags.
                  If you want to verride the flags, use -p parameter.
  P4JOBS          The number of p4c-tofino threads (see -j)
  PDFLAGS         Compiler flags for tofino pd generation
  P4_BUILD_ASSUME_PDFIXED
                  Bypass check for pdfixed headers
  CC              C compiler command
  CFLAGS          C compiler flags
  CPP             C preprocessor
  CPPFLAGS        C preprocessor flags
  CXX             C++ compiler command
  CXXFLAGS        C++ compiler flags
  PYTHON          the Python interpreter
  

  Most important P4-build flags:
  ==============================
  By "flags" we mean parameters that start with "-" or "--". Unlike P4-build
  variables they need to be separated from the rest of the parameters via "--".

  Run "$SDE/pkgsrc/p4-build/configure --help" for the full list 

  Default compiler flags:
  =======================
  p4c-tofino: $default_p4flags_tofino
  p4c(p4_14): $default_p4flags_p4_14
  p4c(p4_16): $default_p4flags_p4_16

EOF
}

#
# Print version
#
print_version() {
    echo "Designed for SDE-9.0.0 (without p4c-tofno)"
}

#############################################################################
########## Detecting the environment (copied from sde_build.sh) #############
#############################################################################
#
# Autodetecting the number of the CPUs
#
get_ncpus() {
    nproc

    # If that utility is not present (it should be), you can use the following
    # code instead
    #    ncpu=`grep ^processor /proc/cpuinfo | tail -1 | sed -e 's/^.*: //'`
    #    echo $[ncpu+1]
}

#
# Function get_onl_manifest_item
#
get_onl_manifest_item() {
    grep \"$1\" /etc/onl/rootfs/manifest.json | cut -d: -f2 | sed -e 's/ *\(".*"\).*/\1/'
    return 0
}

# 
#
# Function get_os_info
#
# The function sets the following variables, according to the OS:
# UNAME_A, DISTRIB_ID, DISTRIB_RELEASE, DISTRIB_CODENAME, DISTRIB_DESCRIPTION
# Normally, it gets them from /etc/lsb-release and tries to guess in other cases
#
get_os_info() {
    UNAME_A=`uname -a`
    if [ -r /etc/lsb-release ]; then
        . /etc/lsb-release
    elif [ -r /etc/onl/rootfs/manifest.json ]; then
        # This is an ONL system, so we can use manifest.json
        DISTRIB_ID="ONL"
        DISTRIB_RELEASE=`get_onl_manifest_item PRODUCT_ID_VERSION`
        DISTRIB_CODENAME=`get_onl_manifest_item PRODUCT_VERSION`
        DISTRIB_DESCRIPTION=`get_onl_manifest_item VERSION_STRING`
    else         
        # Here are some heuristics for non-LSB systems.
        DISTRIB_ID="Unknown"
        DISTRIB_RELEASE="Unknown"
        DISTRIB_CODENAME="Unknown"
        DISTRIB_DESCRIPTION="Unknown, non-LSB System"
    fi
}

#
# Function: check_environment
#
# Ensure that $SDE and $SDE_INSTALL are properly set and generally
# things make sense. Use reasonable defaults
#
check_environment() {
    if [ -z $SDE ]; then
        echo "ERROR: SDE Environment variable is not set"
        exit 1
    else 
        echo "Using SDE          ${SDE}"
    fi

    #
    # Basic Checks that SDE is valid
    #
    if [ ! -d $SDE ]; then
        echo "  ERROR: \$SDE ($SDE) is not a directory"
        exit 1
    fi

    cd $SDE
    if [ $? != 0 ]; then
        echo "  ERROR: Cannot change directory to \$SDE"
        exit 1
    fi

    if [ -z $SDE_INSTALL ]; then
        echo "WARNING: SDE_INSTALL Environment variable is not set"
        echo "         Assuming $SDE/install"
        export SDE_INSTALL=$SDE/install
    else
        echo "Using SDE_INSTALL ${SDE_INSTALL}"
    fi
    
    if [[ ! ":$PATH:" == *":$SDE_INSTALL/bin:"* ]]; then
        echo "INFO: Adding $SDE_INSTALL/bin to \$PATH"
        PATH=$SDE_INSTALL/bin:$PATH
    fi

    #
    # Check SDE version
    #
    if SDE_MANIFEST=`ls $SDE/bf-sde-*.manifest 2> /dev/null`; then 
        echo Using SDE version `basename $SDE_MANIFEST .manifest`
        echo
    else
        echo "  ERROR: SDE manifest file not found in \$SDE"
        exit 1
    fi

    SDE_PACKAGE_LIST=`tr -d ' ' < $SDE_MANIFEST`
    
    #
    # Check available RAM
    #
    total_mem=`grep MemTotal /proc/meminfo | sed -e 's/.* \([0-9]*\) .*/\1/'`
    total_mem_gb=$[total_mem/1000000]
    if [ $total_mem_gb -lt $sde_min_gb ]; then
        echo "ERROR: You system has only ${total_mem_gb}GB of RAM"
        echo "       To build SDE you will need at least ${sde_min_gb}GB"
        exit 1
    fi

    #
    # Basic System Info
    #
    get_os_info
    echo "OS Name: $DISTRIB_DESCRIPTION"
    
    ncpus=`get_ncpus`
    echo "This system has ${total_mem_gb}GB of RAM and ${ncpus} CPU(s)"

    #
    # For parallel builds we need to make sure each process gets at least
    # $sde_min_gb GB of memory
    recommended_jobs=$ncpus
    if [ $[total_mem_gb*2/sde_min_gb] -le $ncpus ]; then
        recommended_jobs=$[total_mem_gb*2/sde_min_gb]
    fi

    # The number of jobs can be specified explicitly. In this case do not
    # override it
    if [ $jobs -eq 0 ]; then 
        jobs=$recommended_jobs
    fi

    echo "Parallelization:  Recommended: -j$recommended_jobs   Actual: -j$jobs"
    
    SDE_PACKAGES=$SDE/$packages
    SDE_PKGSRC=$SDE/$pkgsrc
    SDE_BUILD=$SDE/$build
    SDE_LOGS=$SDE/$logs

    return 0
}
##########################################################################
############# Log collection and display (from sde-build.sh) #############
##########################################################################

#
# Function: start_log
#
# Put a standard header in every logfile
#
start_log() {
    local logfile=$1; shift

    cat <<EOF > $logfile
=========================================================================
         File: `basename $logfile`
      Created: `date`
 Command Line: $CMDLINE
          SDE: $SDE (`basename $SDE_MANIFEST .manifest`)
 Build System: `uname -a`
 Distribution: $DISTRIB_DESCRIPTION
   Build Arch: `uname -m`
       CPU(s): $ncpus
          RAM: ${total_mem_gb}GB
       Job(s): -j$jobs
  p4_build.sh: `print_version`

  Disk Space: for \$SDE
`df -H $SDE`
=========================================================================
 Current Dir: `pwd`
   Executing: $*
=========================================================================
EOF
}

#
# Function: show_log
#
# Prominently display the last $log_lines from the relevant logfile on error
#
show_log() {
    echo "=========================" `basename $1` "========================="
    tail -$log_lines $1
    echo "=========================" `basename $1` "========================="
    echo
    echo "ERROR: For the details and to obtain technical support see the file"
    echo "       $1"
    echo
}

############################################################################
############################## Intelligence :) #############################

#
# Check program
#
# This function tries to figure out the version of the language and the
# architecture that the program uses. Given the fact that P4 uses
# C preprocessor, it might be a little tough, but we'll try :)
#
# The function looks at the following:
#      1) The #includes used by the program
#         (by running the file through CPP with -M):
#            tofino/intrinsic_metadata.p4 -- p4_14/tofino
#            tna.p4                       -- p4_16/tna
#            tofino1arch.p4               -- p4_16/tna
#            t2na.p4                      -- p4_16/t2na
#            tofino2arch.p4               -- p4_16/t2na
#            v1model.p4                   -- p4_16/v1model
#            psa.p4                       -- p4_16/psa
#            core.p4                      -- p4_14/UNKNOWN
#            None of the above            -- p4_14/simple_switch
#      2) First line of the file (Emacs convention)
#          -*- P4_14 -*-
#          -*- P4_16 -*-
#          -*- mode: P4_14; p4-arch: tofino -*-
#          -*- mode: P4_16; p4-arch: tna -*-
#      3) $P4_VERSION $P4_ARCHITECTURE (if specified)
#
# If multiple indicators are present, then they are checked for consistency
#
# Input:
#   P4_REALPATH         -- path to the program's main file
#
# Output:
#   P4_VERSION      -- P4 version in p4_build-compatible format (p4_14/p4_16)
#   P4_ARCHITECTURE -- P4 architecture to compile for (it is currently ignored
#                      by p4-build for p4_14)

#
# Function:
#     p4_includes path_to_program include_file var_for_result
#
# The function sets the specified variable to "yes" or "no", depending on
# whether the program includes a given file or not.
#
# Because we do not know the language/compiler, we will attempt to run CPP with
# three different system include directories that represent p4c-tofino,
# p4c/p4_14 (in fact, they are pretty much identical and can be skipped) and
# p4c/p4_16. If all fails, the function will return 1. Most probably that means
# that the program requires additional include directories that have not been
# specified. In this case, it will also fallback on a simple grep.
p4_includes() {
    local prog=$1;     shift
    local file=$1;     shift
    local var_name=$1; shift
    include_dirs="$SDE_INSTALL/share/p4_lib              \
                  $SDE_INSTALL/share/p4c/p4_14include    \
                  $SDE_INSTALL/share/p4c/p4include"
    good_cpp_runs=0
    for tofino in `seq 1 2`; do
        for inc in $include_dirs; do
            if deps=`cpp -undef -nostdinc -x assembler-with-cpp  \
                         -D__TARGET_TOFINO__=$tofino -I$inc -M   \
                         $P4PPFLAGS $prog 2>/dev/null`; then
                good_cpp_runs=$[$good_cpp_runs+1]
                if [[ $deps =~ $file ]]; then
                    eval $var_name="yes"
                    return 0
                fi
            fi
        done
    done
    if [ $good_cpp_runs -eq 0 ]; then
        #
        # It might be that all calls to CPP failed, because the program requires
        # mode include directories
        if grep -q "^# *include *[<\"].*$file.*[\">]" $prog; then
            eval $var_name="yes"
            return 1
        fi
        eval $var_name="no"
        return 1
    fi
    eval $var_name="no"
    return 0
}

    
check_program() {
    if p4_includes $P4_REALPATH tofino/intrinsic_metadata.p4 inc_tofino; then
        p4_includes $P4_REALPATH tna.p4             inc_tna
        p4_includes $P4_REALPATH tofino1arch.p4     inc_tofino1arch
        p4_includes $P4_REALPATH t2na.p4            inc_t2na
        p4_includes $P4_REALPATH tofino2arch.p4     inc_tofino2arch
        p4_includes $P4_REALPATH v1model.p4         inc_v1model
        p4_includes $P4_REALPATH psa.p4             inc_psa
        p4_includes $P4_REALPATH core.p4            inc_core
    else
        cat <<EOF
ERROR: All the attempts to run CPP on $P4_REALPATH failed.

       The typical reason for this is that the program requires include
       files from directories other than standard ones or addtional preprocessor
       defines. 

       If so, you need to specify these on the command line or as a part of 
       P4PPFLAGS variable, e.g.
               -I<my_inc_dir> -DMY_VAR=1
           or
               P4PPFLAGS="-I<my_inc_dir> -DMY_VAR=1"

       Note: Tilde (~) expansion doesn't work inside quotes and after other 
             characters. If your include directory is located in your home
             directory, use \$HOME instead.

       Note: Due to VPATH build scheme utilized by this script, it is highly
             recommended to provide ABSOLUTE paths to the include directories

       Another reason for this problem might be a real CPP error, such as an 
       incorrect CPP construct used in the file, missing #endif, etc.

       In this case, the easiest way is to run the compiler directly first. 
       However, you will need to specify language and architecture explicitly.
EOF
        exit 1
    fi
    
    first_line=`head -1 $P4_REALPATH`
    if [[ "$first_line" =~ -\*-\ (.*)\ -\*- ]]; then
        # echo Emacs First Line Found
        efl="${BASH_REMATCH[1]}"
        if [[ $efl =~ mode:\ *(P4_1[46])\;\ p4-arch:\ ([^;]*)\; ]]; then
            emacs_mode=${BASH_REMATCH[1]}
            emacs_p4_arch=${BASH_REMATCH[2]}
        elif [[ $efl =~ mode:\ *(P4_1[46]) ]]; then
            emacs_mode=${BASH_REMATCH[1]}
            emacs_p4_arch=
        elif [[ $efl =~ (P4_1[46]) ]]; then
            emacs_mode=${BASH_REMATCH[1]}
            emacs_p4_arch=
        else
            emacs_mode=not_p4
            emacs_p4_arch=
        fi
    else
        emacs_mode=
        emacs_p4_arch=
    fi

    #echo inc_tofino            $inc_tofino
    #echo inc_tna               $inc_tna
    #echo inc_tofino1arch       $inc_tofino1arch
    #echo inc_t2na              $inc_t2na
    #echo inc_tofino2arch       $inc_tofino2arch
    #echo inc_v1model           $inc_v1model
    #echo inc_psa               $inc_psa
    #echo inc_core              $inc_core
    #echo emacs_mode            $emacs_mode
    #echo emacs_p4_arch         $emacs_p4_arch

    #
    # The following algorithm can be made more and more intelligent if one
    # has time. For now, we will make the most obvious decisions and only
    # basic consistency checks
    #
    if [ $inc_tofino == "yes" ]; then
        AUTO_P4_VERSION=p4_14
        AUTO_P4_ARCHITECTURE=$default_arch_p4_14
        p4_autodetected=1
    elif [ $inc_tna == "yes" -a $inc_t2na == "yes" ]; then
        if [ $with_tofino == "--with-tofino" ]; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=tna
            p4_autodetected=1
        elif [ $with_tofino == "--with-tofino2" ]; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=t2na
            p4_autodetected=1
        else
            cat <<EOF
ERROR: This program has been written using the same main (top-level) file
       for both TNA and T2NA architectures. This is a really bad style.

       p4_build.sh script does not support these programs on purpose. You have
       to specify --with-tofino or --with-tofino2 to proceed.

       Please, rewrite your program, so that it uses two separate main files,
       one for TNA and another one for T2NA. You will find it useful to put
       the common code that can be shard into separate files. 

       If you want to follow the current practice, then you should use the
       p4-build subsystem directly, without the help of this handy script.
EOF
            exit 1
        fi
    elif [ $inc_tna == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        if [ $inc_tofino1arch == "yes" -a $inc_tofino2arch == "yes" ]; then
            if [ $with_tofino == "--with-tofino" ]; then
                AUTO_P4_ARCHITECTURE=tna
                p4_autodetected=1
            elif [ $with_tofino == "--with-tofino2" ]; then
                AUTO_P4_ARCHITECTURE=t2na
                p4_autodetected=1
            else
                # Default will be Tofino
                AUTO_P4_ARCHITECTURE=tna
                p4_autodetected=1                
            fi
        fi
    elif [ $inc_t2na == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        AUTO_P4_ARCHITECTURE=t2na
        p4_autodetected=1
    elif [ $inc_tofino1arch == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        AUTO_P4_ARCHITECTURE=tna
        p4_autodetected=1
    elif [ $inc_tofino2arch == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        AUTO_P4_ARCHITECTURE=t2na
        p4_autodetected=1
    elif [ $inc_psa == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        AUTO_P4_ARCHITECTURE=psa
        p4_autodetected=1
    elif [ $inc_v1model == "yes" ]; then
        AUTO_P4_VERSION=p4_16
        AUTO_P4_ARCHITECTURE=v1model
        p4_autodetected=1
    elif [ $inc_core == "no" ]; then
        # It might be a P4 program written for simple_switch or it might be an
        # already preprocessed source
        if grep -q 'tofino/intrinsic_metadata\.p4' $P4_REALPATH; then
            AUTO_P4_VERSION=p4_14
            AUTO_P4_ARCHITECTURE=$default_arch_p4_14
            p4_autodetected=1
        elif grep -q 'p4include/tna\.p4' $P4_REALPATH; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=tna
            p4_autodetected=1
        elif grep -q 'p4include/t2na\.p4' $P4_REALPATH; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=tna
            p4_autodetected=1
        elif grep -q 'p4include/v1model\.p4' $P4_REALPATH; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=v1model
            p4_autodetected=1
        elif grep -q 'p4include/psa\.p4' $P4_REALPATH; then
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=psa
            p4_autodetected=1
        else
            # There might be a couple reasons for us not being able to find
            # standard include files in the code. In the past that would be a
            # simple p4_14 program written for the simple_swirtch architecture.
            # Nowadays, a more common case is a P4_16/v1model program that was
            # obtained as a result of the automatic p4_14-to-p4_16 conversion
            #
            # We can further improve the detection by adding the heuristics.
            # For example if the code contains header_type keyword, it's p4_14
            AUTO_P4_VERSION=p4_16
            AUTO_P4_ARCHITECTURE=v1model
            p4_autodetected=1
        fi
    else
        cat <<EOF
WARNING: Cannot automatically detect P4_VERSION/P4_ARCHITECTURE
         for $P4_REALPATH

         tofino/intrinsic_metadata.p4 included: $inc_tofino
                              core.p4 included: $inc_core
                               tna.p4 included: $inc_tna
                              t2na.p4 included: $inc_t2na
                               psa.p4 included: $inc_psa
                           v1model.p4 included: $inc_v1model
                                    Emacs Mode: $emacs_mode
                                 Emacs P4 Arch: $emacs_p4_arch 

         Usually this means that the file you specified is not a top-level one
         or that the program has been written to support multiple architectures
EOF
        if [ ! -z $P4_VERSION ]; then
            echo "   INFO: Using P4_VERSION=$P4_VERSION from the command line"
        else
            P4_VERSION=$default_p4_version
            echo "   INFO: Using default P4_VERSION=$P4_VERSION"
        fi

        if [ ! -z $P4_ARCHITECTURE ]; then
            echo "   INFO: Using P4_ARCHITECTURE=$P4_ARCHITECTURE from the command line"
        else
            if [ $P4_VERSION == p4_14 ]; then
                P4_VERSION=$default_arch_14
            else
                P4_VERSION=$default_arch_16
            fi
            echo "   INFO: Using default P4_ARCHITECTURE=$P4_ARCHITECTURE for $P$_VERSION"
        fi
        p4_autodetected=0
    fi

    #
    # If command-line parameters contradict what we detected, it's better
    # to issue a warning
    #
    if [ $p4_autodetected -eq 1 ]; then
        if [ ! -z $P4_VERSION ]; then
            if [ $AUTO_P4_VERSION != $P4_VERSION ]; then
               cat <<EOF
WARNING: You requested the program to be compiled as $P4_VERSION, but
         the autodetection code believes it has been written in $AUTO_P4_VERSION.
         The script will attempt compilation as requested on the command line.
EOF
            fi
        else
            P4_VERSION=$AUTO_P4_VERSION
        fi
    fi
    
    if [ $p4_autodetected -eq 1 ]; then
        if [ ! -z $P4_ARCHITECTURE ]; then
            if [ $AUTO_P4_ARCHITECTURE != $P4_ARCHITECTURE ]; then
               cat <<EOF
WARNING: You requested the program to be compiled for $P4_ARCHITECTURE
         P4 Architecture, but the autodetection code believes it has been 
         written in $P4_VERSION for $AUTO_P4_ARCHITECTURE architecture.
         The script will attempt compilation as requested on the command line.
EOF
            fi
        else
            P4_ARCHITECTURE=$AUTO_P4_ARCHITECTURE
        fi
    fi
    
    #
    # Basic File Consistency Checks
    #
    if [ $P4_VERSION == p4_14 ]; then
        case $P4_ARCHITECTURE in
            tofino|simple_switch|"");;
            *) cat <<EOF
ERROR: Architecture $P4_ARCHITECTURE is not supported for P4_14 programs
EOF
               exit 1
               ;;
        esac
        if [ $inc_core == "yes" ]; then
            cat <<EOF
WARNING: The program appears to be written in P4_14, but includes
         core.p4, which is a P4_16 file
EOF
        fi
        if [ ! -z $emacs_mode ]; then
            if [ $emacs_mode != P4_14 ]; then
                cat <<EOF
WARNING: The program appears to be written in P4_14, but the first
         Emacs mode setting line is:

         $first_line
EOF
           fi
        fi
    elif [ $P4_VERSION == p4_16 ]; then
        case $P4_ARCHITECTURE in
            tna|t2na|psa|v1model);;
            *) cat <<EOF
ERROR: Architecture $P4_ARCHITECTURE is not supported for P4_16 programs
EOF
               exit 1
               ;;
        esac
        if [ ! -z $emacs_mode ]; then
            if [ $emacs_mode != P4_16 ]; then
                cat <<EOF
WARNING: The program appears to be written in P4_16, but the first
         Emacs mode setting line is:

         $first_line
EOF
           fi
        fi
    else
        cat <<EOF
ERROR: Unknown Language Version <$P4_VERSION>"
EOF
        exit 1
    fi

    echo
    echo "Compiling for $P4_VERSION/$P4_ARCHITECTURE"
}

#
# Function: check_compiler
#
# This function determines the actual path to the compiler as well as
# its type: older-style p4c-tofino or newer-style p4c
#
# Variables set:
#  p4c             -- Absolute path to the compiler
#  p4c_major       -- Compiler Major version (<=5 is p4-hlir-based, >=6 -- p4c)
#  default_p4flags -- Additional flags this script would like to use by default
#
check_compiler() {
    if [[ -z $with_p4c ]]; then
        case $P4_VERSION in
            p4_14) with_p4c=$with_p4c_14;;
            p4_16) with_p4c=$with_p4c_16;;
        esac
    fi
                   
    if p4c=`which $with_p4c`; then
        p4c_version=`$p4c --version 2>&1 | sed -e 's/.*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*.*(.*)\)/\1/'`
        echo "P4 compiler path:    $p4c"
        echo -n "P4 compiler version: $p4c_version "
        p4c_major=`echo $p4c_version | cut -d. -f1`
    else
        echo "ERROR: The specified compiler <$with_p4c> is not executable"
        return 1
    fi

    if [ $p4c_major -le 5 ]; then
        echo "(p4-hlir-based)"
        default_p4flags="$default_p4flags_tofino"
        if [ $with_graphs == "yes" ]; then
            default_p4flags="$default_p4flags --create-dot"
        fi
    else
        echo "(p4c-based)"
        if [ $P4_VERSION == p4_14 ]; then 
            default_p4flags="$default_p4flags_p4_14"
            # As long as p4c is not the default for p4_14, let's use a suffix
            # if [ -z $P4_SUFFIX ]; then
            #    P4_SUFFIX=".p4c"
            # fi
        else
            default_p4flags="$default_p4flags_p4_16"
        fi
        if [ $with_graphs == "yes" ]; then
            default_p4flags="$default_p4flags --create-graphs"
        fi
    fi

    return 0
}

package_dir() {
    package_name=$1
    shift

    package_list=(`cd $SDE_PKGSRC; ls -d ${package_name}* 2>/dev/null`)
    num_packages=${#package_list[@]}
    case $num_packages in
        0)
            echo ""
            ;;
        1)
            echo ${package_list[0]}
            ;;
        *)
            prompt="\nWARNING: Multiple versions of $package_name package found in \$SDE/$pkgsrc"
            for p in `seq 0 $[$num_packages-1]`; do
                prompt="${prompt}\n    ${p} -- ${package_list[$p]}"
            done
            prompt="$prompt\nPlease choose one(0..$[$num_packages-1])[0]"
            prompt=`echo -e $prompt`
            read -p "$prompt " p
            if [ -z $p ]; then
                p=0
            fi
            echo ${package_list[$p]}
            ;;
    esac
    return 0
}

build_p4_prog() {
    local cmd

    #
    # The customer can pass standard p4-build options. Let's check them
    # and provide reasonable defaults
    #
    if [ -z $P4_NAME ]; then
        P4_NAME=`basename $P4_PATH .p4`
    fi

    if [ -z $P4_PREFIX ]; then 
        P4_PREFIX=$P4_NAME
    fi
    
    if [ -z $P4JOBS ]; then
        P4JOBS=`get_ncpus`
    fi

    # We need to fix P4_ARCHITECTURE, because p4-build expects it to be
    # set to "v1model" for P4_14 programs
    if [ $P4_VERSION == "p4_14" ]; then
        P4_ARCH="v1model"
        if [ -z $with_thrift ]; then
            with_thrift=$default_with_thrift
        fi
    else
        P4_ARCH=$P4_ARCHITECTURE
        if [ $P4_ARCH == "t2na" ]; then
            with_tofino="--with-tofino2"
        fi
        if [ ! -z $with_thrift ]; then
            cat <<EOF
ERROR: Thrift and PD APIs are not supported by P4_16 programs
EOF
            exit 1
        fi
    fi
    
    # Amend customer-provided P4FLAGS with our defaults
    if [ $p4flags_override -ne 1 ]; then
        P4FLAGS="$P4FLAGS $default_p4flags"
    fi

    # Now, let's form the list of the variables for the config.
    # We will go over the list of customer variables and pass all of them,
    # except those we pass explicitly
    p4_build_args=""
    for user_var in $p4_build_vars; do
        case $user_var in
            P4_PATH|P4_NAME|P4_PREFIX|P4_VERSION|P4_ARCHITECTURE|P4JOBS|P4FLAGS)
            ;;
            *) eval \
               p4_build_args="\"$user_var=\\\"\${$user_var}\\\" $p4_build_args\""
               ;;
        esac
    done
    #echo "p4_build_args=$p4_build_args"
    
    P4_BUILD=$SDE_BUILD/p4-build/${P4_NAME}${P4_SUFFIX}
    P4_LOGS=$SDE_LOGS/p4-build/${P4_NAME}${P4_SUFFIX}
    P4_INSTALL=$SDE_INSTALL

    p4_build=`package_dir p4-build`
    if [ -z $p4_build ]; then 
        echo "ERROR: p4-build package not found in $SDE"
        return 1
    fi

    p4_examples=`package_dir p4-examples`
    if [ -z $p4_examples ]; then 
        echo "ERROR: p4-examples package not found in $SDE"
        return 1
    fi

    echo "Build Dir: $P4_BUILD"
    echo " Logs Dir: $P4_LOGS"
    echo 
    echo -n "  Building $P4_NAME        ... "
    rm -rf $P4_BUILD
    rm -rf $P4_LOGS
    echo -en "\b\b\b\bCLEAR ... "
    
    mkdir -p $P4_BUILD
    mkdir -p $P4_LOGS
    cd $P4_BUILD
    
    echo -en "\b\b\b\bCONFIGURE ... " 
    cmd="$SDE_PKGSRC/${p4_build}/configure        \
           --prefix=\"$P4_INSTALL\"               \
           --with-p4c=\"$p4c\"                    \
           P4_PATH=\"$P4_REALPATH\"               \
           P4_NAME=\"$P4_NAME\"                   \
           P4_PREFIX=\"$P4_PREFIX\"               \
           P4_VERSION=\"${P4_VERSION/_/-}\"       \
           P4_ARCHITECTURE=\"$P4_ARCH\"           \
           P4JOBS=$P4JOBS                         \
           P4FLAGS=\"$P4FLAGS\"                   \
           $with_tofino $with_thrift"

    start_log $P4_LOGS/configure.log $cmd "$p4_build_args" "$@"
    if eval $cmd "$p4_build_args" "$@" &>> $P4_LOGS/configure.log; then 
        echo -ne "\b\b\b\b"
    else
        echo FAILED
        show_log $P4_LOGS/configure.log
        cd $WORKDIR
        return 1
    fi

    echo -n "MAKE ... "
    cmd="make -j${jobs}"
    start_log $P4_LOGS/make.log $cmd
    if $cmd &>> $P4_LOGS/make.log; then
        echo -ne "\b\b\b\b"
    else
        echo FAILED
        show_log $P4_LOGS/make.log
        cd $WORKDIR
        return 1
    fi

    echo -n "INSTALL ... "
    cmd="make install"
    start_log $P4_LOGS/install.log $cmd
    if $cmd &>> $P4_LOGS/install.log; then
        echo DONE
    else
        echo FAILED
        show_log $P4_LOGS/install.log
        cd $WORKDIR
        return 1
    fi

    #
    # Installing the conf file
    #
    if [ $P4_VERSION == "p4_14" ]; then
        echo -n "Installing ${P4_NAME}.conf   ... "
        mkdir -p ${P4_INSTALL}/share/p4/targets/tofino

        CONF_IN=$SDE_PKGSRC/${p4_examples}/tofino/tofino_single_device.conf.in
    
        if [ ! -f $CONF_IN ]; then
            echo FAILED
            cat <<EOF

ERROR: Cannot find the template config file `basename $CONF_IN` 
       Check your distribution.

EOF
            cd $WORKDIR
            return 1
        fi

        CONF_OUT_DIR=${P4_INSTALL}/share/p4/targets/tofino
        sed -e "s/TOFINO_SINGLE_DEVICE/${P4_NAME}/"  \
            $CONF_IN                                 \
            > ${CONF_OUT_DIR}/${P4_NAME}.conf 

        echo DONE
    fi

    cd $WORKDIR
    return 0
}

build_graphs() {
    # P4_NAME=`basename $P4_PATH .p4`        # Already set in build_p4_prog
    # P4_BUILD=$SDE_BUILD/p4-build/$P4_NAME  # Already set in build_p4_prog
    GRAPHS_DIR=$P4_BUILD/tofino/$P4_NAME/graphs

    #
    # P4-graphs work with P4_14 only. So, if this is a P4_16 program
    # or if the user doesn't want them, simply return
    #
    if [ $with_graphs == "no" -o  $P4_VERSION == "p4_16" ]; then
        return 0
    fi
    
    # Basic checks. First the utility should be executable
    if [ -z `which $p4graphs` ]; then
        cat <<EOF
ERROR: p4-graphs utility ($p4graphs) does not exist or is not executable.
       P4_14 graphs will not be built

EOF
        exit 1
    fi

    # Second, it requires "dot" utility in the PATH
    if [ -z `which dot` ]; then
        cat <<EOF
ERROR: p4-graphs requires the "dot" utility to creategraphs. 
       However, this utility is not present in your PATH. 
       Please, make sure that graphviz package is installed on your system.

EOF
        exit 1
    fi

    # Third, it requires "primitives.json" in the P4_14 include path
    P4_14INCLUDE=$SDE_INSTALL/share/p4c/p4_14include/
    if [ ! -f $P4_14INCLUDE/tofino/primitives.json ]; then
        P4_14INCLUDE=$SDE_INSTALL/share/p4_lib
        if [ ! -f $P4_14INCLUDE/tofino/primitives.json ]; then
            cat <<EOF
ERROR: p4-graphs requires primitives.json file to be present in the p4_14
       include directory (\$SDE_INSTALL/share/p4c/p4_14include/tofino/ or
       \$SDE_INSTALL/share/p4_lib/tofino/).
       However, we cannot find it and thus can't build the graphs.

       You can ignore this error or use --no-graphs to avoid it
EOF
            exit 1
        fi
    fi
    
    mkdir -p $GRAPHS_DIR
    echo -n "  Building $P4_NAME graphs ... "

    if [ $P4_ARCHITECTURE == "tofino" ]; then
        extra_args="-D__TARGET_TOFINO__  -I$P4_14INCLUDE \
        --primitives $P4_14INCLUDE/tofino/primitives.json"
    fi

    cmd="$p4graphs $P4PPFLAGS $extra_args --gen-dir $GRAPHS_DIR $P4_REALPATH"
    start_log $P4_LOGS/graphs.log $cmd

    if $cmd > $GRAPHS_DIR/graphs.log 2>> $P4_LOGS/graphs.log; then
        echo DONE
    else
        echo FAILED
        show_log $P4_LOGS/graphs.log
        return 1
    fi

    return 0
}

############################################################################
##########################     M A I N    ##################################
############################################################################

WORKDIR=`pwd`

#
# Option Processing
#
CMDLINE="$@"

opts=`getopt -o hvj:pI:D:U:                                         \
             -l help -l version  -l jobs: -l p4jobs:                \
             -l with-tofino      -l with-tofino2                    \
             -l without-tofino   -l no-tofino                       \
             -l with-thrift      -l without-thrift   -l no-thrift   \
             -l with-graphs      -l without-graphs   -l no-graphs   \
             -l with-p4c::       -l p4c::                           \
             -l with-p4-graphs:: -l p4-graphs::                     \
             -l with-p4graphs::  -l p4graphs::                      \
             -l with-suffix:     -l suffix:                         \
             -l p4flags-override                                    \
             -- "$@"`

if [ $? != 0 ]; then
  print_help
  exit 1
fi
eval set -- "$opts"
      
while true; do
    case "$1" in
        -h|--help)     print_help;    exit 0;;
        -v|--version)  print_version; exit 0;;
        -j|--jobs) if [[ $2 =~ ^[0-9]*$ ]]; then
                       jobs=$2;
                   else
                       echo "ERROR: Number of jobs (-j) must be an integer"
                       exit 1
                   fi;                       shift 2;;
        -I)
            MY_P4PPFLAGS+="$1"`realpath $2`; shift 2;;
        -[DU])
            MY_P4PPFLAGS+=" $1$2";           shift 2;;
        --with-tofino)
            with_tofino="--with-tofino";     shift 1;;
        --with-tofino2)
            with_tofino="--with-tofino2";    shift 1;;
        --without-tofino|--no-tofino)
            with_tofino="";                  shift 1;;
        --with-thrift)
            with_thrift="--enable_thrift";   shift 1;;
        --without-thrift|--no-thrift)
            with_thrift="";                  shift 1;;
        --with-graphs)
            with_graphs="yes";               shift 1;;
        --without-graphs|--no-graphs)
            with_graphs="no";                shift 1;;
        --with-p4c|--p4c)
            if [ -z $2 ]; then
                with_p4c="p4c";
            else
                with_p4c=$2;
            fi
                                             shift 2;;
        --with-p4-graphs|--p4-graphs|--with-p4graphs|--p4graphs)
            with_graphs="yes"
            if [ -z $2 ]; then
                p4graphs="p4-graphs"
            else
                p4graphs=$2;
            fi
                                             shift 2;;
        --with-suffix|--suffix)
            P4_SUFFIX=$2;                    shift 2;;
        -p|--p4flags-override)
            p4flags_override=1;              shift 1;;
        --) shift; break;
    esac
done

#
# Now process positional parameters
#

# The first parameter is the path to the program
P4_PATH=$1

if [ -z $P4_PATH ]; then
    cat <<EOF
ERROR: You didn't specify the name of the program to be compiled
EOF
    exit 1
fi
shift

if [ ! -f $P4_PATH ]; then
    echo "ERROR: P4 program $P4_PATH doesn't exist or is not readable"
    exit 1
fi

P4_REALPATH=$(realpath $P4_PATH)

#
# The rest of the parameters will be passed to p4-build/configure
# They will have the form VARIABLE=VALUE and so we'll capture them
# by setting the appropriate shell variables in the script.
#
# Note, that this is potentially a dangerous thing to do. For example,
# if they specify something like SDE= or any other variable that we
# rely on. But, that's the price of flexibility
#
# Also, we'll store the full list of these variables in $p4_build_vars
# so that we can recover the list.
#
# Some variables, most notably P4_VERSION and P4_ARCHITECTURE might be
# modified/corrected by the script
#
p4_build_vars=
for x in "$@"; do
    if [[ $x =~ ^([A-Za-z0-9_]*)=(.*) ]]; then
        p4_build_vars="$p4_build_vars ${BASH_REMATCH[1]}"
        eval "${BASH_REMATCH[1]}=\"${BASH_REMATCH[2]}\""
        shift
    fi
done
   
#
# Clean up P4_VERSION. Besides standard values ("p4_14" and "p4_16") the script
# allows some typical variations, e.g. P4_16, p4-14, and simply 16 (or 14) to
# reduce the number of user errors. In reality users do not need to specify
# P4 version explicitly
#
case ${P4_VERSION,,} in
    p4[-_]14|p414|14) P4_VERSION=p4_14;;
    p4[-_]16|p416|16) P4_VERSION=p4_16;;
    "");;
    *) cat <<EOF
ERROR: Supported values for P4_VERSION are p4_14 and p4_16. 
EOF
       exit 1;;
esac

#
# Clean up P4_ARCHITECTURE
#
case ${P4_ARCHITECTURE,,} in
    v1model|v1) P4_ARCHITECTURE=v1model;;
    tna)        P4_ARCHITECTURE=tna;;
    t2na)       P4_ARCHITECTURE=t2na;;
    "");;
    *) cat <<EOF
ERROR: Supported values for P4_ARCHITECTURE are:
          For P4_14 programs: v1model and tna
          FOR P4_16 programs: tna and t2na
EOF
       exit 1;;
esac

# Amend/create P4PPFLAGS
if [[ -z $P4PPFLAGS ]]; then
    p4_build_vars+=" P4PPFLAGS"
fi
P4PPFLAGS+="$MY_P4PPFLAGS"


check_environment
check_program
check_compiler

#
# Perform the actual build. The remaining parameters we pass are additional
# p4-build flags (usually should not be required)
#
build_p4_prog "$@"

#
# Build additional graphs. Currently only supported for P4_14 programs
#
build_graphs

fi # Executed, not sourced
