import UIKit
import AVFoundation

class SplashVC: UIViewController {

    // MARK: - UI Elements
    private let carImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "splash_car"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "dogus-logo"))
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        return iv
    }()
    
    // Ses Oynatıcılar
    var enginePlayer: AVAudioPlayer?
    var hornPlayer: AVAudioPlayer? // Korna için ikinci oynatıcı

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#ECF4F7")
        
        setupLayout()
        setupAudio()
        
        // Seslerin hazır olması için çok kısa bir bekleme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startAnimation()
        }
    }
    
    private func setupAudio() {
        // 1. Motor Sesi Ayarı
        if let enginePath = Bundle.main.path(forResource: "car_intro_sound", ofType: "mp3") {
            let url = URL(fileURLWithPath: enginePath)
            do {
                enginePlayer = try AVAudioPlayer(contentsOf: url)
                // ÇÖZÜM: Sesteki 2 saniyelik boşluğu atla
                enginePlayer?.currentTime = 2.0
                enginePlayer?.prepareToPlay()
            } catch { print("Motor sesi hatası") }
        }

        // 2. Korna Sesi Ayarı
        if let hornPath = Bundle.main.path(forResource: "car-horn", ofType: "mp3") {
            let url = URL(fileURLWithPath: hornPath)
            do {
                hornPlayer = try AVAudioPlayer(contentsOf: url)
                hornPlayer?.prepareToPlay()
            } catch { print("Korna sesi hatası") }
        }
    }

    private func setupLayout() {
        view.addSubview(carImageView)
        view.addSubview(logoImageView)
        carImageView.frame = CGRect(x: -view.frame.width, y: view.frame.height/2 - 100, width: 400, height: 200)
        logoImageView.frame = CGRect(x: view.frame.width/2 - 100, y: view.frame.height/2 - 50, width: 200, height: 100)
    }

    private func startAnimation() {
        // Motor sesini başlat (2. saniyeden başlar)
        enginePlayer?.play()
        
        // ARABA GELİYOR
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.carImageView.center.x = self.view.center.x
        }) { _ in
            
            // BEKLEME VE ÇIKIŞ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                // ARABA ÇIKARKEN KORNA ÇAL
                self.hornPlayer?.play()
                
                UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseIn, animations: {
                    self.carImageView.frame.origin.x = self.view.frame.width + 100
                    self.logoImageView.alpha = 1
                    self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }) { _ in
                    // Tüm sesleri durdur ve geçiş yap
                    self.enginePlayer?.stop()
                    
                    // Korna sesi bitince ana sayfaya geç (opsiyonel gecikme)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.goToHomePage()
                    }
                }
            }
        }
    }

    private func goToHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeNC = storyboard.instantiateViewController(withIdentifier: "HomeNC") as? UINavigationController {
            homeNC.modalTransitionStyle = .crossDissolve
            homeNC.modalPresentationStyle = .fullScreen
            self.present(homeNC, animated: true, completion: nil)
        }
    }
}
