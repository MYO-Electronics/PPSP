This repository contains the code for the manuscript “Noninvasive Extraction of Maternal and Fetal Electrocardiograms Using Progressive Periodic Source Peel-off”, currently under review at IEEE Transactions on Instrumentation and Measurement.

## Project Structure
| Main File / Function | Description |
|---|---|
| `main` | Main script of the project |
| `FecgImpArtCanc` | Removes impulse artifacts |
| `FecgDetrFilt` | Applies low-pass filtering |
| `FecgNotchFilt` | Applies notch filtering |
| `FecgICAm` | Performs ICA-based independent component analysis |
| `FecgInterp` | Performs signal interpolation |
| `FecgQRSmDet` | Detects maternal ECG |
| `FecgQRSmCanc` | Removes maternal ECG using SVD |
| `derivative` | Differential filtering |
| `yanchibaihua3` | Signal delay and whitening |
| `FecgICAf` | Performs ICA-based independent component analysis |
| `dis_spike` | Removes duplicated independent components |
| `getspike` | Extracts fetal activation sequences using thresholding and clustering |
| `cfICA` | PCFICA implementation |
| `FecgQRSfDet` | Detects fetal ECG |
| `evaluation` | Evaluates activation detection performance, including acc, sen, ppv, and F1 |

## Usage
1. Open MATLAB and add the project folder to the MATLAB path.
2. Prepare the input data and install the required data loading tools (e.g., the WFDB Toolbox).
   An example input data is provided, but WFDB toolbox is still needed to read the data.
   The WFDB Toolbox for MATLAB can be downloaded from:
   https://physionet.org/content/wfdb-matlab/
   Please follow the official instructions to install and configure the toolbox.
3. Place the input data in the same directory as the code, and modify the data loading way in the main script.
4. Run the `main` function to execute the full pipeline.
5. Obtain the fetal R-peak sequence.
6. Obtain the evaluation metrics for QRS complex extraction.
