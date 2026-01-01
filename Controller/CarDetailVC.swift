import UIKit
import SDWebImage

// UIScrollViewDelegate ekledik ki noktalar resimle beraber kaysın
class CarDetailVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var fuelTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favButton: UIBarButtonItem!
    
    var selectedCar: Car?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        if let car = selectedCar {
            setupUI(car: car)
            setupImages(urls: car.images)
        }
    }

    func setupUI(car: Car) {
        self.navigationItem.title = "\(car.brand) \(car.model)"
        
        brandLabel.text = car.brand
        modelLabel.text = car.model
        yearLabel.text = String(car.year)
        colorLabel.text = car.color
        fuelTypeLabel.text = car.fuelType
        priceLabel.text = "\(car.price) TL"
        
        pageControl.numberOfPages = car.images.count
    }

    func setupImages(urls: [String]) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let width = view.frame.width
        let height = scrollView.frame.height
        
        for i in 0..<urls.count {
            let iv = UIImageView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
            iv.sd_setImage(with: URL(string: urls[i]))
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            scrollView.addSubview(iv)
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(urls.count), height: height)
    }
    
    // Noktaları kaydıran sihirli fonksiyon
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    @IBAction func favButtonTapped(_ sender: UIBarButtonItem) {
        if favButton.image == UIImage(systemName: "star") {
                favButton.image = UIImage(systemName: "star.fill")
            } else {
                favButton.image = UIImage(systemName: "star")
            }
    }
}
