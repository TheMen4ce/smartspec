# <img src="https://user-images.githubusercontent.com/9498649/146215803-dd18db5a-b3cd-41f4-bac9-14f903ea040a.png" alt="App Logo" width="50"> SmartSpec 

SmartSpec enables you to measure and analyze the spectrum of visible light between 400 and 700 nm. SmartSpec consists of two parts: Part one is a 3D-printed attachment, containing a lens and a diffraction grating. Part two is an iOS app, that analyzes the camera feed and draws the light's spectrum as a chart.

This app was developed as a proof of concept. Use at your own risk.

Additional resources may be found in [Google Drive](https://drive.google.com/drive/folders/16mSd4CBgMBkTzHsSgzzSJmglhCX4PrbJ).

## How it works
Light can enter through a slit on the front of the attachment. It passes a collimator (bi-convex lens) and then onto a diffraction grating. When properly placed in front of a smartphone camera, a rainbow image (see figure 1) will appear on the camera feed. The image will show all colors contained in the light that has entered the slit. If no image is visible, the image appears blurry or if it is too dim, one must adjust the camera exposure parameters within the app. As a next step, the measurement area, represented by a red rectangle, must be configured. Optimally, the rectangle covers the whole length of the rainbow image with a little extra border. As a last step, the measurements can be calibrated using a light source with known peaks (i.e. a fluorescent lamp). For an accurate calibration, as needed in the last two steps, one can pause the recording of the rainbow image using the ⏯ button.

The rainbow image from the measurement area is transformed to grayscale. The intensity (y-axis in chart) per wavelength will be determined using the respective pixel intensities. The highest measured intensity will be valued as 1 and all others linearly interpolated. The wavelength (x-axis in the chart) is determined using the calibration profile.

|<img src="https://user-images.githubusercontent.com/9498649/146216255-d32a3adc-07c3-4875-b36f-04f52aa79d2c.png" alt="App Logo" width="200">|
|:--:| 
| *Figure 1: Rainbow image of helium in a Geissler tube* |

## Attachment
Various designs for the attachment were tested. An overview of all prototypes can be found [here](https://drive.google.com/drive/folders/1DWJv5h9o8yy3NQZ4DcujevpgTq_-FJ-x). Photos of the final version of the attachment, including CAD files and parts list can be found [here](https://drive.google.com/drive/folders/1DzFAv5CVy-1VjNU017G60a6Jj6LDTuvg).

One may create its own design and choose a different way of manufacturing.

### Possible Improvements

- The latest version of the attachment requires a specific hull for each type of iOS-device. A universal mount would be desirable. 
  - The difficulties in achieving this were to create a light proof attachment, that sticks to the device without moving (a different position of the attachment would require recalibration).

## App

### How To Use

Figure 2 shows the app in actions and describes its features. All actions taken in the application are automatically saved.

1. Set correct exposure
2. Define Measurement Area
3. Calibrate using a light source with known peaks in the spectrum (i.e. [fluorescent lamp](https://drive.google.com/drive/folders/1BVUgVgZY0KLDFgdixcMHBynbQrfPUubC))
4. The background shows the whole camera image
5. Measurement area enlarged and rotated by 90°
6. Graph showing the spectrum of the light source
7. ⏯ button. Will freeze the image whilst still allowing calibration or adjusting the measurement area

|<img src="https://user-images.githubusercontent.com/9498649/146218854-2e0cfe8a-6074-49e7-a181-990bfd30aa4a.png" alt="App Logo" width="200">|
|:--:| 
| *Figure 2: App analyzing the spectrum of a light source created by helium in a Geissler tube* |

### Screenshots

[Here](https://drive.google.com/drive/folders/18nqb-3rSZPpuWuw9ToOiApIVMvF7Rc9W) are some screenshots of the app in action. There are also screenshots comparing the app's measurement against an Avantes Starline spectrometer, using different sources of light.

### Build

#### Prerequisites

- Xcode > 13
- Cocoapods > 1.11.2

#### Instructions

- Clone or download this repository
- Install dependencies via Cocoapods
- Open the `.workspace` file using the latest version of Xcode

### Possible Improvements

- Relative Intensity
  - The intensity is not weighted linearly
    - Tests with an accurate and calibrated spectrometer would be required to determine the correct weighting of the pixel brightness.
    - Hint: changing the y-axis of the reference spectrometer to log scale might help to understand how this is done
- Absolute Intensity
  - Detailed tests would be needed to analyze if absolute intensity can be measured. This might be possible when combining the pixel intensities with the cameras exposure parameters.
- Resolution
  - When analysing a light source with very narrow peaks or peaks appearing very close together they might not be represented correctly in the spectrograph. The resolution could be improved by using a better attachment and by "tuning" the camera image.
    - Tests would require an accurate and calibrated spectrometer with a high resolution
- Spectrograph
  - Missing axis descriptions in the spectrum plot
    - At the time of writing the app, the Charts iOS library had no functionality to set axis descriptions
    
### Known Issues

- Each tap on the buttons for ISO or exposure duration (aka. time) will in- or decrease the value by 10%), this can make adjustments sometimes tedious. If it would take up too much time to reset exposure using the buttons, one can always just delete reinstall the app.
