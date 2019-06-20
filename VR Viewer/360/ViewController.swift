import UIKit
import ARKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    var player: AVPlayer!
    
    @IBAction func addItem(_ sender: Any) {
        //Show options for the source picker only if camera is available
        //checkPermission()
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //HANDLING IMAGE PICKER
    //some reason adding explicit Objective-C reference suppresses error
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //Get Video URL
        let videoURL: NSURL? = info["UIImagePickerControllerReferenceURL"] as? NSURL
        
        player = AVPlayer(url: videoURL! as URL)
        self.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:
            self.player.currentItem, queue: .main, using: { (notification) in
                self.player.seek(to: CMTime.zero)
                self.player.play()
        })
        
        //Add Sphere to Scene
        let sphere = SCNSphere(radius: 60.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = player
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.simdTransform = cameraTransform(z: 0, sideOffset: 0)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        //Play video
        player.play()
    }
    
    func cameraTransform(z: Float, sideOffset: Float = 0) -> simd_float4x4 {
        guard let currentFrame = sceneView.session.currentFrame else { return matrix_identity_float4x4}
        var translation = matrix_identity_float4x4
        translation.columns.3.z = z
        translation.columns.3.x += sideOffset // ( Works with y when in portrait)
        return matrix_multiply(currentFrame.camera.transform, translation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}


extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("Node did update")
        if node.isHidden {
            player.pause()
        } else if player.rate == 0 {
            player.play()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Did add Node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        print("Asked for a node")
        
        return node
    }
    
}



extension ViewController: ARSessionDelegate {
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            print("Limited Tracking")
        case .normal:
            print("Normal Tracking")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        print("Session Failed \(errorMessage)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Need to restart")
       // restartExperience()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }

    
}
