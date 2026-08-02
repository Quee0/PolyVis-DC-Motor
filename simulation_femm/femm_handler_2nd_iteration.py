import subprocess
import random
import math
import datetime
import numpy as np
import pandas as pd
from pathlib import Path
from dataclasses import dataclass, asdict

number_of_simulations = 480000 #4600 for 15 minutes
femm_exe = r"C:\femm42\bin\femm.exe"

optimal_copper_current_density = 4.5 #A/mm^2
coil_fill_factor = 0.5

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
    depths = [50]

    stator_r_outs = [25.0, 30.0, 35.0]
    stator_out_ds = [1.0, 2.0, 3.0]
    stator_materials = ["1018 Steel"]

    mag_size_xs = [3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0] 
    mag_size_ys = [1.0, 1.5, 2.0, 3.0, 4.0]
    mag_counts = [6,8,10,12,14,16]
    # mag_materials = ["N35", "N42", "N52"]
    mag_materials = ["N38"]

    rotor_core_rs = [16.0]
    # rotor_core_rs = [6.0, 7.5, 9.0, 10.0, 12.0, 14.0, 15.0]
    rotor_core_materials = ["1018 Steel"]
    plastic_materials = ["Air"]

    coil_groove_in_rs = np.round(np.linspace(10, 25, 20)).tolist()
    coil_groove_out_rs = np.round(np.linspace(10, 25, 20)).tolist()
    coil_groove_angs = np.round(np.linspace(5, 20, 20)).tolist()
    coil_groove_counts = [6,8,10,12,14] 
    coil_turnss = ["handler"]
    coil_ampss = ["handler"]
    coil_materials = ["18 AWG", "20 AWG", "22 AWG", "24 AWG", "26 AWG"]

    awg_to_mm2 = {
        "18 AWG": 0.823,
        "20 AWG": 0.518,
        "22 AWG": 0.326,
        "24 AWG": 0.205,
        "26 AWG": 0.129
    }

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

        S = awg_to_mm2[param_set.coil_material]
        I_nom = S*optimal_copper_current_density
        param_set.coil_amps = I_nom

        groove_A = (math.pi * (param_set.coil_groove_out_r**2 - param_set.coil_groove_in_r**2)) * (param_set.coil_groove_ang / 360)
        n = (groove_A*coil_fill_factor)/S
        param_set.coil_turns = max(1, math.floor(n))

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

        air_gap = d_min - param_set.coil_groove_out_r
        if air_gap >= 2 or air_gap <= 0.5: flag = False

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
        file.close()

def postprocess_data(file_name):
    df = pd.read_csv(file_name)

    # SAVING
    df = df.sort_values(by="stress_tensor_torque", key=lambda x: x.abs(), ascending=False)
    with pd.ExcelWriter('Simulation_output.xlsx', engine='xlsxwriter') as writer:
        df.to_excel(writer, sheet_name='Results', index=False)

        workbook = writer.book
        worksheet = writer.sheets['Results']

        header_style = workbook.add_format({
            'bold': True,
            'bg_color': "#89A738",
            'font_color': 'black',
            'border': 1,
            'valign': 'vcenter'
        })

        for col_num, value in enumerate(df.columns):
            worksheet.write(0, col_num, value, header_style)
        worksheet.freeze_panes(1, 0)

def main():
    work_dir = Path(__file__).parent.absolute()
    print(f"Program started at: {str(datetime.datetime.now().time())}")

    with open(work_dir/"output.csv", "w") as file:
        file.write(f'session_id,stress_tensor_torque,air_gap,current,volts,impedance,flux_re,k_const,v_supply,omega_nom,rpm_nom,power_nom,efficiency_nom,depth,stator_r_out,stator_out_d,rotor_core_r,mag_size_x,mag_size_y,mag_count,coil_groove_in_r,coil_groove_out_r,coil_groove_ang,coil_groove_count,coil_amps,coil_turns,mag_material,rotor_core_material,stator_material,plastic_material,coil_material\n')
        file.close()

    command = f'"{femm_exe}" -lua-script="geometry_setup.lua"'

    print(f"Generating parameters")
    parameters = create_parameters_sets_monte_carlo(number_of_simulations)
    valid_parameters = validate_parameters_sets(parameters)
    create_parameters_file(work_dir/"femm_input.lua", valid_parameters)
    print(f"Validated {round((len(valid_parameters)/len(parameters))*100,3)}% - starting {len(valid_parameters)} simulations")

    try:
        subprocess.run(command, shell=True, cwd=str(work_dir), check=True)
        print("Done")
        postprocess_data(work_dir/"output.csv")
        print(f"Program ended at: {str(datetime.datetime.now().time())}")
    except subprocess.CalledProcessError as e:
        print(f"FEMM SIMULATION ERROR: {e}")

if __name__ == "__main__": 
    main()
    postprocess_data(Path(__file__).parent.absolute()/"output.csv")