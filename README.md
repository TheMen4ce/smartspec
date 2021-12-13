# smartspec
Smartspec enables you to measure and analyse the spectrum of visible light between 400 and 700 nm. The product consists of two parts: Part one is a 3D-printed attachment, containing a lens and a diffraction grating. Part two is an iOS app, that analyses and presents the measurements.

## How it works
Light can enter through a slit on the front of the attachment. It passes a collimator lens and then onto a diffraction grating. When properly placed infront of a smartphones camera, an image (rainbow image) showing all the colors, contained in the light that has entered the slit, will appear on the camera feed. If no image is visible, the image appears blurry or to dim, one must adjust the camera exposure parameters within the app. As a next step, the measurement area, represented by a red rectangle, must be configured. Optimally, the rectangle covers the whole length of the rainbow image with a little extra border. As a last step, the measurements can be calibrated using a light source with known peaks (i.e. a fluorescent lamp). For an accurate calibration, as needed in the last two steps, one can pause the recording of the rainbow image using the ⏯ button.

### Screenshots

Here are some screenshots of the app in action. There are also screenshots comparing the app's measurement against an Avantes Starline spectrometor, using different sources of light.

https://drive.google.com/drive/folders/16mSd4CBgMBkTzHsSgzzSJmglhCX4PrbJ

## Attachment
The attachment can be 3D printed using our design here:

You may create your own design and choose a different way of manufacturing.

### Possible Improvements

- The current version of the design requires a specific hull for each type of iOS-device. A universal mount would be desirable. 
  - Difficulties achieving this were, to create a light proof attachment, that sticks to the device without moving (a different position of the attachment would require recalibration).

## App

### Build

- Clone this repo
- Install dependencies via Cocoapods
- Open the `.workspace` file using the latest version of Xcode

### Possible Improvements

- Relative Intesity
  - The intensity is not weightet linearly
    - Tests with a high quality and calibrated spectrometer would be required to determine the weighting of the pixel brightness.
    - Hint: chaning the y-axis of the reference spectrometer to log scale might help to understand how this is done
- Absolute Intesity
  - Detailed tests would be needed to analyse if absolute intensity can be measured. This might be possible when combining the pixel intesities with the cameras exposure parameters. 
- Spectrograph
  - Add axis descriptions to the spectrometer plot
    - At the time of writing the app, the Charts iOS library had no functionality to set axis descriptions
    
### Known Issues

- Each tap on the buttons for ISO or exposure euration (aka. time) will in- or decrease the value by 10%), this can make adjustments sometimes tedious. If it would take up too much time to reset exposure using the buttons, one can always just delete reinstall the app.
