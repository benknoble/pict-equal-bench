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

memory.csv: memory-bytes memory-record-dc
	{ printf '%s\n' memory,bench; \
		<memory-bytes sed 's/$$/,bytes/'; \
		<memory-record-dc sed 's/$$/,record-dc/'; } > $@

time.csv: time-bytes time-record-dc
	{ printf '%s\n' bench,cpu,real,gc; \
		<time-bytes sed -E 's/ ?(cpu|real|gc) time: /,/g;s/^/bytes/'; \
		<time-record-dc sed -E 's/ ?(cpu|real|gc) time: /,/g;s/^/record-dc/'; } > $@

memory.svg: memory.csv memory-plot.rkt
	rm -f $@
	racket memory-plot.rkt

time.svg: time.csv time-plot.rkt
	rm -f $@
	racket time-plot.rkt

$(COMPILED): bench.rkt
	raco make bench.rkt
