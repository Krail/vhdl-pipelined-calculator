GHDL        = ghdl
COMPONENTS  = ../components
TESTBENCHES = ../test_benches


all: add2 alu and2 calculator comparator2 control_unit full_adder half_adder mux2 or2 register_file sign_extend xor2 debug_aluregfile debug_pc


add2: full_adder xor2 $(COMPONENTS)/add2.vhd $(TESTBENCHES)/add2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/add2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/add2_tb.vhd  # test bench
	$(GHDL) -e add2_tb                      # binary

alu: add2 comparator2 $(COMPONENTS)/alu.vhd $(TESTBENCHES)/alu_tb.vhd
	$(GHDL) -a $(COMPONENTS)/alu.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/alu_tb.vhd  # test bench
	$(GHDL) -e alu_tb                      # binary

and2: $(COMPONENTS)/and2.vhd $(TESTBENCHES)/and2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/and2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/and2_tb.vhd  # test bench
	$(GHDL) -e and2_tb                      # binary

#######################################
calculator: add2 comparator2 and2 mux2 sign_extend control_unit register_file alu if_id id_ex ex_wb $(COMPONENTS)/calculator.vhd $(TESTBENCHES)/calculator_tb.vhd
	$(GHDL) -a $(COMPONENTS)/calculator.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/calculator_tb.vhd  # test bench
	$(GHDL) -e calculator_tb                      # binary
#######################################

comparator2: $(COMPONENTS)/comparator2.vhd $(TESTBENCHES)/comparator2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/comparator2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/comparator2_tb.vhd  # test bench
	$(GHDL) -e comparator2_tb                      # binary

control_unit: $(COMPONENTS)/control_unit.vhd $(TESTBENCHES)/control_unit_tb.vhd
	$(GHDL) -a $(COMPONENTS)/control_unit.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/control_unit_tb.vhd  # test bench
	$(GHDL) -e control_unit_tb                      # binary

full_adder: half_adder or2 $(COMPONENTS)/full_adder.vhd $(TESTBENCHES)/full_adder_tb.vhd
	$(GHDL) -a $(COMPONENTS)/full_adder.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/full_adder_tb.vhd  # test bench
	$(GHDL) -e full_adder_tb                      # binary

half_adder: and2 xor2 $(COMPONENTS)/half_adder.vhd $(TESTBENCHES)/half_adder_tb.vhd
	$(GHDL) -a $(COMPONENTS)/half_adder.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/half_adder_tb.vhd  # test bench
	$(GHDL) -e half_adder_tb                      # binary

mux2: $(COMPONENTS)/mux2.vhd $(TESTBENCHES)/mux2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/mux2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/mux2_tb.vhd  # test bench
	$(GHDL) -e mux2_tb                      # binary

or2: $(COMPONENTS)/or2.vhd $(TESTBENCHES)/or2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/or2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/or2_tb.vhd  # test bench
	$(GHDL) -e or2_tb                      # binary

register_file: $(COMPONENTS)/register_file.vhd $(TESTBENCHES)/register_file_tb.vhd
	$(GHDL) -a $(COMPONENTS)/register_file.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/register_file_tb.vhd  # test bench
	$(GHDL) -e register_file_tb                      # binary

sign_extend: $(COMPONENTS)/sign_extend.vhd $(TESTBENCHES)/sign_extend_tb.vhd
	$(GHDL) -a $(COMPONENTS)/sign_extend.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/sign_extend_tb.vhd  # test bench
	$(GHDL) -e sign_extend_tb                      # binary

xor2: $(COMPONENTS)/xor2.vhd $(TESTBENCHES)/xor2_tb.vhd
	$(GHDL) -a $(COMPONENTS)/xor2.vhd      # component
	$(GHDL) -a $(TESTBENCHES)/xor2_tb.vhd  # test bench
	$(GHDL) -e xor2_tb                      # binary

# Intermediate registers

if_id: $(COMPONENTS)/if_id.vhd
	$(GHDL) -a $(COMPONENTS)/if_id.vhd  # component

id_ex: $(COMPONENTS)/id_ex.vhd
	$(GHDL) -a $(COMPONENTS)/id_ex.vhd  # component

ex_wb: $(COMPONENTS)/ex_wb.vhd
	$(GHDL) -a $(COMPONENTS)/ex_wb.vhd  # component


# Debugging test benches

debug_aluregfile: calculator $(TESTBENCHES)/debug_aluregfile_tb.vhd
	$(GHDL) -a $(TESTBENCHES)/debug_aluregfile_tb.vhd  # test bench
	$(GHDL) -e debug_aluregfile_tb                      # binary

debug_pc: calculator $(TESTBENCHES)/debug_pc_tb.vhd
	$(GHDL) -a $(TESTBENCHES)/debug_pc_tb.vhd  # test bench
	$(GHDL) -e debug_pc_tb                      # binary



clean:
	rm -f *.o *.cf *_tb *.out
