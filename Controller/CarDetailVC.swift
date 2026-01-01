//
//  CarDetailVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

import UIKit
import SDWebImage
import AVFoundation // Ses kuralı için gerekli

class CarDetailVC: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favButton: UIBarButtonItem!
    
    // MARK: - Properties
    var selectedCar: Car?
    var player: AVAudioPlayer?
    
    // Tasarım Renkleri
    let brandColor = UIColor(hex: "#910029")
    let darkTextColor = UIColor(hex: "#39404B")
    let bgColor = UIColor(hex: "#ECF4F7")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        
        scrollView.delegate = self
        
        if let car = selectedCar {
            setupUI(car: car)
            setupImages(urls: car.images)
            updateFavoriteButton()
        }
    }
    
    func setupTheme() {
        view.backgroundColor = bgColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bgColor
        appearance.titleTextAttributes = [.foregroundColor: darkTextColor, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    // MARK: - UI Setup
    func setupUI(car: Car) {
        brandLabel.text = car.brand.uppercased()
        brandLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        brandLabel.textColor = brandColor
        brandLabel.textAlignment = .right
        
        modelLabel.text = car.model
        modelLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        modelLabel.textColor = darkTextColor
        modelLabel.numberOfLines = 2
        modelLabel.lineBreakMode = .byWordWrapping
        
        let detailFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        yearLabel.text = "\(car.year)"
        yearLabel.font = detailFont
        yearLabel.textColor = darkTextColor.withAlphaComponent(0.8)
        
        colorLabel.text = "\(car.color)"
        colorLabel.font = detailFont
        colorLabel.textColor = darkTextColor.withAlphaComponent(0.8)
        
        fuelLabel.text = "\(car.fuelType)"
        fuelLabel.font = detailFont
        fuelLabel.textColor = darkTextColor.withAlphaComponent(0.8)
        
        priceLabel.text = car.price.formatAsCurrency()
        priceLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = brandColor
        
        self.title = car.model
    }

    func setupImages(urls: [String]) {
        // Kaydırma (Gesture) desteği
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 20
        scrollView.clipsToBounds = true
        
        pageControl.numberOfPages = urls.count
        pageControl.currentPageIndicatorTintColor = brandColor
        
        for (index, urlString) in urls.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            if let url = URL(string: urlString) {
                imageView.sd_setImage(with: url)
            }
            
            let xPosition = self.view.frame.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: 0, width: view.frame.width, height: scrollView.frame.height)
            
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(urls.count), height: scrollView.frame.height)
    }
    
    // MARK: - Actions
    
    // Motor Sesi (Sound kuralı)
    @IBAction func engineSoundTapped(_ sender: UIButton) {
        guard let car = selectedCar else { return }
        let soundName = car.fuelType.lowercased()
        
        if let path = Bundle.main.path(forResource: soundName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("Ses çalınamadı: \(error)")
            }
        }
    }

    // Favori Yıldız Butonu (Core Data ve Animasyon)
    @IBAction func favButtonTapped(_ sender: UIBarButtonItem) {
        guard let car = selectedCar else { return }
        
        // FavoriteManager artık Core Data kullanıyor
        if FavoriteManager.shared.isFavorite(car.id) {
            FavoriteManager.shared.remove(car.id)
            favButton.image = UIImage(systemName: "star")
            favButton.tintColor = .systemBlue
        } else {
            FavoriteManager.shared.add(car)
            favButton.image = UIImage(systemName: "star.fill")
            favButton.tintColor = .systemYellow
            
            // Profesyonel görünüm için POP animasyonu
            let bounce = CAKeyframeAnimation(keyPath: "transform.scale")
            bounce.values = [1.0, 1.4, 0.9, 1.1, 1.0]
            bounce.duration = 0.5
            navigationController?.navigationBar.layer.add(bounce, forKey: nil)
        }
    }
    
    // MARK: - Helper Methods
    func updateFavoriteButton() {
        guard let car = selectedCar else { return }
        if FavoriteManager.shared.isFavorite(car.id) {
            favButton.image = UIImage(systemName: "star.fill")
            favButton.tintColor = .systemYellow
        } else {
            favButton.image = UIImage(systemName: "star")
            favButton.tintColor = .systemBlue
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
}
