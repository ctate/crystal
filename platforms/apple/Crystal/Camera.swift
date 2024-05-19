import AVFoundation

func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: // The user has previously granted access to the camera.
        completion(true)

    case .notDetermined: // The user has not yet been asked for camera access.
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }

    case .denied: // The user has previously denied access.
        completion(false)

    case .restricted: // The user can't grant access due to restrictions.
        completion(false)

    @unknown default:
        completion(false)
    }
}
