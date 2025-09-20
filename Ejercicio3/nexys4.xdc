## ================== CLOCK ==================
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -period 10.000 -name sys_clk [get_ports CLK100MHZ]

## ================== 7-SEGMENTS ==================
# Segmentos (activos en 0)
set_property PACKAGE_PIN L3 [get_ports {SEG[0]}]
set_property PACKAGE_PIN N1 [get_ports {SEG[1]}]
set_property PACKAGE_PIN L5 [get_ports {SEG[2]}]
set_property PACKAGE_PIN L4 [get_ports {SEG[3]}]
set_property PACKAGE_PIN K3 [get_ports {SEG[4]}]
set_property PACKAGE_PIN M2 [get_ports {SEG[5]}]
set_property PACKAGE_PIN L6 [get_ports {SEG[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[*]}]

# Punto decimal
set_property PACKAGE_PIN M4 [get_ports DP]
set_property IOSTANDARD LVCMOS33 [get_ports DP]

# Ánodos (activos en 0)
set_property PACKAGE_PIN N6 [get_ports {AN[0]}]
set_property PACKAGE_PIN M6 [get_ports {AN[1]}]
set_property PACKAGE_PIN M3 [get_ports {AN[2]}]
set_property PACKAGE_PIN N5 [get_ports {AN[3]}]
set_property PACKAGE_PIN N2 [get_ports {AN[4]}]
set_property PACKAGE_PIN N4 [get_ports {AN[5]}]
set_property PACKAGE_PIN L1 [get_ports {AN[6]}]
set_property PACKAGE_PIN M1 [get_ports {AN[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[*]}]

## ================== SWITCHES ==================
# ⚠️ Pinout que TÚ misma ya comprobaste (no lo cambies):
# SW[3]=P4, SW[2]=P3, SW[1]=R3, SW[0]=T1
# El resto según tu archivo previo:
set_property PACKAGE_PIN U9 [get_ports {SW[0]}]
set_property PACKAGE_PIN U8 [get_ports {SW[1]}]
set_property PACKAGE_PIN R7 [get_ports {SW[2]}]
set_property PACKAGE_PIN R6 [get_ports {SW[3]}]
set_property PACKAGE_PIN R5 [get_ports {SW[4]}]
set_property PACKAGE_PIN V7 [get_ports {SW[5]}]
set_property PACKAGE_PIN V6 [get_ports {SW[6]}]
set_property PACKAGE_PIN V5 [get_ports {SW[7]}]
set_property PACKAGE_PIN U4 [get_ports {SW[8]}]
set_property PACKAGE_PIN V2 [get_ports {SW[9]}]
set_property PACKAGE_PIN U2 [get_ports {SW[10]}]
set_property PACKAGE_PIN T3 [get_ports {SW[11]}]
set_property PACKAGE_PIN T1 [get_ports {SW[12]}]
set_property PACKAGE_PIN R3 [get_ports {SW[13]}]
set_property PACKAGE_PIN P3 [get_ports {SW[14]}]
set_property PACKAGE_PIN P4 [get_ports {SW[15]}]

# IOSTANDARD para TODOS los SW (también vale uno por bus):
set_property IOSTANDARD LVCMOS33 [get_ports {SW[*]}]

## ================== CONTROL EXTRA ==================
# Botón BTND en V10 para correr LFSR al mantener
set_property PACKAGE_PIN V10 [get_ports BTN_V10]
set_property IOSTANDARD LVCMOS33 [get_ports BTN_V10]
set_property PULLDOWN true [get_ports BTN_V10]

# Switches dedicados si tu toplevel tiene puertos SW_RST y SW_WE
# (si NO existen como puertos, borra estas 4 líneas)
set_property PACKAGE_PIN T16 [get_ports {SW_RST}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_RST}]
set_property PACKAGE_PIN R10 [get_ports {SW_WE}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_WE}]

## ================== CONFIG BANK ==================
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
