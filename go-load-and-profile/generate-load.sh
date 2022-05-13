#!/usr/bin/env bash

CALL_SCRIPT="./load-call.sh"

P=1
N=100

CPUPROFILE_PORT=
CPUPROFILE_SECONDS=5
CPUPROFILE_OUTPUT_PREFIX="cpu-"

while true; do
	case $1 in
	--parallel|-p)
		P="${2}"
		shift 2
		;;
	--num|-n)
		N="${2}"
		shift 2
		;;
	--cpuprofile_port)
		CPUPROFILE_PORT="${2}"
		shift 2
		;;
	--cpuprofile_seconds)
		CPUPROFILE_SECONDS="${2}"
		shift 2
		;;
	--cpuprofile_output_prefix)
		CPUPROFILE_OUTPUT_PREFIX="${2}"
		shift 2
		;;
	*) break ;;
	esac
done

execute() {
	echo "worker ${1} started ..."
	for ((i = 0; i < ${N}; i += 1)); do
		. "${CALL_SCRIPT}"
    	if (( $? > 0 )); then
    		>&2 echo "Error during execution in worker ${1}. Aborting."
    		exit 3
    	fi
    done
	echo "... worker ${1} finished"
	exit 0
}

echo "
script executed:	${CALL_SCRIPT}
parallelism:		${P}
# iterations:		${N}
"

procs=()
for ((i = 0; i < ${P}; i += 1)); do
	execute ${i} &
	procs+=($!)
done

if [ -n "${CPUPROFILE_PORT}" ]; then
	pprof -proto \
		-output "${CPUPROFILE_OUTPUT_PREFIX}-$(date +%s).prof.pb.gz" \
		"http://localhost:${CPUPROFILE_PORT}/debug/pprof/profile?seconds=${CPUPROFILE_SECONDS}" &
	procs+=($!)
fi

for proc in "${procs[@]}"; do
	wait "${proc}"
done
