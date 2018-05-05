vsim -gui work.pipeline
mem load -i {/home/fatema/Desktop/College/Third year/Second Term/Arch/project/Pipelined_Microprocessor/FRam_code4.mem} /pipeline/f/ramm/ram
mem load -i {/home/fatema/Desktop/College/Third year/Second Term/Arch/project/Pipelined_Microprocessor/Fmem_code3.mem} /pipeline/M/mem/ram
add wave -position end  sim:/pipeline/Clk
add wave -position end  sim:/pipeline/Rst
add wave -position end  sim:/pipeline/f/pc/q
add wave -position end  sim:/pipeline/D/R0/enb
add wave -position end  sim:/pipeline/D/R0/q
add wave -position end  sim:/pipeline/D/R1/enb
add wave -position end  sim:/pipeline/D/R1/q
add wave -position end  sim:/pipeline/D/R2/enb
add wave -position end  sim:/pipeline/D/R2/q
add wave -position 3  sim:/pipeline/ir_buf_ID_IF_sig
add wave -position end  sim:/pipeline/M/sp_reg/enb
add wave -position end  sim:/pipeline/M/sp_reg/d
add wave -position end  sim:/pipeline/M/sp_reg/q
add wave -position end  sim:/pipeline/M/mem/we
add wave -position end  sim:/pipeline/M/mem/datain
add wave -position end  sim:/pipeline/pc_call_IE_IM_sig
add wave -position end  sim:/pipeline/Rsrc_buff_ID_IE_sig
add wave -position end  sim:/pipeline/Rdst_buff_ID_IE_sig
add wave -position 4  sim:/pipeline/ir_fetch_sig
add wave -position 3  sim:/pipeline/f/pc_mux1/s
add wave -position 4  sim:/pipeline/f/pc_mux2/s
add wave -position 5 sim:/pipeline/f/pc_mux3/s
add wave -position 6 sim:/pipeline/f/pc_mux4/s
add wave -position 7  sim:/pipeline/f/pc_mux5/s
add wave -position 8  sim:/pipeline/f/pc_mux5/out1
add wave -position 9  sim:/pipeline/Immediate_val_ID_IE_sig
add wave -position 10  sim:/pipeline/CU/RTcircuitL/counterRTout
add wave -position 11  sim:/pipeline/CU/RTcircuitL/counter3
add wave -position 12  sim:/pipeline/CU/RTcircuitL/counterEn
add wave -position 13  sim:/pipeline/CU/RTcircuitL/counterRToutsig
add wave -position 14  sim:/pipeline/CU/RTcircuitL/retOp
add wave -position 15  sim:/pipeline/CU/RTcircuitL/rtiOp
add wave -position 3  sim:/pipeline/f/irr_buf/Rst
add wave -position 4  sim:/pipeline/f/irr_buf/enb
add wave -position 5  sim:/pipeline/f/irr_buf/q
add wave -position 3  sim:/pipeline/f/pc_mem
add wave -position 31  sim:/pipeline/M/inc_sp
add wave -position 31  sim:/pipeline/inc_SP_ID_IE_sig
add wave -position 31  sim:/pipeline/inc_SP_CU_sig
add wave -position end  sim:/pipeline/RTI_cu_sig
add wave -position end  sim:/pipeline/RTI_ID_IE_sig
add wave -position end  sim:/pipeline/RTI_IE_IM_sig
add wave -position 26  sim:/pipeline/D/D_write_Rdst/in_dec
add wave -position 27  sim:/pipeline/D/D_write_Rdst/out_dec
add wave -position 24  sim:/pipeline/D/D_write_Rsrc/in_dec
add wave -position 25  sim:/pipeline/D/D_write_Rsrc/out_dec
add wave -position 22  sim:/pipeline/D/Rdst_add_IM_IW
add wave -position 23  sim:/pipeline/D/Rsrc_add_IM_IW
add wave -position 22  sim:/pipeline/E/Rdst_add_IE_IM
add wave -position 23  sim:/pipeline/E/Rsrc_add_IE_IM
add wave -position 26  sim:/pipeline/E/IE_IM_exec_res_L/enb
add wave -position 27  sim:/pipeline/E/IE_IM_exec_res_L/q
force -freeze sim:/pipeline/Clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
run
force -freeze sim:/pipeline/Rst 0 0
run
