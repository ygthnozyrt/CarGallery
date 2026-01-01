//
//  SplashVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

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
    
    // Ses Oynatıcılar (Sound kuralı için)
    var enginePlayer: AVAudioPlayer?
    var hornPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // HomeVC ile uyumlu arka plan rengi
        view.backgroundColor = UIColor(hex: "#ECF4F7")
        
        setupLayout()
        setupAudio()
        
        // Seslerin ve UI'ın hazır olması için kısa bir bekleme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startAnimation()
        }
    }
    
    private func setupAudio() {
        // 1. Motor Sesi
        if let enginePath = Bundle.main.path(forResource: "car_intro_sound", ofType: "mp3") {
            let url = URL(fileURLWithPath: enginePath)
            do {
                enginePlayer = try AVAudioPlayer(contentsOf: url)
                // Sesteki boşluğu atlamak için profesyonel dokunuş
                enginePlayer?.currentTime = 2.0
                enginePlayer?.prepareToPlay()
            } catch { print("Motor sesi yüklenemedi") }
        }

        // 2. Korna Sesi
        if let hornPath = Bundle.main.path(forResource: "car-horn", ofType: "mp3") {
            let url = URL(fileURLWithPath: hornPath)
            do {
                hornPlayer = try AVAudioPlayer(contentsOf: url)
                hornPlayer?.prepareToPlay()
            } catch { print("Korna sesi yüklenemedi") }
        }
    }

    private func setupLayout() {
        view.addSubview(carImageView)
        view.addSubview(logoImageView)
        
        // Başlangıç pozisyonları (Ekranın dışı)
        carImageView.frame = CGRect(x: -view.frame.width, y: view.frame.height/2 - 100, width: view.frame.width * 0.8, height: 200)
        logoImageView.frame = CGRect(x: view.frame.width/2 - 100, y: view.frame.height/2 - 50, width: 200, height: 100)
    }

    private func startAnimation() {
        // Animasyon başladığında sesi çal
        enginePlayer?.play()
        
        // 1. Araba ekrana giriyor
        UIView.animate(withDuration: 1.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.carImageView.center.x = self.view.center.x
        }) { _ in
            
            // 2. Kısa bir bekleme ve kornayla çıkış
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.hornPlayer?.play()
                
                UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseIn, animations: {
                    // Araba sağdan çıkar
                    self.carImageView.frame.origin.x = self.view.frame.width + 50
                    // Logo belirir
                    self.logoImageView.alpha = 1
                    self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    // Geçiş yapmadan önce sesleri temizle
                    self.enginePlayer?.stop()
                    
                    // Ana sayfaya yumuşak geçiş
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.goToHomePage()
                    }
                }
            }
        }
    }

    private func goToHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Storyboard ID'nin "HomeNC" olduğundan emin ol
        if let homeNC = storyboard.instantiateViewController(withIdentifier: "HomeNC") as? UINavigationController {
            homeNC.modalTransitionStyle = .crossDissolve
            homeNC.modalPresentationStyle = .fullScreen
            self.present(homeNC, animated: true, completion: nil)
        }
    }
}
