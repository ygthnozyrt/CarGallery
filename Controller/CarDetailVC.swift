import UIKit
import SDWebImage
import AVFoundation // SES İÇİN MUTLAKA EKLE

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
    @IBOutlet weak var favButton: UIBarButtonItem! // Sağ üstteki yıldız butonu
    
    // MARK: - Properties
    var selectedCar: Car?
    var player: AVAudioPlayer? // Ses oynatıcı

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        if let car = selectedCar {
            setupUI(car: car)
            setupImages(urls: car.images)
        }
    }

    // MARK: - UI Setup
    func setupUI(car: Car) {
        brandLabel.text = "Brand : \(car.brand)"
        modelLabel.text = "Model : \(car.model)"
        yearLabel.text = "Year : \(car.year)"
        colorLabel.text = "Color : \(car.color)"
        fuelLabel.text = "Fuel Type : \(car.fuelType)"
        priceLabel.text = "\(car.price)"
        
        // Başlığı araba ismi yapalım
        self.title = "\(car.brand) \(car.model)"
    }

    func setupImages(urls: [String]) {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        pageControl.numberOfPages = urls.count
        
        for (index, urlString) in urls.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            if let url = URL(string: urlString) {
                imageView.sd_setImage(with: url)
            }
            
            let xPosition = self.view.frame.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(index + 1)
            scrollView.addSubview(imageView)
        }
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
        if favButton.image == UIImage(systemName: "star") {
            favButton.image = UIImage(systemName: "star.fill")
            favButton.tintColor = .systemYellow
            
            // POP ANİMASYONU: Butonun zıplamasını sağlar
            let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            bounceAnimation.values = [1.0, 1.4, 0.9, 1.1, 1.0]
            bounceAnimation.duration = 0.5
            navigationController?.navigationBar.layer.add(bounceAnimation, forKey: nil)
            
        } else {
            favButton.image = UIImage(systemName: "star")
            favButton.tintColor = .systemBlue
        }
    }
    
    // MARK: - ScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
