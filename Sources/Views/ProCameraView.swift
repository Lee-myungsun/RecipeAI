import SwiftUI
import AVFoundation

struct ProCameraView: UIViewControllerRepresentable {
  @Binding var capturedImage: UIImage?
  @Environment(\.dismiss) var dismiss

  func makeUIViewController(context: Context) -> CameraViewController {
    let vc = CameraViewController()
    vc.onCapture = { image in
      capturedImage = image
      dismiss()
    }
    vc.onDismiss = {
      dismiss()
    }
    return vc
  }

  func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
  var captureSession: AVCaptureSession?
  var previewLayer: AVCaptureVideoPreviewLayer?
  var photoOutput: AVCapturePhotoOutput?
  var videoDevice: AVCaptureDevice?
  var flashMode: AVCaptureDevice.FlashMode = .auto
  var flashButton: UIButton?
  var zoomLabel: UILabel?
  var lastZoomFactor: CGFloat = 1.0

  var onCapture: ((UIImage) -> Void)?
  var onDismiss: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupCamera()
    setupUI()
    setupGestures()
  }

  private func setupCamera() {
    captureSession = AVCaptureSession()
    captureSession?.sessionPreset = .photo

    guard let captureSession = captureSession else { return }

    videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    guard let videoDevice = videoDevice, let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

    if captureSession.canAddInput(videoInput) {
      captureSession.addInput(videoInput)
    }

    photoOutput = AVCapturePhotoOutput()
    if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
      captureSession.addOutput(photoOutput)
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer?.videoGravity = .resizeAspectFill
    previewLayer?.frame = view.bounds
    if let previewLayer = previewLayer {
      view.layer.addSublayer(previewLayer)
    }

    DispatchQueue.global(qos: .userInitiated).async {
      captureSession.startRunning()
    }
  }

  private func setupUI() {
    let closeButton = UIButton(type: .system)
    closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
    closeButton.tintColor = .white
    closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    closeButton.layer.cornerRadius = 22
    closeButton.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(closeButton)

    flashButton = UIButton(type: .system)
    flashButton?.tintColor = .white
    flashButton?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    flashButton?.layer.cornerRadius = 22
    flashButton?.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    flashButton?.translatesAutoresizingMaskIntoConstraints = false
    if let flashButton = flashButton {
      view.addSubview(flashButton)
    }
    updateFlashButton()

    zoomLabel = UILabel()
    zoomLabel?.text = "1x"
    zoomLabel?.textColor = .white
    zoomLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    zoomLabel?.textAlignment = .center
    zoomLabel?.layer.cornerRadius = 22
    zoomLabel?.layer.masksToBounds = true
    zoomLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    zoomLabel?.translatesAutoresizingMaskIntoConstraints = false
    if let zoomLabel = zoomLabel {
      view.addSubview(zoomLabel)
    }

    let captureButton = UIButton(type: .system)
    captureButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
    captureButton.tintColor = .white
    captureButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    captureButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(captureButton)

    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      closeButton.widthAnchor.constraint(equalToConstant: 44),
      closeButton.heightAnchor.constraint(equalToConstant: 44),

      flashButton!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      flashButton!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      flashButton!.widthAnchor.constraint(equalToConstant: 44),
      flashButton!.heightAnchor.constraint(equalToConstant: 44),

      zoomLabel!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      zoomLabel!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      zoomLabel!.widthAnchor.constraint(equalToConstant: 44),
      zoomLabel!.heightAnchor.constraint(equalToConstant: 44),

      captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
    ])
  }

  private func setupGestures() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    view.addGestureRecognizer(pinchGesture)
  }

  @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
    guard let device = videoDevice else { return }

    do {
      try device.lockForConfiguration()
      defer { device.unlockForConfiguration() }

      let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
      let newZoomFactor = lastZoomFactor * gesture.scale
      let clampedZoomFactor = max(1.0, min(newZoomFactor, maxZoom))

      device.videoZoomFactor = clampedZoomFactor
      lastZoomFactor = clampedZoomFactor

      let zoomValue = String(format: "%.1fx", clampedZoomFactor)
      zoomLabel?.text = zoomValue

      gesture.scale = 1.0
    } catch {
      print("카메라 줌 설정 실패: \(error)")
    }
  }

  @objc private func toggleFlash() {
    let modes: [AVCaptureDevice.FlashMode] = [.off, .on, .auto]
    if let currentIndex = modes.firstIndex(of: flashMode) {
      flashMode = modes[(currentIndex + 1) % modes.count]
    }
    updateFlashButton()
  }

  private func updateFlashButton() {
    let imageName: String
    switch flashMode {
    case .off:
      imageName = "bolt.slash.fill"
    case .on:
      imageName = "bolt.fill"
    case .auto:
      imageName = "bolt"
    @unknown default:
      imageName = "bolt"
    }
    flashButton?.setImage(UIImage(systemName: imageName), for: .normal)
  }

  @objc private func capturePhoto() {
    guard let photoOutput = photoOutput else { return }

    var photoSettings = AVCapturePhotoSettings()
    photoSettings.flashMode = flashMode

    photoOutput.capturePhoto(with: photoSettings, delegate: self)
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
    onCapture?(image)
  }

  @objc private func closeCamera() {
    if let session = captureSession, session.isRunning {
      session.stopRunning()
    }
    onDismiss?()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let session = captureSession, session.isRunning {
      session.stopRunning()
    }
  }
}
