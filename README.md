# VisionText

VisionText is Optical Character Recognition Software. It uses OpenCV and Tesseract libraries. It performs image preprocessing (sharpening, thresholding, deskewing and text areas detection).

### Installation

You should have following environment variables properly set: 
- OpenCV_DIR
- Tesseract_DIR (OPTIONAL)
- Leptonica_DIR (OPTIONAL)

Keep in mind paths should contain LibraryConfig.cmake or cmake/LibraryConfig.cmake (e.g TesseractConfig.cmake).

When Leptonica or Tesseract library are not installed, projects will be cloned and added as build dependency. OpenCV is huge library and there is no such option supported.

### Building

```sh
$ mkdir build && cd build
$ cmake ..
```