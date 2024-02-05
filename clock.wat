
(module


(import "wasi_unstable" "fd_write"
	(func $print (param i32 i32 i32 i32)(result i32))
)

(import "wasi_unstable" "clock_time_get"
	(func $clock (param i32 i64 i32)(result i32))
)

(memory 1)
(export "memory" (memory 0))


(func $main (export "_start")
	(local $runnum i32)
	i32.const 20
	local.set $runnum

	(loop $run
		local.get $runnum
			i32.const 1
			i32.sub
		local.set $runnum

		call $print_time
		
		local.get $runnum
		i32.const 0
		i32.gt_u
		br_if $run
	)
)

(func $print_time

	(local $tsb i64)
	(local $tsrptr i32)
	
	i32.const 0 ;;some sort of arbitrary identifier for clocks / I think 0 is generally what I need? further research needed.
	i64.const 0 ;;'precision'
	i32.const 0 ;;according to WASIX API, this is a ptr to loc in memory where time will be written to.
	call $clock
		;; will write the timestamp as 8 bytes, 0-7 in memory

	i32.const 0
	i64.load 0
	call $stringify64u
		;; my func to convert the i64 into a 20-char string + newline char

	i32.const 1 ;;arbitrary identifier for stdout
	i32.const 0 ;;ptr to iovec array (consists of ptr to string + length)
	i32.const 1 ;;length of iovec array, or num of strings it should write
	i32.const 30 ;;ptr to after the str where it logs how many bytes were written
		;;not sure why you would use this, but maybe is more important when writing to a diff destination than the terminal?
	call $print
	
	return
)

(func $stringify64u
	;;takes i64 and destination in memory in, turns into a "string"/iov
	(param $dest i32) (param $num i64)
	
	;;set base of iovec
	local.get $dest
	local.get $dest
		i32.const 8
		i32.add
	i32.store
	;;set iovec length
	local.get $dest
		i32.const 4
		i32.add
	i32.const 21 ;;max 2^64 = 20 digits + newline char
	i32.store

	;;set dest ptr to end of 21-char space
	local.get $dest
		i32.const 28 ;;max + iovec base/len, -1 for the last pos of it
		i32.add
	local.set $dest
	;;write the newline char to mem
	local.get $dest
		i32.const 10
	i32.store8
	;;decrement ptr to be next pos
	local.get $dest
		i32.const 1
		i32.sub
	local.set $dest


	(loop $convert
		;;get the ASCII of the 1s position of the i64 / write it to mem
		local.get $dest
		local.get $num
			i64.const 10
			i64.rem_u
			i64.const 48 ;;add for ASCII alignment
			i64.add
		i64.store8

		;;decrement ptr
		local.get $dest
		i32.const 1
		i32.sub
		local.set $dest
		;;remove 1s pos of i64
		local.get $num
			i64.const 10
			i64.div_u
		local.set $num

		;;check to end the loop
		local.get $num
		i64.const 0
		i64.gt_u
		br_if $convert

		;;technically, doesnt account for a time num thats < 20 digits / but dont rly need to for years sooo
	)
)
	

(;end;))
