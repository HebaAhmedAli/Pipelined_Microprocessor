vsim -gui work.pipeline
mem load -filltype value -filldata {0110010000000000 } -fillradix symbolic /pipeline/f/ramm/ram(0)
mem load -filltype value -filldata 0000000000000101 -fillradix symbolic /pipeline/f/ramm/ram(1)
mem load -filltype value -filldata 0000011000000000 -fillradix symbolic /pipeline/f/ramm/ram(2)
mem load -filltype value -filldata 0110010000000010 -fillradix symbolic /pipeline/f/ramm/ram(3)
mem load -filltype value -filldata 0000000000000010 -fillradix symbolic /pipeline/f/ramm/ram(4)
mem load -filltype value -filldata 0110010000000001 -fillradix symbolic /pipeline/f/ramm/ram(5)
mem load -filltype value -filldata 0000000000000010 -fillradix symbolic /pipeline/f/ramm/ram(6)
add wave -position end  sim:/pipeline/Clk
add wave -position end  sim:/pipeline/Rst
add wave -position end  sim:/pipeline/f/pc/q
add wave -position end  sim:/pipeline/D/R0/q
add wave -position end  sim:/pipeline/D/R1/q
add wave -position end sim:/pipeline/D/R2/q
add wave -position end  sim:/pipeline/pc_mem_m_sig
add wave -position end  sim:/pipeline/ir_buf_ID_IF_sig
add wave -position 7  sim:/pipeline/ir_fetch_sig
add wave -position end  sim:/pipeline/f/irr_buf/Rst
add wave -position end  sim:/pipeline/f/irr_buf/enb
add wave -position end  sim:/pipeline/f/irr_buf/d
add wave -position end  sim:/pipeline/f/irr_buf/q
add wave -position 7  sim:/pipeline/f/ramm/address
add wave -position end  sim:/pipeline/f/jmp_cond
add wave -position end  sim:/pipeline/f/imm_buf
add wave -position 18  sim:/pipeline/D/Imm_buff_ID_IE
add wave -position 18  sim:/pipeline/D/R1_Imm_buff/rst
add wave -position 15  sim:/pipeline/Immediate_val_ID_IE_sig
add wave -position 3  sim:/pipeline/f/stall_ld
add wave -position 4  sim:/pipeline/f/pc/Rst
add wave -position 5  sim:/pipeline/f/pc/enb
add wave -position 3  sim:/pipeline/f/pc_mux1/s
add wave -position 3  sim:/pipeline/f/pc_mux2/s
add wave -position 4 sim:/pipeline/f/pc_mux3/s
add wave -position 3  sim:/pipeline/CU/offsetSel

add wave -position end  sim:/pipeline/LDM_cu_sig

add wave -position end  sim:/pipeline/LDM_ID_IE_sig
add wave -position 12  sim:/pipeline/D/R0/enb
add wave -position 14  sim:/pipeline/D/R1/enb
add wave -position 16  sim:/pipeline/D/R2/enb
force -freeze sim:/pipeline/Clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
run
force -freeze sim:/pipeline/Rst 0 0

