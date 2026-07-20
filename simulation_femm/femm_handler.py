import subprocess
import random
import math
import numpy as np
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


def create_parameters_sets_monte_carlo(n):
    empty_materials = ["Air"]
    depths = [5, 10, 20, 30]

    stator_r_outs = [3, 4, 6, 8, 10]
    stator_out_ds = [1, 2, 3, 4]
    stator_materials = ["1018 Steel"]

    mag_size_xs = [3.0, 4.0, 5.0, 6.0, 7.0] 
    mag_size_ys = [1.0, 1.5, 2.0, 3.0, 4.0]
    mag_counts = [4,6,8,10,12,14]
    mag_materials = ["N35", "N42", "N52"]

    rotor_core_rs = [1,2,3,4,5,6,7,8,9]
    rotor_core_materials = ["1018 Steel"]
    plastic_materials = ["Air"]

    coil_groove_in_rs = np.round(np.linspace(1, 10, 20)).tolist()
    coil_groove_out_rs = np.round(np.linspace(1, 10, 20)).tolist()
    coil_groove_angs = np.round(np.linspace(5, 20, 20)).tolist()
    coil_groove_counts = [6,8,10,12,14] 
    coil_turnss = np.linspace(1, 100, 20, dtype=int).tolist()
    coil_ampss = np.round(np.linspace(1, 10, 20)).tolist()
    coil_materials = ["18 AWG", "20 AWG", "22 AWG", "24 AWG", "26 AWG"]

    combination_handler = [
        empty_materials,
        depths,
        stator_r_outs,
        stator_out_ds,
        stator_materials,
        mag_size_xs,
        mag_size_ys,
        mag_counts,
        mag_materials,
        rotor_core_rs,
        rotor_core_materials,
        plastic_materials,
        coil_groove_in_rs,
        coil_groove_out_rs,
        coil_groove_angs,
        coil_groove_counts,
        coil_turnss,
        coil_ampss,
        coil_materials
    ]

    all_param_combination = []

    for index in range(1, n + 1):
        random_params = [random.choice(p_list) for p_list in combination_handler]
        param_set = Parameters_set(index, *random_params)
        all_param_combination.append(param_set)

    return all_param_combination

def validate_parameters_sets(params):
    filterted_params = []

    flag = True
    for param_set in params:
        flag = True
        if param_set.rotor_core_r >= (param_set.coil_groove_in_r - 0.3): flag = False
        if param_set.coil_groove_in_r >= (param_set.coil_groove_out_r - 1.0): flag = False
        if not (param_set.coil_groove_out_r - param_set.coil_groove_in_r > 1): flag = False
        
        R = param_set.stator_r_out - param_set.stator_out_d
        w = param_set.mag_size_x
        h = param_set.mag_size_y
        if R <= 0 or (w / 2) >= R: 
            flag = False
        else:
            d_zewn = math.sqrt(R**2 - (w / 2)**2)
            d_min = d_zewn - h
            
            if param_set.coil_groove_out_r >= (d_min - 0.5): 
                flag = False

            max_w_half = d_min * math.tan(math.pi / param_set.mag_count)
            
            if (w / 2) >= max_w_half:
                flag = False

        if flag: filterted_params.append(param_set)
    return filterted_params

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
    work_dir = Path(__file__).parent.absolute()

    with open(work_dir/"output.csv", "w") as file: 
        file.close()

    command = f'"{femm_exe}" -lua-script="geometry_setup.lua"'

    print(f"Generating parameters")
    parameters = create_parameters_sets_monte_carlo(1000000)
    valid_parameters = validate_parameters_sets(parameters)
    create_parameters_file(work_dir/"femm_input.lua", valid_parameters)
    print(f"Validated {round((len(valid_parameters)/len(parameters))*100,3)}% - starting {len(valid_parameters)} simulations")

    try:
        subprocess.run(command, shell=True, cwd=str(work_dir), check=True)
        print("Done")
    except subprocess.CalledProcessError as e:
        print(f"FEMM SIMULATION ERROR: {e}")

if __name__ == "__main__": 
    main()