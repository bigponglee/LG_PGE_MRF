# LG_PGE_MRF

A simple implementation of the LG-PGE for MRF reconstruction: "Improved MRF Reconstruction via Structure-Preserved Graph Embedding Framework"

# Files
* 'data': contains the demo data
* 'utils': utility functions
* 'py_func': python functions for NUFFT
* 'main_vds_spiral_LGPGE.m': the main file for the LG-PGE method

# Requirements
* [torchkbnufft](https://github.com/mmuckley/torchkbnufft)
* PyTorch >=1.13.0
* numpy
* scipy
* matlab

# Demo
* Prepare your development environment by installing the required packages
* run the 'main_vds_spiral_LGPGE.m' file in MATLAB

# Citation
If you find this code useful, please cite the following paper:
```
@ARTICLE{10720657,
  author={Li, Peng and Ji, Yuping and Hu, Yue},
  journal={IEEE Transactions on Image Processing}, 
  title={Improved MRF Reconstruction via Structure-Preserved Graph Embedding Framework}, 
  year={2024},
  volume={33},
  number={},
  pages={5989-6001},
  keywords={Image reconstruction;Manifolds;Fingerprint recognition;Estimation;Accuracy;Optimization;Magnetic resonance imaging;Data acquisition;Computational complexity;Coils;MRF;graph embedding;manifold learning;Laplacian eigenmaps},
  doi={10.1109/TIP.2024.3477980}}
```
