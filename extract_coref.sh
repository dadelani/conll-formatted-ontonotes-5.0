#!/usr/bin/env bash

ONTONOTES_PATH=`readlink -f $1`
CONLL_PATH=`readlink -f $2`
OUTPUT_PATH=`readlink -f $3`

if [ -e $OUTPUT_PATH ]; then
    echo "Output path ${OUTPUT_PATH} already exist, deleting it ..."
    rm -rf $OUTPUT_PATH
    echo "  Done"
    mkdir -p $OUTPUT_PATH
fi

mkdir -p ${OUTPUT_PATH}/compiled

cd $CONLL_PATH

function extract_partition() {
    partition=$1
    echo
    echo "Extracting subset of ${partition} data with coref annotations ..."
    pushd data/${partition}/data/english/annotations > /dev/null
    for f in */*/*/*.gold_conll; do
        output_dir=${OUTPUT_PATH}/${partition}/${f%/*}
        if [ ! -d $output_dir ]; then
            mkdir -p $output_dir
        fi
        coref_file=${ONTONOTES_PATH}/data/files/data/english/annotations/${f%.*}.coref
        if [ -f $coref_file ]; then
            cp $f $output_dir
        fi
    done
    file_count=`find ${OUTPUT_PATH}/${partition} -type f | wc -l`
    echo "  ${file_count} files extracted to ${OUTPUT_PATH}/${partition}"
    popd > /dev/null
}

function compile_partition() {
    partition=$1
    echo "Compile all files in ${OUTPUT_PATH}/${partition} to ${OUTPUT_PATH}/compiled/${partition}.gold_conll"
    rm -f ${OUTPUT_PATH}/compiled/${partition}.gold_conll
    cat ${OUTPUT_PATH}/${partition}/*/*/*/*.gold_conll >> ${OUTPUT_PATH}/compiled/${partition}.gold_conll
}

extract_partition train
compile_partition train
extract_partition development
compile_partition development
extract_partition test
compile_partition test

