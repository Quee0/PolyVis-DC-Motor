import subprocess
import itertools
import numpy
from pathlib import Path

femm_exe = r"C:\femm42\bin\femm.exe"

def main():

    with open("output.csv", "w") as file: 
        file.close() 


    work_dir = Path(__file__).parent.absolute()
    command = f'"{femm_exe}" -lua-script="geometry_setup.lua"'
    
    try:
        subprocess.run(command, shell=True, cwd=str(work_dir), check=True)
        print("Done")
    except subprocess.CalledProcessError as e:
        print(f"FEMM SIMULATION ERROR: {e}")

if __name__ == "__main__": 
    main()