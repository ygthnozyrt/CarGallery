import UIKit
import SDWebImage
import AVFoundation

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
    
    // Renkleri tanımlayalım
    let brandColor = UIColor(hex: "#910029")
    let darkTextColor = UIColor(hex: "#39404B")
    let bgColor = UIColor(hex: "#ECF4F7")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme() // Temayı ayarla
        
        scrollView.delegate = self
        
        if let car = selectedCar {
            setupUI(car: car)
            setupImages(urls: car.images)
            updateFavoriteButton()
        }
    }
    
    func setupTheme() {
        // Arka plan rengi HomeVC ile aynı olmalı
        view.backgroundColor = bgColor
        
        // Navigation Bar ayarı
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bgColor
        appearance.titleTextAttributes = [.foregroundColor: darkTextColor, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    // MARK: - UI Setup
    func setupUI(car: Car) {
        // 1. Marka (Daha görünür ve şık)
            brandLabel.text = car.brand.uppercased()
            brandLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold) // Biraz büyüttük
            brandLabel.textColor = brandColor
            brandLabel.textAlignment = .right // Sağ üst köşede şık durur
        
        // Model: Büyük ve Koyu Gri
        modelLabel.text = car.model
        modelLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        modelLabel.textColor = darkTextColor
        modelLabel.numberOfLines = 2
        modelLabel.lineBreakMode = .byWordWrapping
        
        // Detaylar (Yıl, Renk, Yakıt): Daha temiz bir görünüm
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
        
        // Fiyat: Belirgin ve Büyük Bordo
        priceLabel.text = car.price.formatAsCurrency()
        priceLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = brandColor
        
        self.title = car.model
    }

    func setupImages(urls: [String]) {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 20 // Resimlerin olduğu alanı yuvarla
        scrollView.clipsToBounds = true
        
        pageControl.numberOfPages = urls.count
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = brandColor
        
        // Önemli: Constraint'lerin oturması için viewDidLayoutSubviews kullanmak daha iyidir
        // ama basitlik için frame üzerinden gidiyorsak:
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
       
       @IBAction func engineSoundTapped(_ sender: UIButton) {
           guard let car = selectedCar else { return }
           
           let soundName = car.fuelType.lowercased()
           
           if let path = Bundle.main.path(forResource: soundName, ofType: "mp3") {
               let url = URL(fileURLWithPath: path)
               do {
                   player = try AVAudioPlayer(contentsOf: url)
                   player?.prepareToPlay() // Oynatmadan önce hazırla
                   player?.play()
                   print("BAŞARILI: \(soundName) çalıyor.")
               } catch {
                   print("HATA: Ses dosyası oluşturulamadı: \(error.localizedDescription)")
               }
           }
       }

       // 2. Favori Yıldız Butonu (Animasyonlu)
    @IBAction func favButtonTapped(_ sender: UIBarButtonItem) {
        guard let car = selectedCar else { return }
        
        if FavoriteManager.shared.isFavorite(car) {
            FavoriteManager.shared.remove(car)
            favButton.image = UIImage(systemName: "star")
            favButton.tintColor = .systemBlue
        } else {
            FavoriteManager.shared.add(car)
            favButton.image = UIImage(systemName: "star.fill")
            favButton.tintColor = .systemYellow
            
            // POP ANİMASYONU
            let bounce = CAKeyframeAnimation(keyPath: "transform.scale")
            bounce.values = [1.0, 1.4, 0.9, 1.1, 1.0]
            bounce.duration = 0.5
            navigationController?.navigationBar.layer.add(bounce, forKey: nil)
        }
    }
       
       // MARK: - ScrollView Methods
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
           pageControl.currentPage = Int(pageIndex)
       }
    
    func updateFavoriteButton() {
        guard let car = selectedCar else { return }
        
        if FavoriteManager.shared.isFavorite(car) {
            favButton.image = UIImage(systemName: "star.fill")
            favButton.tintColor = .systemYellow
        } else {
            favButton.image = UIImage(systemName: "star")
            favButton.tintColor = .systemBlue // Veya hangi rengi istiyorsan
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
}
