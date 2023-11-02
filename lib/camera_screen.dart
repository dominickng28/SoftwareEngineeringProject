enum CameraPosition {
  front,
  back,
}

class Camera {
  bool cameraAccess;
  CameraPosition cameraPosition;

  Camera(this.cameraAccess, this.cameraPosition);
}

var sampleCameras = [
  Camera(true, CameraPosition.back),
  Camera(false, CameraPosition.front),
];
