##====================== RELOJ ======================
## Bank 35, CLK100MHZ
set_property PACKAGE_PIN E3 [get_ports {CLK100MHZ}]
set_property IOSTANDARD LVCMOS33 [get_ports {CLK100MHZ}]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports {CLK100MHZ}]

##====================== SWITCHES ===================
## Usamos al menos SW[0] para el modo; puedes habilitar todos si quieres
set_property PACKAGE_PIN U9  [get_ports {SW[0]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
set_property PACKAGE_PIN U8  [get_ports {SW[1]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]
set_property PACKAGE_PIN R7  [get_ports {SW[2]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
set_property PACKAGE_PIN R6  [get_ports {SW[3]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
set_property PACKAGE_PIN R5  [get_ports {SW[4]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[4]}]
set_property PACKAGE_PIN V7  [get_ports {SW[5]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[5]}]
set_property PACKAGE_PIN V6  [get_ports {SW[6]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[6]}]
set_property PACKAGE_PIN V5  [get_ports {SW[7]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[7]}]
set_property PACKAGE_PIN U4  [get_ports {SW[8]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[8]}]
set_property PACKAGE_PIN V2  [get_ports {SW[9]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[9]}]
set_property PACKAGE_PIN U2  [get_ports {SW[10]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[10]}]
set_property PACKAGE_PIN T3  [get_ports {SW[11]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[11]}]
set_property PACKAGE_PIN T1  [get_ports {SW[12]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[12]}]
set_property PACKAGE_PIN R3  [get_ports {SW[13]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[13]}]
set_property PACKAGE_PIN P3  [get_ports {SW[14]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[14]}]
set_property PACKAGE_PIN P4  [get_ports {SW[15]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SW[15]}]

##====================== LEDS =======================
set_property PACKAGE_PIN T8  [get_ports {LED[0]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN V9  [get_ports {LED[1]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN R8  [get_ports {LED[2]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN T6  [get_ports {LED[3]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN T5  [get_ports {LED[4]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN T4  [get_ports {LED[5]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U7  [get_ports {LED[6]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN U6  [get_ports {LED[7]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V4  [get_ports {LED[8]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN U3  [get_ports {LED[9]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN V1  [get_ports {LED[10]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN R1  [get_ports {LED[11]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P5  [get_ports {LED[12]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN U1  [get_ports {LED[13]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN R2  [get_ports {LED[14]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN P2  [get_ports {LED[15]}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]

##====================== 7-SEG ======================
## segmentos (activos bajos)
set_property PACKAGE_PIN L3 [get_ports {SEG[0]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[0]}]
set_property PACKAGE_PIN N1 [get_ports {SEG[1]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[1]}]
set_property PACKAGE_PIN L5 [get_ports {SEG[2]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[2]}]
set_property PACKAGE_PIN L4 [get_ports {SEG[3]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[3]}]
set_property PACKAGE_PIN K3 [get_ports {SEG[4]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[4]}]
set_property PACKAGE_PIN M2 [get_ports {SEG[5]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[5]}]
set_property PACKAGE_PIN L6 [get_ports {SEG[6]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {SEG[6]}]
## punto decimal
set_property PACKAGE_PIN M4 [get_ports {DP}]      ; set_property IOSTANDARD LVCMOS33 [get_ports {DP}]
## ánodos (activos bajos)
set_property PACKAGE_PIN N6 [get_ports {AN[0]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property PACKAGE_PIN M6 [get_ports {AN[1]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property PACKAGE_PIN M3 [get_ports {AN[2]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property PACKAGE_PIN N5 [get_ports {AN[3]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]
set_property PACKAGE_PIN N2 [get_ports {AN[4]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[4]}]
set_property PACKAGE_PIN N4 [get_ports {AN[5]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[5]}]
set_property PACKAGE_PIN L1 [get_ports {AN[6]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[6]}]
set_property PACKAGE_PIN M1 [get_ports {AN[7]}]   ; set_property IOSTANDARD LVCMOS33 [get_ports {AN[7]}]

##====================== BOTONES ====================
## Mapeo sugerido: BTN[0]=BTNR, BTN[1]=BTNL, BTN[2]=BTNU, BTN[3]=BTND, RESET=BTNC
set_property PACKAGE_PIN R10 [get_ports {BTN[0]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {BTN[0]}]  ; # BTNR
set_property PACKAGE_PIN T16 [get_ports {BTN[1]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {BTN[1]}]  ; # BTNL
set_property PACKAGE_PIN F15 [get_ports {BTN[2]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {BTN[2]}]  ; # BTNU
set_property PACKAGE_PIN V10 [get_ports {BTN[3]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {BTN[3]}]  ; # BTND
set_property PACKAGE_PIN E16 [get_ports {RESET}]  ; set_property IOSTANDARD LVCMOS33 [get_ports {RESET}]   ; # BTNC (reset activo ALTO)
