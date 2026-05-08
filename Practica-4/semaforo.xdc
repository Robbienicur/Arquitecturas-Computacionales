## PYNQ-Z1 constraints para semaforo doble via
## Reloj de 50 MHz

## CLOCK 50 MHz
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 -name sys_clk -waveform {0 10} [get_ports clk]

## boton de reset (BTN0)
set_property PACKAGE_PIN D19 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## boton de emergencia (BTN3)
set_property PACKAGE_PIN L19 [get_ports emergency]
set_property IOSTANDARD LVCMOS33 [get_ports emergency]

## PMOD semaforo 1
set_property PACKAGE_PIN Y18 [get_ports {luz1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz1[2]}]
set_property PACKAGE_PIN Y19 [get_ports {luz1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz1[1]}]
set_property PACKAGE_PIN Y16 [get_ports {luz1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz1[0]}]

## PMOD semaforo 2
set_property PACKAGE_PIN U18 [get_ports {luz2[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz2[2]}]
set_property PACKAGE_PIN U19 [get_ports {luz2[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz2[1]}]
set_property PACKAGE_PIN W18 [get_ports {luz2[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz2[0]}]

## PMOD semaforo peaton (luz3)
set_property PACKAGE_PIN Y17 [get_ports {luz3[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz3[1]}]
set_property PACKAGE_PIN W19 [get_ports {luz3[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {luz3[0]}]

## PMOD state (debug, 6 bits)
set_property PACKAGE_PIN W14 [get_ports {state[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[5]}]
set_property PACKAGE_PIN Y14 [get_ports {state[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[4]}]
set_property PACKAGE_PIN T11 [get_ports {state[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[3]}]
set_property PACKAGE_PIN T10 [get_ports {state[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[2]}]
set_property PACKAGE_PIN V16 [get_ports {state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[1]}]
set_property PACKAGE_PIN W16 [get_ports {state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {state[0]}]
