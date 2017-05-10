# VisionText

VisionText is Optical Character Recognition Software. It uses OpenCV and Tesseract libraries. It performs image preprocessing (sharpening, thresholding, deskewing and text areas detection).

### Installation

You should have following environment variables properly set: 
- OpenCV_DIR
- Tesseract_DIR
- Leptonica_DIR

Keep in mind paths should containt LibraryConfig.cmake or cmake/LibraryConfig.cmake (e.g TesseractConfig.cmake).

### Building

```sh
$ mkdir build && cd build
$ cmake ..
```