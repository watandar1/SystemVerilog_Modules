# =============================================== #
# This python script simulates sysmemverilog testbenches with its modules
# use it as "python3 verilator_automated.py location/systemverilog.sv location/tb_vga_controller.sv"
# =============================================== #
import subprocess
import sys
import time
from pathlib import Path


def run_verilator(module, tb): #module is module to be tested and tb is the testbench
    top = Path(tb).stem

    # gather all include directories in the current directory except obj_dir
    include_dirs = [f"-I{p}" for p in Path.cwd().glob('*') if p.is_dir() and p.name != 'obj_dir']

    cmd = [
        "verilator",
        "--binary",
        #"--Wall", add this if you want all warnings and everything, this might be annoying
        "--trace",
        "--timing",
        *include_dirs,
        module,
        tb,
        f"--top {top}"
    ]
    print("Running:", " ".join(cmd))
    subprocess.run(" ".join(cmd), shell=True, check=True)
    # find the path for /obj_dir/ Vtestbench
    exe_path = Path("obj_dir") / f"V{top}"


    #wait until we found the executeable
    print(f"Waiting for {exe_path}...")
     
    for i in range(20):
        # if path exist break 
        if exe_path.exists():
            print(f"{exe_path} exists")
            break

        else:
            # the path does not exist wait and try again 
            print(f"{exe_path} does not exist")
            time.sleep(0.5)
    else:
        print(f"Did not find path {exe_path}, exiting")
        sys.exit(1)
 
    #lets run the simulator
    print("Running simulation...")
    subprocess.run(str(exe_path), check=True)

    vcd_file = Path("waveform.vcd")
    if not vcd_file.exists():
        print("No waveform.vcd")
        sys.exit(1)

    print("Opening waveform with GTKWave...")
    subprocess.run(["gtkwave", str(vcd_file)])



if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <module.sv> <tb.sv>")
        sys.exit(1)

    module_file = sys.argv[1] # your code to test 
    tb_file = sys.argv[2] # the testbench to test your code on
    run_verilator(module_file, tb_file)