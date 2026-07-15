# SystemVerilog Modules

Personal collection of SystemVerilog RTL modules, designed and tested on a Xilinx Arty A7-100T FPGA.
Use verilator_automated.py for simulating and testing functionality

This is an ongoing learning repo. Modules get added and revised as I explore different areas of digital design in my free time — some are complete and tested, others are still in progress. 
Status is noted below and in each folder's `about.txt`.

## Module status

| Module | Status | Notes |
|---|---|---|
| UART (TX/RX) | ✅ Tested, working | 115200 baud, verified on Nandland Go board and Arty A7-100T |
| FIFO (18Kb sync) | ✅ Tested, working | Synthesized in Vivado, correctly mapped to an 18Kb BRAM block |
| Debounce | ✅ Tested, working | Simple mechanical button debounce filter |
| VGA | ✅ Tested, working | 640x480@60Hz timing driver plus modular sub-blocks |
| Clock Divider | ✅ Working, minor caveat | Possible drift over very long run times, not yet investigated |
| Pixel Grid Gen | ✅ Working, minor caveat | Known simulation quirk in Verilator; works fine on hardware |
| Generic Modules (LFSR, priority encoder, etc.) | ✅⚠️ Mostly tested | `collision_detection.sv` is an unimplemented stub |
| Snake Game | 🚧 In progress | Playable core loop; body storage is LUT-heavy and needs a BRAM-based rewrite |
| MX180TP scripts (Python) | AI-assisted (Vibe coded) | Bench power supply control scripts, not SystemVerilog. used to control PSU |


//MK
