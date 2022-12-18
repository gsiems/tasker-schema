#!/usr/bin/env bash
########################################################################
#
# 02_run_tests.sh Run pgTap tests
#
########################################################################

function usage() {

    cat <<'EOT'
NAME

02_run_tests.sh

SYNOPSIS

    02_run_tests.sh [-f] [-d] [-q] [-h]

DESCRIPTION

    Runs a set of one or more pgTap test files

OPTIONS

    -f [filename|directory]

        The file name or module directory to test.

            - If a directory is specified then all pgTap sql files in that
            directory sre run.

            - If a file is specified then just that file is run.

            - If not specified then tests are run for all module
            directories (in alpha-numeric order)

    -d database_name

        The name of the database to connect to (defaults to tasker)

    -q level

        Quieter. Requce the amount printed to stdout. Can be repeated
        to increase the quietness.

            - 0 Print everything to standard out
            - 1 Only print the failing tests and summaries to standard out
            - 2 Only print summaries to standard out
            - 3 Only print the final summary to standard out

    -h

        Displays this help

EOT
    exit 0
}

cd "$(dirname "$0")"

quieter=0
exitCode=0
totalPassed=0
totalFailed=0

########################################################################
# Read the calling args
while getopts 'hqd:f:' arg; do
    case ${arg} in
        h)
            usage
            exit 0
            ;;
        q) quieter=$((quieter + 1)) ;;
        d) db=${OPTARG} ;;
        f) file=${OPTARG} ;;
    esac
done

if [ -z "${db}" ]; then
    db=tasker
fi

function run_test() {
    local file="${1}"
    local outFile="${2}"

    echo "" >>${outFile}
    echo "#############################################################" >>${outFile}
    if [ -f ${file} ]; then
        echo "# Running $file" >>${outFile}
        psql -f ${file} ${db} >>${outFile}
    else
        echo "# No such file ($file)"
    fi
}

function test_module() {
    local module="${1}"
    local outFile="${2}"

    echo "" >>${outFile}
    echo "#############################################################" >>${outFile}
    echo "#############################################################" >>${outFile}
    echo "# Testing ${module} module" >>${outFile}

    for file in $(ls ${module}/*.sql); do
        run_test ${file} ${outFile}
    done
}

function print_summary() {
    local label="${1}"
    local outFile="${2}"

    passed=$(grep -c "^ok " ${outFile})
    failed=$(grep -c "^not ok " ${outFile})
    total=$((passed + failed))

    totalPassed=$((totalPassed + passed))
    totalFailed=$((totalFailed + failed))

    # quieter
    # 0 Print everything to standard out
    # 1 Only print the failing tests and summaries to standard out
    # 2 Only print summaries to standard out
    # 3 Only print the final summary to standard out

    case "${quieter}" in
        0)
            cat ${outFile}
            ;;

        1)
            echo ""
            echo "#############################################################"
            echo "# ${label}"
            if [ "${failed}" != "0" ]; then
                grep "# Failed test " ${outFile}
                echo ""
            fi
            echo "# Passed ${passed} of ${total}"
            if [ "${failed}" != "0" ]; then
                echo "# Failed ${failed} of ${total}"
            fi
            ;;

        2)
            echo ""
            echo "#############################################################"
            echo "# ${label}"
            echo "# Passed ${passed} of ${total}"
            if [ "${failed}" != "0" ]; then
                echo "# Failed ${failed} of ${total}"
            fi
            ;;

    esac

}

psql -f 10_init_testrun.sql ${db} 2>&1 >/dev/null

if [ -z "${file}" ]; then

    for module in $(find . -maxdepth 1 -type d ! -name test_data ! -name '\.*' | sort); do
        outFile=$(mktemp -p . tmp.XXXXXXXXXX.out)
        test_module ${module} ${outFile}
        print_summary ${module} ${outFile}
        rm ${outFile}
    done

elif [ -d "${file}" ]; then

    outFile=$(mktemp -p . tmp.XXXXXXXXXX.out)
    test_module ${file} ${outFile}
    print_summary ${file} ${outFile}
    rm ${outFile}

else

    outFile=$(mktemp -p . tmp.XXXXXXXXXX.out)
    run_test ${file} ${outFile}
    print_summary ${file} ${outFile}
    rm ${outFile}

fi

psql -f 40_finalize_testrun.sql ${db} 2>&1 >/dev/null

echo ""
echo "#############################################################"
echo "### Totals"
echo "Total Passed: ${totalPassed} of" $((totalPassed + totalFailed))

if [ "${totalFailed}" != "0" ]; then
    echo "Total Failed: ${totalFailed} of" $((totalPassed + totalFailed))
    exitCode=1
fi

exit ${exitCode}
