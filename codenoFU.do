vsim -gui work.pipeline
mem load -i C:/intelFPGA_pro/17.0/pipline_project/FRam_codenoFU.mem /pipeline/f/ramm/ram
mem load -i C:/intelFPGA_pro/17.0/pipline_project/Fmem_codenoFU.mem /pipeline/M/mem/ram


add wave -position 17  sim:/pipeline/D/R0/q
add wave -position end  sim:/pipeline/D/R0/Clk
add wave -position end  sim:/pipeline/D/R0/Rst
add wave -position end  sim:/pipeline/D/R0/enb
add wave -position end  sim:/pipeline/D/R0/d
add wave -position end  sim:/pipeline/D/R0/q
add wave -position end  sim:/pipeline/D/R1/q
add wave -position end  sim:/pipeline/D/R2/q
add wave -position end  sim:/pipeline/D/R3/q
add wave -position end  sim:/pipeline/D/R4/q
add wave -position end  sim:/pipeline/E/IE_IM_flags/q
add wave -position end sim:/pipeline/f/pc/*
add wave -position end sim:/pipeline/f/irr_buf/*
add wave -position insertpoint  \
sim:/pipeline/E/alu_module/Rdst_buf \
sim:/pipeline/E/alu_module/Rsrc_buf
add wave -position insertpoint  \
sim:/pipeline/E/IE_IM_exec_res_L/q
add wave -position end  sim:/pipeline/D/R3_Rdst_buff/q
add wave -position end  sim:/pipeline/D/R2_Rsrc_buff/q
add wave -position insertpoint sim:/pipeline/FU/Rtype/dstRType/*
add wave -position insertpoint sim:/pipeline/FU/ForwardDetection/stallLD1/*
add wave -position insertpoint sim:/pipeline/FU/ForwardDetection/stallLD2/*
add wave -position insertpoint sim:/pipeline/FU/ForwardDetection/stallLDBuffL/*

force -freeze sim:/pipeline/Clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
run
force -freeze sim:/pipeline/Rst 0 0
run