#!/usr/bin/env bash
# build-kg2-snakemake.sh: Create KG2 JSON file from scratch using snakemake
# Copyright 2019 Stephen A. Ramsey
# Author Erica C. Wood

set -o nounset -o pipefail -o errexit

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo Usage: "$0 [test]"
    exit 2
fi

# Usage: build-kg2-snakemake.sh [test]

config_dir=`dirname "$0"`
source ${config_dir}/master-config.shinc

{
echo "================= starting build-kg2-snakemake.sh =================="
date

build_flag=${1-""}

if [[ "${build_flag}" == "test" ]]
then
    # The test argument for bash scripts (ex. extract-semmeddb.sh test)
    test_arg="test"
    # The test argument for file names (ex. kg2-owl-test.json)
    test_arg_d="-test"
    # The test argument for python scripts (ex. python3 uniprotkb_dat_to_json.py --test)
    test_arg_dd="--test"
else
    test_arg=""
    test_arg_d=""
    test_arg_dd=""
fi

SEMMED_TUPLELIST_FILE=${BUILD_DIR}/semmeddb/kg2-semmeddb${TEST_ARG_D}-tuplelist.json
SEMMED_OUTPUT_FILE=${BUILD_DIR}/kg2-semmeddb${TEST_ARG_D}-edges.json

UNIPROTKB_DAT_FILE=${BUILD_DIR}/uniprotkb/uniprot_sprot.dat
UNIPROTKB_OUTPUT_FILE=${BUILD_DIR}/kg2-uniprotkb${TEST_ARG_D}.json

OUTPUT_FILE_BASE=kg2-owl${TEST_ARG_D}.json
OUTPUT_FILE_FULL=${BUILD_DIR}/${OUTPUT_FILE_BASE}

OUTPUT_FILE_ORPHAN_EDGES=${BUILD_DIR}/kg2-orphans${TEST_ARG_D}-edges.json

FINAL_OUTPUT_FILE_BASE=kg2${TEST_ARG_D}.json
FINAL_OUTPUT_FILE_FULL=${BUILD_DIR}/${FINAL_OUTPUT_FILE_BASE}

SIMPLIFIED_OUTPUT_FILE_BASE=kg2-simplified${TEST_ARG_D}.json
SIMPLIFIED_OUTPUT_FILE_FULL=${BUILD_DIR}/${SIMPLIFIED_OUTPUT_FILE_BASE}

SIMPLIFIED_OUTPUT_NODES_FILE_BASE=kg2-simplified${TEST_ARG_D}-nodes.json
SIMPLIFIED_OUTPUT_NODES_FILE_FULL=${BUILD_DIR}/${SIMPLIFIED_OUTPUT_NODES_FILE_BASE}

OUTPUT_NODES_FILE_BASE=kg2${TEST_ARG_D}-nodes.json
OUTPUT_NODES_FILE_FULL=${BUILD_DIR}/${OUTPUT_NODES_FILE_BASE}

REPORT_FILE_BASE=kg2-report${TEST_ARG_D}.json
REPORT_FILE_FULL=${BUILD_DIR}/${REPORT_FILE_BASE}

SIMPLIFIED_REPORT_FILE_BASE=kg2-simplified-report${TEST_ARG_D}.json
SIMPLIFIED_REPORT_FILE_FULL=${BUILD_DIR}/${SIMPLIFIED_REPORT_FILE_BASE}

SLIM_OUTPUT_FILE_FULL=${BUILD_DIR}/kg2-slim${TEST_ARG_D}.json

ENSEMBL_SOURCE_JSON_FILE=${BUILD_DIR}/ensembl/ensembl_genes_homo_sapiens.json
ENSEMBL_OUTPUT_FILE=${BUILD_DIR}/kg2-ensembl${TEST_ARG_D}.json

CHEMBL_OUTPUT_FILE=${BUILD_DIR}/kg2-chembl${TEST_ARG_D}.json

OWL_LOAD_INVENTORY_FILE=${CODE_DIR}/ont-load-inventory${TEST_ARG_D}.yaml

CHEMBL_MYSQL_DBNAME=chembl

UNICHEM_OUTPUT_TSV_FILE=${BUILD_DIR}/unichem/chembl-to-curies.tsv
UNICHEM_OUTPUT_FILE=${BUILD_DIR}/kg2-unichem${TEST_ARG_D}.json

NCBI_GENE_TSV_FILE=${BUILD_DIR}/ncbigene/Homo_sapiens_gene_info.tsv
NCBI_GENE_OUTPUT_FILE=${BUILD_DIR}/kg2-ncbigene${TEST_ARG_D}.json

DGIDB_DIR=${BUILD_DIR}/dgidb
DGIDB_OUTPUT_FILE=${BUILD_DIR}/kg2-dgidb${TEST_ARG_D}.json

REPODB_DIR=${BUILD_DIR}/repodb
REPODB_INPUT_FILE=${BUILD_DIR}/repodb/repodb.csv
REPODB_OUTPUT_FILE=${BUILD_DIR}/kg2-repodb${TEST_ARG_D}.json

SMPDB_DIR=${BUILD_DIR}/smpdb
SMPDB_INPUT_FILE=${SMPDB_DIR}/pathbank_pathways.csv
SMPDB_OUTPUT_FILE=${BUILD_DIR}/kg2-smpdb${TEST_ARG_D}.json

DRUGBANK_INPUT_FILE=${BUILD_DIR}/drugbank.xml
DRUGBANK_OUTPUT_FILE=${BUILD_DIR}/kg2-drugbank${TEST_ARG_D}.json

HMDB_INPUT_FILE=${BUILD_DIR}/hmdb_metabolites.xml
HMDB_OUTPUT_FILE=${BUILD_DIR}/kg2-hmdb${TEST_ARG_D}.json

KG1_OUTPUT_FILE=${BUILD_DIR}/kg2-rtx-kg1${TEST_ARG_D}.json

KG2_TSV_DIR=${BUILD_DIR}/TSV
KG2_TSV_TARBALL=${BUILD_DIR}/kg2-tsv${TEST_ARG_D}.tar.gz

VERSION_FILE=${BUILD_DIR}/kg2-version.txt

# Run snakemake from the virtualenv but run the snakefile in kg2-code
# -F: Run all of the rules in the snakefile
# -R Finish: Run all of the rules in the snakefile
# -j: Run the rules in parallel
# -config: give the test arguments to the snakefile
# -n: dry run REMOVE THIS LATER

export PATH=$PATH:${BUILD_DIR}

cd ~ && ${VENV_DIR}/bin/snakemake --snakefile ${CODE_DIR}/Snakefile \
     -F -j --config test="${TEST_ARG}" testd="${TEST_ARG_D}" \
     testdd="${TEST_ARG_DD}" SEMMED_TUPLELIST_FILE="${SEMMED_TUPLELIST_FILE}" \
     SEMMED_OUTPUT_FILE="${SEMMED_OUTPUT_FILE}" UNIPROTKB_DAT_FILE="${UNIPROTKB_DAT_FILE}" \
     UNIPROTKB_OUTPUT_FILE="${UNIPROTKB_OUTPUT_FILE}" OUTPUT_FILE_BASE="${OUTPUT_FILE_BASE}" \
     OUTPUT_FILE_FULL="${OUTPUT_FILE_FULL}" OUTPUT_FILE_ORPHAN_EDGES="${OUTPUT_FILE_ORPHAN_EDGES}" \
     FINAL_OUTPUT_FILE_BASE="${FINAL_OUTPUT_FILE_BASE}" FINAL_OUTPUT_FILE_FULL="${FINAL_OUTPUT_FILE_FULL}" \
     SIMPLIFIED_OUTPUT_FILE_BASE="${SIMPLIFIED_OUTPUT_FILE_BASE}" \
     SIMPLIFIED_OUTPUT_FILE_FULL="${SIMPLIFIED_OUTPUT_FILE_FULL}" \
     SIMPLIFIED_OUTPUT_NODES_FILE_BASE="${SIMPLIFIED_OUTPUT_NODES_FILE_BASE}" \
     SIMPLIFIED_OUTPUT_NODES_FILE_FULL="${SIMPLIFIED_OUTPUT_NODES_FILE_FULL}" \
     OUTPUT_NODES_FILE_BASE="${OUTPUT_NODES_FILE_BASE}" OUTPUT_NODES_FILE_FULL="${OUTPUT_NODES_FILE_FULL}" \
     REPORT_FILE_BASE="${REPORT_FILE_BASE}" REPORT_FILE_FULL="${REPORT_FILE_FULL}" \
     SIMPLIFIED_REPORT_FILE_BASE="${SIMPLIFIED_REPORT_FILE_BASE}" SIMPLIFIED_REPORT_FILE_FULL="${SIMPLIFIED_REPORT_FILE_FULL}" \
     SLIM_OUTPUT_FILE_FULL="${SLIM_OUTPUT_FILE_FULL}" ENSEMBL_SOURCE_JSON_FILE="${ENSEMBL_SOURCE_JSON_FILE}" \
     ENSEMBL_OUTPUT_FILE="${ENSEMBL_OUTPUT_FILE}" CHEMBL_OUTPUT_FILE="${CHEMBL_OUTPUT_FILE}" \
     OWL_LOAD_INVENTORY_FILE="${OWL_LOAD_INVENTORY_FILE}" CHEMBL_MYSQL_DBNAME="${CHEMBL_MYSQL_DBNAME}" \
     UNICHEM_OUTPUT_TSV_FILE="${UNICHEM_OUTPUT_TSV_FILE}" UNICHEM_OUTPUT_FILE="${UNICHEM_OUTPUT_FILE}" \
     NCBI_GENE_TSV_FILE="${NCBI_GENE_TSV_FILE}" NCBI_GENE_OUTPUT_FILE="${NCBI_GENE_OUTPUT_FILE}" \
     DGIDB_DIR="${DGIDB_DIR}" DGIDB_OUTPUT_FILE="${DGIDB_OUTPUT_FILE}" \
     REPODB_DIR="${REPODB_DIR}" REPODB_INPUT_FILE="${REPODB_INPUT_FILE}" REPODB_OUTPUT_FILE="${REPODB_OUTPUT_FILE}" \
     SMPDB_DIR="${SMPDB_DIR}" SMPDB_INPUT_FILE="${SMPDB_INPUT_FILE}" SMPDB_OUTPUT_FILE="${SMPDB_OUTPUT_FILE}" \
     DRUGBANK_INPUT_FILE="${DRUGBANK_INPUT_FILE}" DRUGBANK_OUTPUT_FILE="${DRUGBANK_OUTPUT_FILE}" \
     HMDB_INPUT_FILE="${HMDB_INPUT_FILE}" HMDB_OUTPUT_FILE="${HMDB_OUTPUT_FILE}" \
     KG1_OUTPUT_FILE="${KG1_OUTPUT_FILE}" RTX_CONFIG_FILE="${rtx_config_file}" \
     KG2_TSV_DIR="${KG2_TSV_DIR}" KG2_TSV_TARBALL="${KG2_TSV_TARBALL}" \
     PREDICATE_MAPPING_FILE="${predicate_mapping_file}" \
     VENV_DIR="${VENV_DIR}" BUILD_DIR="${BUILD_DIR}" CODE_DIR="${CODE_DIR}" CURIES_TO_URLS_FILE="${curies_to_urls_file}" \
     MYSQL_CONF="${mysql_conf}" S3_CP_CMD="${s3_cp_cmd}" VERSION_FILE="${VERSION_FILE}"

date
echo "================ script finished ============================"
} >${BUILD_DIR}/build-kg2-snakemake.log 2>&1
