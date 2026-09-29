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

### 1.2 Project & Idea Evolution

Initial assumptions involved building a brushed motor using easily available materials (3D printing, off-the-shelf parts). Method of estimating parameters, and whole project concept underwent a drastic and necessary transformation.

### 1.2.1 Material selection

#### All-Plastic Construction:

The original idea relied on 3D printing entire motor (except for the windings and magnets). It is quite common approch in DIY projects that demonstrates the working mechanism of brushed DC motor (or BLDC). This design was abandoned. Plastic has a magnetic permeability close to that of a vacuum ( $\mu \approx \mu_0$ ). The lack of a ferromagnetic material in the magnetic circuit makes concentrating the magnetic flux impossible, which in practice means drastically low efficiency and negligible torque.

#### Hybrid Construction (Plastic + Solid Steel):

To solve the lack of a ferromagnetics, the concept evolved into a hybrid solution. The rotor would be a plastic skeleton with an embedded steel core, and the stator is based on a solid steel pipe. To generate a strong 2-pole field using standard components, a multi-segment architecture was adopted. One half of the inner circumference is lined with small magnets facing with their N pole, and the other half with their S pole. Solid steel is exposed to eddy currents, which would melt whole construction. Because this engine would be limited by its hybrid approch, the change of magnetic field in stator (eddy currents) would be negligible. On the other hand, rotor must be laminated. This hybrid was a conscious compromise. The lower efficiency and losses of this construction were accepted. This is a trade-off allows for the fabrication of a prototype in a home workshop environment.

### 1.2.2 Evolution of the Computational Methodology

Determining the forces and torque required the creation of a reliable mathematical model. This model went through successive stages, discarding simplified assumptions in favor of a full electromagnetic simulation.

#### Custom Python Script:

Simulation of dipole distribution in a vacuum. The tool had immense educational value and developed physical intuition, but the script could not model the ferromagnetic material behaviour. This solution was rejected as the primary design tool. Nonetheless this project is a great educational tool and an enormous help for visualising magnetic field in free space. Mathematics was derived and developed based on equations "Introduction to Electrodynamics" by David J. Griffiths - a foundational text in the field. Whole repository is available as a standalone project here: https://github.com/Quee0/dipole-magnetostatic-solver.

#### Classical Magnetic Circuit (Reluctance modeling):

Another approch to this problem was to solve a magnetic circuit. This method quickly ran into a problem with calculating reluctances of airgaps. After reaserch, finding equations for different reluctances shapes and mailing a professor from my university suggested that this method cannot be precise. It failed due to a lack of reliable empirical data for the complex geometry.

#### Finite element analysis (FEMM & Lorentz Force):

To be as precise as possible in this kind of project FEA method was chosen (via free FEMM software). Initial thought was to simulate wide range of geometries and then integrate forces acting solely on current-carrying conductors placed in the slots. This method is used in standard electrodynamics courses, but it does not consider reluctance forces (lorenz force on ferromagnetics carrying the current). Upon further reaserch I choose to stick to FEMM software and develop results based on Maxwell stress tensor.

#### Final Model (FEA FEMM & Maxwell Stress Tensor):

Utilizing the FEA environment (FEMM) to simulate the field distribution with full consideration of material non-linearities. Torque is determined directly using the Maxwell Stress Tensor. Integrating stresses over a virtual contour (volume) surrounding the rotor allows for precise inclusion of both electrodynamic and reluctance forces in a single pass. It calculates forces based on fields nonsymmetry caused by the rotor. Theoretical derivation is in math chapter. In parallel with the magnetic verification, key electrical and topological parameters were established, forming the foundation for the commutator's construction:Topology: Simplex lap winding.

## 2. Simulation & Geometry Selection

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

### 2.2 Maxwell stress tensor derivation

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

### 2.3 Motor parameters calculation model

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

## 3. CAD

## 4. Bill of materials
