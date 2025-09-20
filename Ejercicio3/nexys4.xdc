## Reloj 100 MHz
set_property PACKAGE_PIN E3 [get_ports {CLK100MHZ}]
set_property IOSTANDARD LVCMOS33 [get_ports {CLK100MHZ}]
create_clock -period 10.000 -name sys_clk [get_ports {CLK100MHZ}]

## Switches de datos (usa al menos SW[0..15])
set_property PACKAGE_PIN T1 [get_ports {SW[0]}]
set_property PACKAGE_PIN R3 [get_ports {SW[1]}]
set_property PACKAGE_PIN P3 [get_ports {SW[2]}]
set_property PACKAGE_PIN P4 [get_ports {SW[3]}]
# agrega el resto SW[4]..SW[15] según tu XDC oficial

## Usa dos switches extra para control:
# (puedes reciclar SW[14] como SW_WE y SW[15] como SW_RST en el top)
set_property PACKAGE_PIN <PIN_SW14> [get_ports {SW_WE}]
set_property PACKAGE_PIN <PIN_SW15> [get_ports {SW_RST}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_WE}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_RST}]

## 7 segmentos (activos en 0)
set_property PACKAGE_PIN L3 [get_ports {SEG[0]}]  ;# CA (a)
set_property PACKAGE_PIN N1 [get_ports {SEG[1]}]  ;# CB (b)
set_property PACKAGE_PIN L5 [get_ports {SEG[2]}]  ;# CC (c)
set_property PACKAGE_PIN L4 [get_ports {SEG[3]}]  ;# CD (d)
set_property PACKAGE_PIN K3 [get_ports {SEG[4]}]  ;# CE (e)
set_property PACKAGE_PIN M2 [get_ports {SEG[5]}]  ;# CF (f)
set_property PACKAGE_PIN L6 [get_ports {SEG[6]}]  ;# CG (g)
set_property PACKAGE_PIN M4 [get_ports {DP}]      ;# punto decimal
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DP}]

## Ánodos (activos en 0)
set_property PACKAGE_PIN N6 [get_ports {AN[0]}]
set_property PACKAGE_PIN M6 [get_ports {AN[1]}]
set_property PACKAGE_PIN M3 [get_ports {AN[2]}]
set_property PACKAGE_PIN N5 [get_ports {AN[3]}]
set_property PACKAGE_PIN N2 [get_ports {AN[4]}]
set_property PACKAGE_PIN N4 [get_ports {AN[5]}]
set_property PACKAGE_PIN L1 [get_ports {AN[6]}]
set_property PACKAGE_PIN M1 [get_ports {AN[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[*]}]
