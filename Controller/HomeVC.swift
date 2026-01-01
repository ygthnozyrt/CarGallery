//
//  HomeVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

import UIKit
import SDWebImage

extension Int {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "." // Nokta koyması için
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return (formatter.string(from: NSNumber(value: self)) ?? "\(self)") + " TL"
    }
}
extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var carList: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            
            // Ana arka plan rengi
            let bgColor = UIColor(hex: "#ECF4F7")
            view.backgroundColor = bgColor
            tableView.backgroundColor = bgColor
            setupNavigationBarLogo()
            
            fetchData()
    }
    
    func setupNavigationBarLogo() {
        // 1. Kullanılacak görseli seç (Assets kısmına eklediğin logo adı)
        let logoImage = UIImage(named: "dogus-logo") // Buraya kendi görsel ismini yaz
        let imageView = UIImageView(image: logoImage)
        
        // 2. Görselin boyutlarını ve duruşunu ayarla
        imageView.contentMode = .scaleAspectFit
        
        // Genellikle 100x40 veya 120x33 gibi boyutlar navigasyon bar için idealdir
        let imageWidth: CGFloat = 120
        let imageHeight: CGFloat = 33
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        
        // 3. Yazı yerine bu imageView'ı yerleştir
        self.navigationItem.titleView = imageView
    }
    
    func fetchData() {
        let urlString = "https://gist.githubusercontent.com/ygthnozyrt/5d899ac741fca87cc82c211322981aa9/raw/8c3a82ffdc3dd5bf87927dc373a3073e92c5ae8e/cars.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { return }
            guard let data = data else { return }
            do {
                let incomingCars = try JSONDecoder().decode([Car].self, from: data)
                self.carList = incomingCars
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch { print(error) }
        }.resume()
    }

    // MARK: - TableView Methods
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        let car = carList[indexPath.row]
        
        let verticalPadding: CGFloat = 8
        let horizontalPadding: CGFloat = 16
        cell.contentView.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
        
        // 3. Gölgenin kesilmemesi için bu satır kritik!
            cell.contentView.layer.masksToBounds = false
            cell.clipsToBounds = false
        
        // Renk Tanımların
        let brandColor = UIColor(hex: "#910029")
        let darkTextColor = UIColor(hex: "#39404B")
        let bgColor = UIColor(hex: "#ECF4F7")
        
        cell.backgroundColor = .clear
        
        // --- KART AYARLARI ---
        let cv = cell.contentView
        cv.backgroundColor = bgColor
        cv.layer.cornerRadius = 16
        cv.layer.shadowColor = UIColor.black.cgColor
        cv.layer.shadowOffset = CGSize(width: 0, height: 4)
        cv.layer.shadowRadius = 6
        cv.layer.shadowOpacity = 0.1
        cv.layer.masksToBounds = false
        
        // --- 1. GÖRSEL (DARALTILMIŞ VE KORUNMUŞ) ---
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if let urlString = car.images.first {
                imageView.sd_setImage(with: URL(string: urlString))
            }
            // Resmin genişliğini daraltsan da Aspect Fill sayesinde bozulmaz
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
        }
        
        // --- 2. MODEL İSMİ (SONU NOKTA OLMAMASI İÇİN) ---
        if let modelLabel = cell.viewWithTag(4) as? UILabel {
            modelLabel.text = car.model
            modelLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            modelLabel.textColor = darkTextColor
            
            // ÇÖZÜM: İsim çok uzunsa alt satıra geçer, görsel daraldığı için artık daha çok yerin var
            modelLabel.numberOfLines = 2
            modelLabel.lineBreakMode = .byWordWrapping
        }
        
        // Marka ve Fiyat ayarları...
        if let brandLabel = cell.viewWithTag(2) as? UILabel {
            brandLabel.text = car.brand.uppercased()
            brandLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            brandLabel.textColor = brandColor.withAlphaComponent(0.6)
        }
        
        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = car.price.formatAsCurrency()
            priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            priceLabel.textColor = brandColor
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
        
    }
    // Kartların arasına mesafe koymak için contentView'ı biraz daraltıyoruz
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8
        let horizontalPadding: CGFloat = 12
        
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 15
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
        
        cell.contentView.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.backgroundColor = .clear

        let selectedCar = carList[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: selectedCar)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail",
           let dest = segue.destination as? CarDetailVC,
           let car = sender as? Car {
            dest.selectedCar = car
        }
    }
}
