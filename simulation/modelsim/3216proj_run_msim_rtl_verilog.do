transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA/db {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/db/ip_altpll.v}
vlog -vlog01compat -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA/db {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/db/pll_altpll.v}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/spi_control.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/spi_serdes.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/ip.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/display_480p.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/rom_sync.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/sprite.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/color_mapper.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/lfsr.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/bullet.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/asteroid.sv}
vlog -sv -work work +incdir+C:/Users/stani/Documents/York\ University/Courses/2021-2022/Winter/EECS\ 3216\ -\ Digital\ Systems\ Engineering\ -\ Modelling,\ Implementation\ and\ Validation/Space-Invaders-FPGA {C:/Users/stani/Documents/York University/Courses/2021-2022/Winter/EECS 3216 - Digital Systems Engineering - Modelling, Implementation and Validation/Space-Invaders-FPGA/Top.sv}

