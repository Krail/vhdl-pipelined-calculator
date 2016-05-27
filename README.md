# Lab 2: VHDL 8-bit Calculator
##  CPEG 324
###    Sean Krail

The design of this single-cycle calculator roughly follows the simple, single-cycle MIPS processor shown in this image, including the naming of components:

![Image of the simple, single-cycle MIPS processor](https://raw.githubusercontent.com/Krail/vhdl-single-cycle-calculator/master/.meta/project.png)


## Install GHDL 0.31 (may not be necessary, GHDL 0.29 should be fine... maybe)
	sudo add-apt-repository ppa:pgavin/ghdl
	sudo apt update
	sudo apt install ghdl

## Run test benches
1. Enter make directory:
		cd make

2. Remove current test bench binaries (may not be necessary):
		make clean

3. Make test bench binaries
	a. Make all test bench binaries
		make
	b. Make a specific test bench binary
		make add2
		make alu
		make and2
		make calculator
		make control\_unit
		make full\_adder
		make half\_adder
		make mux2
		make or2
		make register\_file
		make sign\_extend
		make xor2
		make debug\_aluregfile
		make debug\_pc

4. Execute a test bench binary
		./add2\_tb
		./alu\_tb
		./and2\_tb
		./calculator\_tb
		./comparator2\_tb
		./control\_unit\_tb
		./debug\_aluregfile\_tb
		./debug\_pc\_tb
		./full\_adder\_tb
		./half\_adder\_tb
		./mux2\_tb
		./or2\_tb
		./register\_file\_tb
		./sign\_extend\_tb
		./xor2\_tb

## Main test bench
1. Enter make directory:
		cd make

2. Remove current test bench binaries (may not be necessary):
		make clean

3. Make calculator's test bench binary
  Make all or make calculator (they are equivalent)
		make
		make calculator

4. Execute the test bench binary
		./calculator\_tb

5. Create a GHW Waveform for GTKWave
        ./calculator\_tb --wave=../gtkwave/pipelined.ghw

## Features (definitely not bugs)
- We print every clock cycle.
- Overflow and underflow flags are set accordingly internally
  inside of the calculator, but our calculator never does anything about it.
- Register file does reads just after (not on!) the rising_edge of clock.
