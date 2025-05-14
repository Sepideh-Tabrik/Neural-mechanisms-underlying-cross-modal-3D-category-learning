# Neural-mechanisms-underlying-cross-modal-3D-category-learning
Humans use visual and tactile sensory systems interchangeably for object recognition on a daily basis. This human ability brings up three main questions, which have not been fully answered. Will there be a cross-modal transfer between the visual and tactile modalities involved in object categorization? Which brain areas are involved in the cross-modal transfer of category information? How does visual/tactile object categorization learning induce brain plasticity? To answer these question we designed an experiment using a new set of stimuli which called "digital embryo" i combination with resting-state and task0based functional MRI. 

# Experiment Design
A task-based fMRI experiment studied 84 naïve participants divided into four groups—two cross-modal (Visual-Tactile, Tactile-Visual) and two unimodal (Visual-Visual, Tactile-Tactile)—to investigate visual and tactile categorization. On Day 1, participants underwent category learning training outside the scanner (visual: ~60 min in Virtual Reality; tactile: ~75 min with 3D-printed objects), achieving 85% accuracy. On Day 2, testing occurred inside a 3T MRI scanner, with visual stimuli presented as 4-second rotating object videos and tactile stimuli explored via wrist/finger movements, each involving five 32-trial runs. Training used 8 primed objects (4 per category), while testing included all 16 objects (primed and non-primed) to assess categorical knowledge transfer. In addition, resting-state data were recorded at 4 time points: pre- and post-training, pre- and post-test sesions.

More detaile ar available here: https://hss-opus.ub.ruhr-uni-bochum.de/opus4/frontdoor/deliver/index/docId/9089/file/diss.pdf 
![image](https://github.com/user-attachments/assets/87e7adf3-8ded-466e-a3d0-4b3740604e77)


# Data Acquisition
High-resolution anatomical images for EPI-distortion correction were obtained via a T1-weighted MPRAGE sequence with following parameters: repetition time (TR) = 8.2 ms, echo time (TE) = 3.8 ms, voxel size = 1 × 1 × 1 mm³, field of view (FOV) = 240 × 240 × 220 mm³, flip angle = 90°. Task-based functional data were collected using a T2*-weighted single-shot EPI sequence (TR = 2 s, TE = 24 ms, voxel size = 2 × 2 × 3 mm³, FOV = 224 × 224 × 125 mm³, flip angle = 80°, 38 transverse slices, slice thickness = 3 mm, inter-slice gap = 0.3 mm, multiband acceleration factor = 2). rs-fMRI data were acquired pre- and post-training on Day 1, and pre- and post-test on Day 2, using an EPI sequence (TR = 2.5 s, TE = 35 ms, flip angle = 90°, 39 slices, no gap, FOV = 224 × 224 × 117 mm³, voxel size = 2 × 2 × 3 mm³). 

# fMRI Data Preprocessing Peipline
 All  neuroimaging data (task-based and resting-state) were processed using a suite of tools, including FMRIB Software Library (FSL, v6.0.5.1, https://fsl.fmrib.ox.ac.uk/fsl/docs/#/), Analysis of Functional NeuroImages (AFNI, v20.0.09, https://afni.nimh.nih.gov/), Advanced Normalization Tools (ANTs, https://github.com/ANTsX/ANTs), and FreeSurfer (v7.1.1, Harvard University, Boston, MA, USA, https://surfer.nmr.mgh.harvard.edu/). 

# fMRI Preprocessing Pipeline

This guide outlines the preprocessing steps for task-based and resting-state fMRI data from the similarity rating task dataset, using tools like FSL, AFNI, FreeSurfer, ANTs, and ICA-AROMA. Below are the step-wise procedures, including the function or tool to run each step.

## Task-Based fMRI Preprocessing

1. **Convert DICOM to NIfTI**
   - **Function**: `dcm2niix`
   - Convert raw DICOM files to NIfTI format for compatibility with neuroimaging tools.
2. **Assess Data Quality (Framewise Displacement)**
   - **Function**: `fsl_motion_outliers` (FSL)
   - Calculate framewise displacement (FD) from rigid-body realignment estimates to identify motion-affected volumes.
3. **Skull-Strip Anatomical Images**
   - **Function**: `recon-all` (FreeSurfer)
   - Remove skull and non-brain tissue from anatomical (T1) images.
4. **Motion Correction**
   - **Function**: `MCFLIRT` (FSL)
   - Correct motion-related artifacts in fMRI time series by aligning volumes to a reference.
5. **Remove Non-Brain Tissue from fMRI**
   - **Function**: Manual or BET (FSL)
   - Remove non-brain tissue from fMRI data to focus on brain signals.
6. **Spatial Smoothing**
   - **Function**: `3dBlurInMask` (AFNI)
   - Apply a 5 mm FWHM Gaussian filter to smooth fMRI data within a brain mask.
7. **Global Intensity Normalization**
   - Normalize global intensity to a grand mean of 10,000 across sessions for group analysis.
8. **Clean Motion Artifacts**
   - **Function**: `ICA-AROMA` (version 0.3beta) https://github.com/maartenmennes/ICA-AROMA
   - Remove in-scanner head motion artifacts using independent component analysis.
9. **Temporal High-Pass Filtering**
   - **Function**: `3dTproject` (AFNI)
   - Apply high-pass filtering (>0.01 Hz) to remove low-frequency noise post-ICA-AROMA.

10. **Discard Non-Steady-State Volumes**
    - **Function**:  `fslroi`
    - Remove the first and last five volumes to ensure steady-state data and minimize filtering artifacts.
11. **Register EPI to Structural**
    - **Function**: `epi_reg` (FSL, BBR)
    - Register EPI (fMRI) images to high-resolution structural (MPRAGE) images using boundary-based registration.
12. **Register Structural to MNI Template**
    - **Function**: `antsRegistrationSyN.sh` (ANTs)
    - Register structural images to the MNI152_T1_2mm template using nonlinear Symmetric Normalization (SyN).
13. **Concatenate Transformations**
    - **Function**: `antsApplyTransforms` (ANTs)
    - Combine BBR and SyN transformations to warp fMRI data to MNI space.

## Resting-State fMRI Preprocessing
The resting-state fMRI preprocessing follows the task-based pipeline (Steps 1–13) with the following additional or modified steps:

1. **Convert DICOM to NIfTI**
2. **Assess Data Quality (Framewise Displacement)**
3. **Skull-Strip Anatomical Images**
4. **Motion Correction**
5. **Slice-Timing Correction**
   - **Function**: `slicetimer` (FSL)
   - Correct for interleaved ascending acquisition timing, using the middle slice as reference.
6. **Remove Non-Brain Tissue from fMRI**
7. **Spatial Smoothing**
8. **Global Intensity Normalization**
9. **Clean Motion Artifacts**
10. **Segment Structural Images**
    - **Function**: `fast` (FSL)
    - Segment structural images into grey matter, white matter (WM), and cerebrospinal fluid (CSF) masks.
11. **Binarize WM and CSF Masks**
    - **Function**: `fslmaths` (FSL)
    - Binarize WM and CSF masks at a 0.95 threshold to prevent overlap.
12. **Regress Nuisance Signals**
    - **Function**: `fslregfilt` (FSL)
    - Regress mean WM, CSF, and global signals from each voxel’s time series.
13. **Temporal Bandpass Filtering**
    - **Function**: `3dTproject` (AFNI)
    - Apply bandpass filtering (0.01–0.1 Hz) to isolate resting-state frequencies.
14. **Discard Non-Steady-State Volumes**
15. **Register EPI to Structural**
16. **Register Structural to MNI Template**
17. **Concatenate Transformations**

## Notes
- **Dataset**: (please provide the correct link).
- **Motion Exclusion**: Participants listed in Table 1 were excluded due to excessive motion (FD > 0.9 mm).
- **Multiband Data**: Slice-timing correction was skipped for task-based fMRI due to multiband acquisition.
- **Dependencies**: Ensure FSL, AFNI, FreeSurfer, ANTs, and ICA-AROMA (version 0.3beta) are installed.

