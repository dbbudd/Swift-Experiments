
import PlaygroundSupport
import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController{
    
    let motionManager = CMMotionManager()
    let cameraNode = SCNNode()
    let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
    let scene = SCNScene()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: -200, width: 800, height: 1200)
        view.backgroundColor = .black
        
        sceneView.backgroundColor = .clear
        sceneView.scene = scene
        sceneView.center = view.center
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = true
        
        view.addSubview(sceneView)
        
        
        //Create a node containing a sphere, using the panoramic image as a texture
        let sphere = SCNSphere(radius: 60.0)
        
        sphere.firstMaterial!.isDoubleSided = true
        
        let image = #imageLiteral(resourceName: "cover.png")
        sphere.firstMaterial!.diffuse.contents = image
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
        
        //Create a camera node which will be the view of the user
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(5,-10,20) //adjust to fit your image
        scene.rootNode.addChildNode(cameraNode)
        
        //Control with CoreMotion
        let motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1.0
        motionManager.startDeviceMotionUpdates(to: .main, withHandler: handleMove)
    }
    
    func handleMove(motion: CMDeviceMotion?, error: Error?){
        guard let data = motion else {return}
        let attitude: CMAttitude = data.attitude
        self.cameraNode.eulerAngles = SCNVector3Make(Float(attitude.roll - Double.pi/2.0), Float(attitude.yaw), Float(attitude.pitch))
    }
    
}

PlaygroundPage.current.liveView = ViewController()
