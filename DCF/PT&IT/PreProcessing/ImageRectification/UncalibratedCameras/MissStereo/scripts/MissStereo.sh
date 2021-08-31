#!/bin/bash

# Exit in case of error
set -e

# Log file
LOGFILE=.missStereo.log

# Necessary utilities
BASENAME=/usr/bin/basename
TEE=/usr/bin/tee
DATE=/bin/date
GREP=/bin/grep
CUT=/usr/bin/cut

# Append to log file
log () {
    echo \[`$DATE +"%F %T.%N"`\] $1 >> $LOGFILE
}

# Execute command and output to log file
log_exe () {
    log "$1"
    if [ $# = 1 ]; then
        $1 2>&1 |$TEE -a $LOGFILE;
    elif [ $# = 2 ]; then # copy std output to file
        $1 2>&1 |$TEE -a $LOGFILE |$TEE $2;
    else # 3rd argument (whatever its value) means "launch as background"
        $1 2>&1 |$TEE -a $LOGFILE |$TEE $2 &
        PID=$!
    fi
    [ ${PIPESTATUS[0]} = 0 ] || false
}

# Rectification pipeline. Set variables DISPARITY, HIN1, and HIN2.
rectification() {
# --- 1: SIFT matches ---
    PAIRS="$IM1"_"$IM2"_pairs.txt
    log_exe "sift $1 $2 $PAIRS toto.png"

# --- 2: ORSA matches ---
    PAIRS_GOOD="$IM1"_"$IM2"_pairs_orsa.txt
    log_exe "orsa $DIM $PAIRS $PAIRS_GOOD 500 1 0 2 0"

# --- 3: Rectification ---
    FILE_DISPARITY=${IM1}_${IM2}_disparity.txt
    log_exe "rectify $PAIRS_GOOD $DIM ${IM1}_h.txt ${IM2}_h.txt" $FILE_DISPARITY
    # Put disparity range in shell variable
    DISPARITY=`$GREP Disparity $FILE_DISPARITY |$CUT -f 2 -d :`

    # If we do not stop after rectification, output float rectified images
    if [ "${MODE}" != "Rectify" ]; then
        HIN1=H_${IM1}_float.tif
        HIN2=H_${IM2}_float.tif;
    fi

# --- 4: Run two homographies in parallel ---
    log_exe "homography $1 ${IM1}_h.txt H_$IM1 ${HIN1}" /dev/null background
    log_exe "homography $2 ${IM2}_h.txt H_$IM2 ${HIN2}"
    wait $PID
}

# Disparity pipeline
disparity() {
    OUT=${IM1}_float.tif

# --- 5: A contrario block matching ---
    log_exe "stereoAC $HIN1 $HIN2 $DISPARITY disp1_$OUT"

# --- 6: Self-similarity filter ---
    log_exe "selfSimilar $HIN1 $HIN2 $DISPARITY disp1_$OUT disp2_$OUT"

# --- 7: Sub-pixel refinement ---
    log_exe "subPixel $HIN1 $HIN2 disp2_$OUT disp3_$OUT"

# --- 8: Fill by median ---
    log_exe "medianFill disp3_$OUT disp4_$OUT"

    # Convert disp3 (subpixel map) to 8-bit image and record min/max disparities
    FILE_MINMAX=${IM1}_minmax.txt
    log_exe "convert disp3_$OUT disp3_${IM1}.png" $FILE_MINMAX
    # Put observed disparity range in shell variable
    MINMAX=`$CUT -f 2 -d : $FILE_MINMAX`

    # Convert all 3 other disparity maps to 8-bit
    for i in 1 2 4; do
        log_exe "convert disp${i}_$OUT disp${i}_${IM1}.png $MINMAX"
    done

    # Display density of each map
    for i in 1 2 3 4; do
        COMMAND="density disp${i}_$OUT"
        log "$COMMAND"
        echo -n disp${i}_$OUT " " |$TEE -a $LOGFILE
        $COMMAND 2>&1 |$TEE -a $LOGFILE
        [ ${PIPESTATUS[0]} = 0 ] || false
    done

# --- 9: output PLY file ---
    # If we did rectification, get estimated K matrices
    if [ "x$FILE_DISPARITY" != "x" ]; then
        $GREP K_left  $FILE_DISPARITY |$CUT -f 2 -d : > Kl_$IM1.txt
        $GREP K_right $FILE_DISPARITY |$CUT -f 2 -d : > Kr_$IM1.txt
        printf -v Klr "%s %s" Kl_$IM1.txt Kr_$IM1.txt
    fi
    log_exe "mesh disp4_$OUT ${IM1} disp4_${IM1}.ply ${Klr}"
}

# Just rectification
if [ "`$BASENAME $0`" = "Rectify.sh" ]; then
    MODE="Rectify";
fi

# Just disparity
if [ "`$BASENAME $0`" = "Disparity.sh" ]; then
    MODE="Disparity";
fi

if [ "$MODE" = "Disparity" ]; then
    [ $# = 4 ] || { echo Usage: $0 image1 image2 dispMin dispMax; false; }
else
    [ $# = 2 ] || { echo Usage: $0 image1 image2; false; }
fi

[ "$MISS_STEREO_PATH" = "" ] || export PATH=${MISS_STEREO_PATH}:$PATH

IM1=`$BASENAME $1`
IM2=`$BASENAME $2`
log ""
log "MISS_STEREO_PATH=$MISS_STEREO_PATH"
log "IM1=$IM1 IM2=$IM2"

# --- 0: Get image sizes and check they are the same ---
COMMAND="size $1"
log "$COMMAND"
DIM=`$COMMAND 2>&1 |$TEE -a $LOGFILE`
[ "$DIM" = "`size $2`" ] || { echo Images are not of same size. Unable to proceed; false; }
log "Size: $DIM"

if [ "$MODE" = "Disparity" ]; then
    printf -v DISPARITY "%s %s" $3 $4 
    HIN1="$IM1"
    HIN2="$IM2"
else # Rectification part
    rectification "$1" "$2"
fi #End of rectification part

# Ultimate part of rectification, for visual inspection
if [ "${MODE}" = "Rectify" ]; then
    log_exe "showRect H_$IM1 show_H_$IM1 ${PAIRS_GOOD} left ${IM1}_h.txt"
    log_exe "showRect H_$IM2 show_H_$IM2 ${PAIRS_GOOD} right ${IM2}_h.txt"
fi

# If we proceed with disparity, the input images are the rectified ones
if [ "${MODE}" != "Disparity" ]; then
    IM1=H_${IM1}
    IM2=H_${IM2}
fi

# Disparity computation
if [ "${MODE}" != "Rectify" ]; then
    disparity
fi # End of disparity computation
