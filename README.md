
# wasm clock

Grey Keenan 24/05/02

This is just a small personal thing, my first with wat/wasm. I wrote a wat file which will print out the current POSIX time using "wasi_unstable" functions.

Right now, it just prints out the time unformatted. If I want to spend more time on this, I might change that.


*tested with wasmer 4.2.5


## todos, if I feel like it

1. Format POSIX time to date/time
2. Command-line arg to get the number of times to check the time.
3. Command-line arg for delay between checking the time.
4. Command-line arg for alternate date/time formatting schemes.

Not sure if I'll end up doing any of these, but just a list in case I come back to this later.


#### personal note:

This was originally in the le/wasm/reverse repo
