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
        formatter.groupingSeparator = "."
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
    let brandColor = UIColor(hex: "#910029")
    let darkTextColor = UIColor(hex: "#39404B")
    let bgColor = UIColor(hex: "#ECF4F7")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        view.backgroundColor = bgColor
        tableView.backgroundColor = bgColor
        
        setupNavigationBarLogo()
    }
    
    func setupNavigationBarLogo() {
        let logoImage = UIImage(named: "dogus-logo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 120, height: 33)
        self.navigationItem.titleView = imageView
    }
    
    func fetchData() {
        let urlString = "https://gist.githubusercontent.com/ygthnozyrt/5d899ac741fca87cc82c211322981aa9/raw/8c3a82ffdc3dd5bf87927dc373a3073e92c5ae8e/cars.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                let incomingCars = try JSONDecoder().decode([Car].self, from: data)
                self.carList = incomingCars
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch { }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        let car = carList[indexPath.row]
        
        cell.backgroundColor = .clear
        
        let cv = cell.contentView
        cv.backgroundColor = .white
        cv.layer.cornerRadius = 16
        cv.layer.shadowColor = UIColor.black.cgColor
        cv.layer.shadowOffset = CGSize(width: 0, height: 4)
        cv.layer.shadowRadius = 6
        cv.layer.shadowOpacity = 0.1
        cv.layer.masksToBounds = false
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if let urlString = car.images.first {
                imageView.sd_setImage(with: URL(string: urlString))
            }
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
        }
        
        if let modelLabel = cell.viewWithTag(4) as? UILabel {
            modelLabel.text = car.model
            modelLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            modelLabel.textColor = darkTextColor
            modelLabel.numberOfLines = 2
            modelLabel.lineBreakMode = .byWordWrapping
        }
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8
        let horizontalPadding: CGFloat = 12
        cell.contentView.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
