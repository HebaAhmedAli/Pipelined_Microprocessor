vsim -gui work.pipeline
mem load -i {/home/fatema/Desktop/College/Third year/Second Term/Arch/project/Pipelined_Microprocessor/FRam_code2.mem} /pipeline/f/ramm/ram
mem load -i {/home/fatema/Desktop/College/Third year/Second Term/Arch/project/Pipelined_Microprocessor/Fmem_code2.mem} /pipeline/M/mem/ram
add wave -position end  sim:/pipeline/Clk
add wave -position end  sim:/pipeline/Rst
add wave -position end  sim:/pipeline/D/R0/enb
add wave -position end  sim:/pipeline/D/R0/q
add wave -position end  sim:/pipeline/D/R1/enb
add wave -position end  sim:/pipeline/D/R1/q
add wave -position end  sim:/pipeline/D/R2/enb
add wave -position end  sim:/pipeline/D/R2/q
add wave -position end  sim:/pipeline/FU/forwardSelDst
add wave -position end  sim:/pipeline/FU/rDstBuf
add wave -position end  sim:/pipeline/ir_buf_ID_IF_sig
add wave -position end  sim:/pipeline/Immediate_val_ID_IE_sig
add wave -position end  sim:/pipeline/f/pc/q
add wave -position 10  sim:/pipeline/FU/memoryResult
add wave -position end  sim:/pipeline/FU/writeEnrDstDE
add wave -position end  sim:/pipeline/FU/execResultLDstSelSig
add wave -position end  sim:/pipeline/FU/forwardSelSrc
add wave -position 14  sim:/pipeline/FU/execResultLow
add wave -position 13  sim:/pipeline/D/Rdst_buff_ID_IE
add wave -position 9  sim:/pipeline/FU/RtypeDE
add wave -position end  sim:/pipeline/flag_reg_sig
add wave -position 12  sim:/pipeline/D/Rsrc_buff_ID_IE
add wave -position end  sim:/pipeline/E/en_exec_result_sig
add wave -position end  sim:/pipeline/E/ALU_op_ctrl
add wave -position 21  sim:/pipeline/E/flags
add wave -position 3  sim:/pipeline/CU/jmpOffsetL/condJMP/en
add wave -position 4  sim:/pipeline/CU/jmpOffsetL/condJMP/q
add wave -position 5  sim:/pipeline/CU/jmpOffsetL/delayJMPDE
add wave -position 4  sim:/pipeline/f/pc_mux3/in1
add wave -position 5  sim:/pipeline/f/pc_mux3/in2
add wave -position 6  sim:/pipeline/f/pc_mux3/s
add wave -position 7 sim:/pipeline/D/R_selOffsetPc/*
force -freeze sim:/pipeline/Clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
run
force -freeze sim:/pipeline/Rst 0 0
run






