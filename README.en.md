# 🚀 DRFF-R1 Dataset Description

## Language Selection
- [English](README.en.md)
- [中文](README.md)

## 1. Equipment Introduction

### 1. Drones and Flight Controllers  
This dataset uses DJI drones and their flight control systems, covering 20 drones across 7 models:  
- 1 × Mavic Mini  
- 1 × Mavic Air  
- 1 × Mavic 3  
- 3 × Mini SE  
- 3 × Mini 3 Pro  
- 5 × Mavic Air 2  
- 6 × Mavic Air 2S  

### 2. RF Signal Receiver  
The RF signal reception device is the USRP-B210 from Ettus Research. Key specifications:  
- Frequency range: 70 MHz - 6 GHz  
- 2 TX / 2 RX channels  
- Maximum instantaneous bandwidth: 56 MHz  
- Signal gain: 0-90 dB  
- Maximum I/Q sampling rate: 61.44 MS/s  

### 3. Data Cable  
The data cable connecting the host and USRP is an E164571-KS AWM 2725, supporting up to 5 GB/s transfer rate with latency <10 ms.  

### 4. Host Computer  
The host runs Windows 11 with an Intel(R) Core(TM) i5-13450HX CPU, 16 GB RAM, and a 2 TB portable HDD for storage.  
A GNU Radio environment is installed to drive the USRP for signal acquisition and data I/O.  

## 2. Dataset  

### Naming Convention  
Taking `mini_3pro_1_0.mat` as an example:  
- `mini_3pro`: Drone model  
- `1`: The 1st drone of this model  
- `0`: Collection distance  
  - `0`: Baseline signal in an anechoic chamber (no EMI)  
  - `10`, `30`, `50`, `70`, `90`: Hovering distances (meters)  

### Dataset Content  
Each `.mat` file contains:  
- 140 million In-phase (I) and Quadrature (Q) signal samples  
- Sampling frequency (`Fs`)  
- Center frequency (`CenterFreq`)  

For detailed collection workflow, refer to `collect.py`.  

### Data Collection Strategy  
During the actual signal acquisition process, we simultaneously collected RF signals from real environments and reference signals with low channel-effect interference. Specifically:

- Control the drone to hover at different altitudes (10m/30m/50m/70m/90m) while keeping both the receiver and flight controller stationary, collecting RF signals without Doppler effects in the actual environment.

- To eliminate multipath effects caused by environmental reflections in real scenarios, we placed the USRP receiver, normally connected drone, and flight controller together inside microwave-absorbing foam for signal acquisition (the foam effectively absorbs electromagnetic waves in the 5-6 GHz band with reflection attenuation >30 dB).

  ![absorb](images/absorb.jpg)  

📌 **Tips:**  
When using the dataset:  
- Signals collected under microwave-absorbing foam wrapping (marked as 0m distance data files) can serve as reference signals, which are unaffected by multipath and Doppler effects.  
- You can superimpose different channel models (e.g., Rayleigh fading, multipath delay) on this reference signal through simulation to construct training datasets for complex scenarios.  
- RF signals from real environments (marked with distances ≥10m) can directly validate models in real-world scenarios.  

## 3. Collection Workflow  

Two operators are required: Operator A controls the drone, Operator B manages the host.  

1. **Operator A**:  
   - Powers on the drone near the host and places it in standby mode, connecting to a calibrated remote controller or mobile app.  
   - Maintains drone hovering at specified distances (anechoic chamber, 10m, 30m, 50m, 70m, 90m), with real-time distances monitored via the app.  

2. **Operator B**:  
   - Executes Python scripts to connect the host with USRP-B210 via the data cable.  
   - Configures default parameters:  
     - Sampling rate: 40 MS/s  
     - Center frequency: 5.745 GHz (all drones manually set to Channel 149 for consistency across OcuSync 2.0/3.0 variants)  
     - Gain: 30 dB  
     - Bandwidth: 20 MHz  
   - Collects 140 million samples per file, labels files following naming rules, and verifies data integrity.  
   - Signals Operator A to land the drone after completion, then repeats for other drones.  

- **Schematic**:  

![Collection Schematic](images/collect.png)  

---  

## 4. Data Visualization  

### Plotting Amplitude and Time-Frequency Diagrams  
To visualize amplitude plots and spectrograms, modify the file path in `plot.py`:  
```matlab  
data = load('./mini_se_3_0.mat');  
```
### Mini SE 3 
- **I/Q Amplitude Graph and Time-Frequency Graph of data acquired under RF signal wave-absorbing cotton wrapping**

![Mavic Air 2S 1 I/Q 振幅图](images/Mini_SE_3_0.png) 

---
