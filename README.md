# noise-navigator
This Matlab code can be used to calculate the noise navigator shown in these articles:

R.J.M. Navest, A. Andreychenko, J.J.W. Lagendijk, and C.A.T. van den Berg, “Prospective
Respiration Detection in Magnetic Resonance Imaging by a Non-Interfering
Noise Navigator“, IEEE Transactions on Medical Imaging 2018;37(8):1751-1760,
[doi:10.1109/TMI.2018.2808699](http://dx.doi.org/10.1109/TMI.2018.2808699);

R.J.M. Navest, S. Mandija, A. Andreychenko, A.J.E. Raaijmakers, J.J.W. Lagendijk,
and C.A.T. van den Berg, “Understanding the physical relations governing
the noise navigator“, Magnetic Resonance in Medicine 2019;82(6):2236-2247,
[doi:10.1002/mrm.27906](http://dx.doi.org/10.1002/mrm.27906);

R.J.M. Navest, S. Mandija, T. Bruijnen, B. Stemkens, R.H.N Tijssen, A. Andrey-
chenko, J.J.W. Lagendijk, and C.A.T. van den Berg, “The noise navigator: a sur-
rogate for respiratory-correlated 4D-MRI for motion characterization in
radiotherapy“, Physics in Medicine & Biology 2020;65(1):01NT02, [doi:10.1088/13616560/ab5c62](http://dx.doi.org/10.1088/1361-6560/ab5c62);

The "demo_noise_navigator" script shows a respiratory motion detection example for a 2D balanced steady-state free precession cine MRI acquisition acquired at a 1.5T hybrid MRI-linac system. Due to size limitations, the data was uploaded for the individual RF receive channels separately and combined again in the script.

**Function overview** in order of appearance
1. *noiseCoVar_git* requires the raw MRI (i.e. k-space) data in the format [kx, profiles, channels]. The second input needed is the FOV for the MRI data that contains anatomy (the bore has a diameter of 700 mm and thus everything outside 720 mm is considered thermal noise as there cannot be any anatomy). The output is the thermal noise (co)variance calculated per profile, corresponding time vector and the number of thermal noise samples per profile used to calculate the thermal noise (co)variance.
2. *fourierCoeff* calculates the frequency spectrum of the input data.
3. *Kalman_IEEE_legacy* applies the Kalman filter described in the IEEE article mentioned above to the thermal noise variance combined for all RF receive channels.
4. *MovingAverage_legacy* applies a moving average filter with a certain window length to the thermal noise variance combined for all RF receive channels.

For questions or suggestions feel free to message me at robin.navest@gmail.com
