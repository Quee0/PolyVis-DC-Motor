# MOTOR PROJECT -TESTNAME- ⚡️

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

## 3. CAD

## 4. Bill of materials
