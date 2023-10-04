enum CameraPosition {
  front,
  back,
}

class Camera {
  bool cameraAccess;
  CameraPosition cameraPosition;

  Camera(this.cameraAccess, this.cameraPosition);
}

var SAMPLE_CAMERAS = [
  Camera(true, CameraPosition.back),
  Camera(false, CameraPosition.front),
];
