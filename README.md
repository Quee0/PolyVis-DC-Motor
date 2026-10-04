# PolyVis DC Motor ⚡️

<p align="left">
  <img src="https://img.shields.io/badge/CAD-Autodesk_Inventor-0696D7?style=flat&logo=autodesk&logoColor=white" alt="Autodesk Inventor">
  <img src="https://img.shields.io/badge/Enclosure-3D_Printable-FF6C2A?style=flat&logo=bambulab&logoColor=white" alt="3D Printing">
  <img src="https://img.shields.io/badge/Status-Tested_%26_Working-4C1?style=flat" alt="Status">
</p>

<p align="center">
  <img src="img\import\Main_animation_render.gif" width="1200" alt="Podpis alternatywny">
</p>

## 1. Project Overview

### 1.1 General Description

PolyVis is a fully functional, hybrid (3D-printed plastic + solid steel) brushed DC motor designed from scratch. The main goal was to create viable DC Motor, that can be built without expensive tools and hard-to-source materials. Furthermore its development was an R&D process bringing theoretical electromagnetism, Finite Element Analysis (FEA), and practical DIY manufacturing.

> [!NOTE]
> **This includes:**
>
> * Automated FEA methodology utilizing custom Python and Lua scripts for geometry generation and simulation,
> * Advanced parameters calculations using the Maxwell Stress Tensor to evaluate both electrodynamic and reluctance forces,
> * Real world characteristics reaserch,
> * Two-layer simplex lap winding integrated with a 6-segment commutator for smooth current switching,
> * Hybrid material architecture bridging the gap between accessible 3D printing and necessary ferromagnetic properties.

The end result is a fully functional prototype capable of validating theoretical models in the real world, demonstrating a practical understanding of electromagnetic design and applied physics.

### 1.2 Project & Idea Evolution

Initial assumptions involved building a brushed motor using easily available materials (3D printing, off-the-shelf parts). Method of estimating parameters, and whole project concept underwent a drastic and necessary transformation.

### 1.2.1 Material selection

#### ❌ All-Plastic Construction:

The original idea relied on 3D printing entire motor (except for the windings and magnets). It is quite common approch in DIY projects that demonstrates the working mechanism of brushed DC motor (or BLDC). This design was abandoned.

> [!NOTE]
> Plastic has a magnetic permeability close to that of a vacuum ( $\mu \approx \mu_0$ ). The lack of a ferromagnetic material in the magnetic circuit makes concentrating the magnetic flux impossible, which in practice means drastically low efficiency and negligible torque.

#### ✅ Hybrid Construction (Plastic + Solid Steel):

To solve the lack of a ferromagnetics, the concept evolved into a hybrid solution. The rotor would be a plastic skeleton with an embedded steel core, and the stator is based on a solid steel pipe. To generate a strong 2-pole field using standard components, a multi-segment architecture was adopted. One half of the inner circumference is lined with small magnets facing with their N pole, and the other half with their S pole.

> [!NOTE]
> Solid steel is exposed to eddy currents, which would melt whole construction. Because this engine would be limited by its hybrid approch, the change of magnetic field in stator (eddy currents) would be negligible. On the other hand, rotor must be laminated. This hybrid was a conscious compromise. The lower efficiency and losses of this construction were accepted. This is a trade-off allows for the fabrication of a prototype in a home workshop environment.

### 1.2.2 Evolution of the Computational Methodology

Determining the forces and torque required the creation of a reliable mathematical model. This model went through successive stages, discarding simplified assumptions in favor of a full electromagnetic simulation.

**1. Custom Python Script:**

* **Idea:** Custom simulation script of dipole distribution in a vacuum. The tool had immense educational value and developed physical intuition, but the script could not model the ferromagnetic material behaviour.
* **Verdict:** This solution was rejected as the primary design tool. Nonetheless this project is a great educational tool and an enormous help for visualising magnetic field in free space. Mathematics was derived and developed based on equations "Introduction to Electrodynamics" by David J. Griffiths - a foundational text in the field.
  *Note: The code was spun off into a standalone repository:* [`dipole-magnetostatic-solver`](https://github.com/Quee0/dipole-magnetostatic-solver).

**2. Classical Magnetic Circuit (Reluctance modeling):**

* **Idea:** Another approch to this problem was to solve a magnetic circuit. This method quickly ran into a problem with calculating reluctances of airgaps.
* **Verdict:** After reaserch, finding equations for different reluctances shapes and mailing a professor from my university suggested that this method cannot be precise. It failed due to a lack of reliable empirical data for the complex geometry.

#### Finite element analysis (FEMM & Lorentz Force):

* **Idea:** To be as precise as possible in this kind of project FEA method was chosen (via free FEMM software). Initial thought was to simulate wide range of geometries and then integrate forces acting solely on current-carrying conductors placed in the slots.
* **Verdict:** This method is used in standard electrodynamics courses, but it does not consider reluctance forces (lorenz force on ferromagnetics carrying the current). Upon further reaserch I choose to stick to FEMM software and develop results based on Maxwell stress tensor.

#### Final Model (FEA FEMM & Maxwell Stress Tensor):

* **Idea:** Utilizing the FEA environment (FEMM) to simulate the field distribution with full consideration of material non-linearities. Torque is determined directly using the Maxwell Stress Tensor.
* **Verdict:** Integrating stresses over a virtual contour (volume) surrounding the rotor allows for precise inclusion of both electrodynamic and reluctance forces in a single pass. It calculates forces based on fields nonsymmetry caused by the rotor. Theoretical derivation is in math chapter. In parallel with the magnetic verification, key electrical and topological parameters were established, forming the foundation for the commutator's construction:Topology: Simplex lap winding.

## 2. Simulation, Calculations & Geometry Selection

<p align="center">
  <img src="img\import\simulation_progress_gif.gif" width="1200" alt="Alt text">
</p>

The current script model for geometry optimization and selection was developed on the open-source finite element analysis tool - FEMM (`www.femm.info`). The script generates and tests various geometries, then simulates them and writes the data to Excel. On this basis, it was possible to select the target geometry and manually correct the parameters.

### 2.1 Simulation Files

```
root-directory
├── ...
└── simulation_femm/
    ├── femm_handler_2nd_iteration.py
    ├── femm_handler.py
    ├── geometry_setup.lua
    └── output.csv
```

**2nd iteration arised after aknowleding parameter problems in the first one. You can change parameters in either of them.**

### 2.2 Running the Simulation

The simulation process has been fully automated using Python and Lua scripts. Python generates geometries and later opens FEMM with lua scripting. To run this script, you need to set up the appropriate working environment.

* **Install Python** (version 3.x).
* **Install FEMM 4.2** (Finite Element Method Magnetics).

> [!WARNING]
> **Critical path requirement:** The main Python script calls the simulation engine directly. During the FEMM installation, make sure the destination path is exactly (or change destination in script):
> `C:\femm42\bin\femm.exe`

The script utilizes external libraries for data handling and generating final result spreadsheets. Install them using the `pip` package manager:

```bash
pip install numpy pandas xlsxwriter
```

To begin the Monte Carlo simulation, open a terminal in the target folder and run the script:

```bash
python femm_handler_2nd_iteration.py
```

**Background execution process:**
Upon launch, the script will automatically generate the `femm_input.lua` parameter batch file and execute the FEMM engine. Each valid geometry will be simulated and temporarily saved to the `output.csv` file. Once all iterations are complete, the script will sort the data by the highest torque and export a clean spreadsheet named `Simulation_output.xlsx`.

### 2.3 Maxwell stress tensor derivation

Main calculation done directly in FEMM is torque on rotor. I used volumetric integral (surface integral in 2D) of Maxwell's stress tensor. Typical academical approach to electromagnetic problems is to treat them as tranciver and reciver. One object generates electromagnetic field and the other expirience force. Based on my reaserch this approach is insufficient. It cannot easily determine forces on ferromagnetic elements (reluctance forces). Alternative approach is derived based on assimetry of electromagnetic field. It evaluates both the electrodynamic forces acting on the coils and the reluctance forces exerted on the ferromagnetic components. While the Virtual Work method provides a viable alternative for capturing reluctance forces through magnetic energy variations, the Maxwell stress tensor was selected for its direct and computationally efficient integration along the bounding surface.

#### Stress tensor derivation:

<details>
<summary><b> Expand for further details </b></summary>

Total electromagnetic force:

$$\mathbf{F} = q(\mathbf{E} + \mathbf{v} \times \mathbf{B}) = \int\int\int (\mathbf{E} + \mathbf{v} \times \mathbf{B})\rho dV$$

The force per unit volume is:

$$\mathbf{f} = \rho\mathbf{E} + \mathbf{J} \times \mathbf{B}$$

Next, charge density $\rho$ and current density $\mathbf{J}$ can be expressed in terms of fields $\mathbf{E}$ and $\mathbf{B}$, using Gauss's law and Ampère's law:

$$\mathbf{f} = \varepsilon_0 (\nabla \cdot \mathbf{E}) \mathbf{E} + \frac{1}{\mu_0} (\nabla \times \mathbf{B}) \times \mathbf{B} - \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t} \times \mathbf{B}$$

Another transformation comes from rewriting the Poynting vector. Using the product rule and Faraday's law of gives:

$$\frac{\partial}{\partial t} (\mathbf{E} \times \mathbf{B}) = \frac{\partial \mathbf{E}}{\partial t} \times \mathbf{B} + \mathbf{E} \times \frac{\partial \mathbf{B}}{\partial t} = \frac{\partial \mathbf{E}}{\partial t} \times \mathbf{B} - \mathbf{E} \times (\nabla \times \mathbf{E})$$

And now $\mathbf{f}$ as:

$$\mathbf{f} = \varepsilon_0 (\nabla \cdot \mathbf{E}) \mathbf{E} + \frac{1}{\mu_0} (\nabla \times \mathbf{B}) \times \mathbf{B} - \varepsilon_0 \frac{\partial}{\partial t} (\mathbf{E} \times \mathbf{B}) - \varepsilon_0 \mathbf{E} \times (\nabla \times \mathbf{E})$$

Rearrange $\mathbf{E}$ and $\mathbf{B}$:

$$\mathbf{f} = \varepsilon_0 \left[ (\nabla \cdot \mathbf{E}) \mathbf{E} - \mathbf{E} \times (\nabla \times \mathbf{E}) \right] + \frac{1}{\mu_0} \left[ -\mathbf{B} \times (\nabla \times \mathbf{B}) \right] - \varepsilon_0 \frac{\partial}{\partial t} (\mathbf{E} \times \mathbf{B})$$

"Fixing" symmetry by inserting $0 = (\nabla \cdot \mathbf{B}) \mathbf{B}$:

$$\mathbf{f} = \varepsilon_0 \left[ (\nabla \cdot \mathbf{E}) \mathbf{E} - \mathbf{E} \times (\nabla \times \mathbf{E}) \right] + \frac{1}{\mu_0} \left[ (\nabla \cdot \mathbf{B}) \mathbf{B} - \mathbf{B} \times (\nabla \times \mathbf{B}) \right] - \varepsilon_0 \frac{\partial}{\partial t} (\mathbf{E} \times \mathbf{B})$$

Eliminating the crossproducts (which are complicated to calculate), using the vector calculus identity:

$$\frac{1}{2} \nabla (\mathbf{A} \cdot \mathbf{A}) = \mathbf{A} \times (\nabla \times \mathbf{A}) + (\mathbf{A} \cdot \nabla) \mathbf{A} ,$$

leads to:

$$\mathbf{f} = \varepsilon_0 \left[ (\nabla \cdot \mathbf{E}) \mathbf{E} + (\mathbf{E} \cdot \nabla) \mathbf{E} \right] + \frac{1}{\mu_0} \left[ (\nabla \cdot \mathbf{B}) \mathbf{B} + (\mathbf{B} \cdot \nabla) \mathbf{B} \right] - \frac{1}{2} \nabla \left( \varepsilon_0 E^2 + \frac{1}{\mu_0} B^2 \right) - \varepsilon_0 \frac{\partial}{\partial t} (\mathbf{E} \times \mathbf{B}) .$$

This expression contains every aspect of electromagnetism and momentum and is relatively easy to compute. It can be written more compactly by introducing the **Maxwell stress tensor**,

$$\sigma_{ij} = \varepsilon_0 \left( E_i E_j - \frac{1}{2} \delta_{ij} E^2 \right) + \frac{1}{\mu_0} \left( B_i B_j - \frac{1}{2} \delta_{ij} B^2 \right) .$$

All but the last term of $\mathbf{f}$ can be written as the tensor divergence of the Maxwell stress tensor, giving:

$$\nabla \cdot \boldsymbol{\sigma} = \mathbf{f} + \varepsilon_0 \mu_0 \frac{\partial \mathbf{S}}{\partial t} ,$$

In FEMM we analise magnetostatic problem, so time derivative of Poynting vector is always 0, so:

$$\mathbf{f} = \nabla \cdot \boldsymbol{\sigma},$$

We integrate force per unit volume to get total force enduced on volume:

$$F = \int\int\int \mathbf{f} dV = \int\int\int \nabla \cdot \boldsymbol{\sigma} dV,$$

And finally we use the divergance theorem to get rid of nabla and replace integral type:

$$F = \int\int \boldsymbol{\sigma} \cdot dS$$

(Complete derivation: https://en.wikipedia.org/wiki/Maxwell_stress_tensor)

</details>

### 2.4 Motor parameters calculation model

<p align="center">
  <img src="img\import\Simulation_output_field.png" width="1200" alt="Alt text">
  <img src="img\import\Simulation_output_console.png" alt="Alt text">
</p>

Apart from defined and read parameters, python & lua scripts calculate and evaluate more expected values.

* **Torque Constant ($k_{const}$):** Determined as total electromagnetic torque (calculated using the Maxwell Stress Tensor) devided by the current flowing through the winding.

$$k_{const} = \frac{T}{I}$$

* **Back EMF:** The script calculates the voltage drop across the windings, incorporating a correction factor of $1.45$. The electromotive force is the difference between the defined supply voltage ($V_{supply} = 24\text{ V}$) and this voltage drop.

$$EMF = V_{supply} - (I \cdot Z)$$

* **Rotational Speed ($\omega$):** The angular velocity ($\omega$) in radians per second is the Back-EMF devided by the torque constant.

$$\omega = \frac{EMF}{k_{const}}$$

It can be later recalculated into RPM:

$$RPM = \omega \cdot \frac{30}{\pi}$$

* **Energy Efficiency ($\eta$):** Defined as the ratio of useful mechanical power to the total electrical power consumed. In non ideal reality efficienty is lower, because of work done by resistance forces. Despite that, this calculation allowed to compare different geometries.

$$\eta = \frac{\omega \cdot T}{V_{supply} \cdot I} \cdot 100\%$$

---

<details>
<summary><b> Verification of the output parameters: </b></summary>

* Electromagnetic torque ($T$): $-0.055\text{ Nm}$
* Current ($I$): $1.47\text{ A}$
* Voltage drop ($V_{drop}$): $0.973\text{ V}$
* Supply voltage ($V_{supply}$): $24\text{ V}$
* **Torque constant ($k_t$):**

$$k_const = \frac{-0.055}{1.467} = -0.0375$$

* **Nominal angular velocity ($\omega$):**

$$\omega = \frac{24 - 0.973}{-0.0375} = -613.3 \text{ rad/s}$$

* **Rotational speed (RPM):**

$$RPM = -613.3 \cdot \frac{30}{\pi} = -5856.6$$

* **Useful mechanical power ($P_{mech}$):**

$$P_{mech} = -613.3 \cdot (-0.055) = 33.8 \text{ W}$$

* **Total efficiency ($\eta$):**

$$\eta = \frac{33.8}{24 \cdot 1.467} \cdot 100 = 95.95 \%$$

</details>

### 2.5 Winding schamatic

This construction utilizes a two-layer simplex lap winding. It is integrated with a 12-slot core and a 6-segment commutator. The winding process begins at `Plate 1` which, at the illustrated commutation moment, serves as the positive voltage application point. The wire forms the first coil (L1) spanning from slot 1 to 7, and then directly proceeds to form the second coil (L2) routed through slots 2 to 8. This dual series sequence terminates at `Plate 2`. This configuration is replicated symmetrically around the entire commutator. The topology completes its loop by physically connecting the output of the final coil L12 (12-6) back to the initial `Plate 1`. After `Plate 4`, coils are wound as a second layer. It allows for the utilization of all plates while maintaining one-way current flow within each slot. Positioning the opposite power terminal (GND) on `Plate 4` effectively divides this closed circuit into two symmetrical, parallel current branches.

<p align="center">
  <img src="img\import\Commutator_switching_schematic.png" width="1200" alt="Alt text">
</p>

## 3. Physical Build

### 3.X Motor Performance Characteristics

To fully validate the physical build motor, its real-world performance is mapped against standard brushed DC motor characteristic curves. These idealized curves illustrate how the machine's primary parameters behave as the mechanical load (Torque) on the shaft increases from a free-spinning state (No-Load) to a complete stop (Stall).

<p align="center">
  <img src="img\import\dc_motor_characteristics.png" width="1200" alt="Alt text">
</p>

* **Rotational Speed ($\omega$):** Exhibits a linear decline as torque increases. The motor operates at its highest velocity under no load ($n_0$) and linearly drops to zero when the load exceeds the motor's capacity (Stall Torque).
* **Current Draw ($I$):** Shows a direct, linear increase proportional to the applied torque. It begins at a minimal no-load current (the energy required to overcome internal mechanical friction and magnetic losses) and reaches its absolute peak at stall condition.
* **Mechanical Output Power ($P_{out}$):** Forms a classic parabolic curve. Since mechanical power is the product of angular speed and torque ($P = \omega \cdot \tau$), it equals zero at both extremes (no torque and no speed). The maximum output power ($P_{2max}$) is theoretically achieved exactly at 50% of the stall torque and 50% of the no-load speed.
* **Efficiency ($\eta$):** Represents the ratio of useful mechanical power output to the electrical power input. The efficiency rises sharply to its maximum peak ($\eta_{max}$) at relatively low torque values (typically around 10-20% of the stall torque, often denoted as roughly $1/7 M_h$). Beyond this optimal point, as current (and resistive $I^2R$ heating) increases drastically, efficiency gradually drops to zero at the stall point.

## 4. CAD

## 5. Bill of materials
