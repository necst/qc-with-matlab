# Quantum Computing: A Practical Perspective
This is the official repository of the course "Quantum Computing: A Practical Perspective", offered by NECSTLab @ Politecnico di Milano, in collaboration with MathWorks.

## Course Details

This course aims to introduce the basic notions to design, develop, and analyze algorithms for quantum computers. In the last decades, the state of the art has produced an extraordinary improvement for quantum architectures, that are able to tackle complex problems, achieving extremely reduced execution time if compared to classical computation. Yet, current limits regarding the number of available qubits and noise intensity strongly limit their potential. Therefore, a quantum engineer needs to know how to design algorithms, identify their bottlenecks, and adopt effective solutions to mitigate noise.This course aims to provide students with the necessary notions to use MathWorks MATLAB Support Package for Quantum Computing, in order to design quantum algorithms, simulate them locally, run them on real quantum hardware through cloud-based services, visualize and analyze their circuits and their output. Students will see practical examples of notorious algorithms, such as the mathematical optimization frameworks known as QUBO. They will also be introduced to error mitigation and correction techniques. At the end of the course, students will work on a project, aiming to consider real use cases and strengthen their capabilities in quantum computation.

## Editions

First Edition: March to April 2024

Second Edition: November to December 2024

Third Edition: March to April 2025

## Content

Each folder contains the slides and the code used in the corresponding lecture. Feel free to use them to learn and develop novel quantum algorithms!

Furthermore, we provide novel projects to further dive into the amazing world of quantum computing!

| Folder     | Topic                                       | PDF            | Example: File                                                                                                                                                                                                                                              | Time       |
|------------|---------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|
| Lecture 1  | Theory Recap on Quantum Computing           | [Lecture1.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%201/Lecture1.pdf)   | -                                                                                                                                                                                                                                                           | about 2 hrs|
| Lecture 2  | Initial Setup and first experiments         | [Lecture2.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%202/Lecture2.pdf)   | - Quantum Circuits 1: [lesson2_first_steps.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%202/lesson2_first_steps.mlx)<br>- Quantum Circuits 2: [lesson2_basic_examples.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%202/lesson2_basic_examples.mlx) <br>- Quantum Fourier Transform: [lesson2_qft.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%202/lesson2_qft.mlx) <br>- Quantum Teleportation: [lesson2_teleportation.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%202/lesson2_teleportation.mlx)                                                   | about 2 hrs|
| Lecture 3  | Grover's Algorithm                          | [Lecture3.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%203/Lecture3.pdf)   | - Graph Coloring: [lesson3.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%203/lesson3.mlx) (\*)                                                                                                                                                                                                                           | about 2 hrs|
| Lecture 4  | Combinatorial Optimization (QUBO)           | [Lecture4.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%204/Lecture4.pdf)   | - QUBO: [lesson4_basic_examples.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%204/lesson4_basic_examples.mlx)<br>- Feature Selection: [lesson4_fs.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%204/lesson4_fs.mlx) (\*) <br>- Traveling Salesperson Problem: [lesson4_tsp.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%204/lesson4_tsp.mlx) (\*) <br>- Capacitated Vehicle Routing Problem: [lesson4_cvrp.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%204/lesson4_cvrp.mlx) (\*)                                                       | about 2 hrs|
| Lecture 5  | VQE, QMC and QNN<br>Quantum Machine Learning| [Lecture5.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%205/Lecture5.pdf)   | - Variational Quantum Eigensolver: [lesson5_vqe.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%205/lesson5_vqe.mlx) (\*) <br>- Quantum Monte Carlo: [lesson5_qmc.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%205/lesson5_qmc.mlx) (\*) <br>- Quantum Neural Network for XOR problem: [lesson5_qnn.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%205/lesson5_qnn.mlx) (\*)                                                                                       | about 2 hrs|
| Lecture 6  | Quantum Error Correction and mitigation     | [Lecture6.pdf](https://github.com/necst/qc-with-matlab/blob/main/Lecture%206/Lecture6.pdf)   | - 9-Qubit Shor Code: [lesson6.mlx](https://github.com/necst/qc-with-matlab/blob/main/Lecture%206/lesson6.mlx)                                                                                                                                                                                                                            | about 2 hrs|
| PoliMi Students Projects   | MATLAB Quantum Computing Projects           | -              | - Milano Metro Stops: [Milano Metro Stops](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/Milano%20Metro%20Stops/Livescript.mlx)<br>- QAOA: [QAOA](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/QAOA/Exploring_QAOA.mlx)<br>- Bernstein-Vazirani: [Bernstein-Vazirani](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/BernsteinVazirani.mlx)<br>- Bernstein-Vazirani Attack: [Bernstein-Vazirani Attack](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/BVattack.mlx)<br>- QEC Repetition Codes: [QEC Repetition Codes](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/QEC_Repetition_Codes.mlx)<br>- QKD BB84: [QKD BB84](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/QKD_BB84.mlx)<br>- Shor's Algorithm: [Shor's Algorithm](https://github.com/necst/qc-with-matlab/blob/main/PoliMi%20Students%20Projects/Shor_Algorithm.mlx) | -          |

(\*) Based on MathWorks documentation or web sites.

For PoliMi Students Projects, credits to: Matteo Rossi, Giovanni Stanghellini, Pietro Lanna, Simone Pellegatta, Giulia Blanchetti, Marco Venere

Every Live Script has been executed with MATLAB R2024b. 

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=necst/qc-with-matlab&file=readme_table.mlx)

## Acknowledgements

A special thanks to MathWorks, which has supported the Quantum Computing with MATLAB Curriculum Development Project.

## Contacts

In case you have any doubts, feel free to reach out:

Marco Venere - marco.venere@polimi.it
