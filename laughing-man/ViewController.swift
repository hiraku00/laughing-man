import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // ユーザーが選択するオプションを追加
    var option: String = "OFF"
    
    // UISegmentedControlを追加
    let segmentedControl: UISegmentedControl = {
        let items = ["OFF", "laughing-man", "mosaic", "kabuki"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return sc
    }()
    
    // シャッターボタンを追加
    let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shutter", for: .normal)
        button.backgroundColor = UIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 60) // ボタンのサイズを設定
        button.addTarget(self, action: #selector(handleShutter), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSegmentChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            option = "OFF"
        case 1:
            option = "laughing-man"
        case 2:
            option = "mosaic"
        case 3:
            option = "kabuki"
        default:
            break
        }
        // セッションをリセットして新しいオプションを反映
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func handleShutter() {
        let snapshot = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UISegmentedControlを画面上部に配置
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // シャッターボタンを画面下部に配置
        view.addSubview(shutterButton)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 200).isActive = true // ボタンの幅を設定
        shutterButton.heightAnchor.constraint(equalToConstant: 60).isActive = true // ボタンの高さを設定
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARFaceAnchor && option != "OFF" {
            if option == "kabuki" {
                let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
                let node = SCNNode(geometry: faceMesh)
                node.geometry?.firstMaterial?.fillMode = .fill
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "kabuki.jpeg")
                node.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,1,1) // 画像のスケーリングを調整
                return node
            } else {
                // 顔の大きさと位置に合わせて平面を作成します
                var plane = SCNPlane(width: 0.1, height: 0.1)
                var opacity = 1.0 // 透明度
                if option == "laughing-man" {
                    // 3倍
                    plane = SCNPlane(width: 0.3, height: 0.3)
                    plane.firstMaterial?.diffuse.contents = UIImage(named: "Laughing_man.png")
                } else if option == "mosaic" {
                    // 2倍
                    plane = SCNPlane(width: 0.2, height: 0.2)
                    plane.firstMaterial?.diffuse.contents = UIColor(
                        red: CGFloat(arc4random_uniform(255)),
                        green: CGFloat(arc4random_uniform(255)),
                        blue: CGFloat(arc4random_uniform(255)),
                        alpha: 1.0)
                    opacity = 0.7
                }
                // 平面を顔のノードに追加します
                let planeNode = SCNNode(geometry: plane)
                planeNode.opacity = opacity
                return planeNode
            }
        }
        return nil
    }
}
