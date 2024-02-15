.POSIX:
SHELL = /bin/sh
.SUFFIXES:

COMPILED = compiled/bench_rkt.dep compiled/bench_rkt.zo

time-bench: $(COMPILED)
	rm -f time-bytes time-record-dc
	touch time-bytes time-record-dc
	hyperfine 'racket bench.rkt --time --bytes -n 1 >> time-bytes' 'racket bench.rkt --time --record-dc -n 1 >> time-record-dc'

memory-bench: $(COMPILED)
	rm -f memory-bytes memory-record-dc
	touch memory-bytes memory-record-dc
	hyperfine 'racket bench.rkt --memory --bytes -n 1 >> memory-bytes' 'racket bench.rkt --memory --record-dc -n 1 >> memory-record-dc'

$(COMPILED): bench.rkt
	raco make bench.rkt
