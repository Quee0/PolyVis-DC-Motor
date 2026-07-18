import subprocess
import itertools
import numpy
from pathlib import Path
from dataclasses import dataclass, asdict

femm_exe = r"C:\femm42\bin\femm.exe"

@dataclass
class Parameters_set:
    session_id: int
    empty_material: str
    depth: float

    stator_r_out: float
    stator_out_d: float
    stator_material: str

    mag_size_x: float 
    mag_size_y: float
    mag_size_z: float 
    mag_count: int
    mag_material: str

    rotor_core_r: float
    rotor_core_material: str
    plastic_material: str

    coil_groove_in_r: float
    coil_groove_out_r: float
    coil_groove_ang: float 
    coil_groove_count: int 
    coil_turns: int 
    coil_amps: float
    coil_material: str


def create_parameters_file(file_name, params):
    
    with open(file_name, "w") as file:
        file.write("parameters_list = {\n")

        # loop for every set
        for param_set in params:
            
            set_dict = asdict(param_set)
            
            file.write("{\n")
            #loop for every key
            for key, value in set_dict.items():
                if type(value) == str: file.write(f'{key} = "{value}",\n')
                else: file.write(f'{key} = {value},\n')
            file.write("},\n")

        file.write("}")

def main():

    with open("output.csv", "w") as file: 
        file.close()

    work_dir = Path(__file__).parent.absolute()
    command = f'"{femm_exe}" -lua-script="geometry_setup.lua"'

    parametry_test = [Parameters_set(
        session_id = 1,
        empty_material = "Air",
        depth = 50,

        stator_r_out = 10.65,
        stator_out_d = 2,
        stator_material = "1117 Steel",

        mag_size_x = 4,
        mag_size_y = 0.5,
        mag_size_z = 50,
        mag_count = 8,
        mag_material = "N45",

        rotor_core_r = 3.5,
        rotor_core_material = "1117 Steel",
        plastic_material = "Air",

        coil_groove_in_r = 4,
        coil_groove_out_r = 7,
        coil_groove_ang = 10,
        coil_groove_count = 12,
        coil_turns = 20,
        coil_amps = 4,
        coil_material = "24 AWG",
    ), Parameters_set(
        session_id = 1,
        empty_material = "Air",
        depth = 50,

        stator_r_out = 10.65,
        stator_out_d = 2,
        stator_material = "1117 Steel",

        mag_size_x = 4,
        mag_size_y = 0.5,
        mag_size_z = 50,
        mag_count = 8,
        mag_material = "N45",

        rotor_core_r = 3.5,
        rotor_core_material = "1117 Steel",
        plastic_material = "Air",

        coil_groove_in_r = 4,
        coil_groove_out_r = 7,
        coil_groove_ang = 10,
        coil_groove_count = 12,
        coil_turns = 20,
        coil_amps = 4,
        coil_material = "24 AWG",
    )
    ]

    create_parameters_file("femm_input.lua", parametry_test)
    
    try:
        subprocess.run(command, shell=True, cwd=str(work_dir), check=True, timeout=15)
        print("Done")
    except subprocess.CalledProcessError as e:
        print(f"FEMM SIMULATION ERROR: {e}")

if __name__ == "__main__": 
    main()