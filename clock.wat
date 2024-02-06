
(module


(import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32)(result i32)))
(import "wasi_unstable" "clock_time_get" (func $clock_time_get (param i32 i64 i32)(result i32)))

(memory 1)
(export "memory" (memory 0))

(func $main (export "_start")

	call $print_time

)

(func $print_time
	(local $strend i32)

	i32.const 0 ;;arbitrary clock id
	i64.const 0 ;;precision of the clock
	i32.const 0 ;;ptr to memory, will write i64 there
	call $clock_time_get

	i32.const 8
	i32.const 0
	i64.load 
	call $strme_u64
	local.set $strend

	i32.const 1 ;;arbitrary identifier for stdout
	i32.const 8 ;;ptr to iovec array
	i32.const 1 ;;num of iovecs to write
	local.get $strend ;;ptr to mem, will write num of bytes printed (i32 or i64?) / I wonder if you can disable this somehow
	call $fd_write

	return
)

(func $strme_u64
	(param $destination i32)
	(param $n i64)

	(result i32)
	
	(local $len i32)
	(local $writeTo i32)
	(local $swapFrom i32)

	;;set writeTo & swapFrom (for later), ptr to where chars will be
	local.get $destination
	i32.const 8
	i32.add
	local.tee $writeTo
	local.set $swapFrom

	;;set base of iovec
	local.get $destination
	local.get $writeTo
	i32.store
	
	(loop $charme ;;write each digit as char to mem in reverse order
		;;get 1s position and store as char
		local.get $writeTo
		local.get $n
		i64.const 10
		i64.rem_u
		i64.const 48 ;;ASCII num offset
		i64.add
		i64.store8

		;;increment ptr
		local.get $writeTo
		i32.const 1
		i32.add
		local.set $writeTo

		;;increment len
		local.get $len
		i32.const 1
		i32.add
		local.set $len
		
		;;chop $n and check for 0
		local.get $n
		i64.const 10
		i64.div_u
		local.tee $n
		i64.const 0
		i64.gt_u
		br_if $charme
	)

	;;end with newline char
	local.get $writeTo
	i32.const 10
	i32.store8

	;;increment len for newline char
	local.get $len
	i32.const 1
	i32.add
	local.set $len

	;;decrement $writeTo for reversal:
	local.get $writeTo
	i32.const 1
	i32.sub
	local.set $writeTo

	(loop $reverse ;;reverse string to be in correct order, not including newline char
		;;swap them (its a stack, so dont need a buffer var)
		local.get $swapFrom
		local.get $writeTo
		i32.load8_u
		local.get $writeTo
		local.get $swapFrom
		i32.load8_u
		i32.store8
		i32.store8

		;;decrement writeTo
		local.get $writeTo
		i32.const 1
		i32.sub
		local.set $writeTo

		;;increment swapFrom
		local.get $swapFrom
		i32.const 1
		i32.add
		local.set $swapFrom

		;;end condition
		local.get $swapFrom
		local.get $writeTo
		i32.lt_u
		br_if $reverse
	)

	;;set len of iovec
	local.get $destination
	i32.const 4
	i32.add
	local.get $len
	i32.store

	;;return ptr to first byte after str
	local.get $destination
	i32.const 8
	i32.add
	local.get $len
	i32.add
	return
)


(;end;))
