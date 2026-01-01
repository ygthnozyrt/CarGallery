//
//  HomeVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

import UIKit
import SDWebImage

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var carList: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Arka planı hafif gri yaparak kartları ön plana çıkarıyoruz
        tableView.backgroundColor = .systemGray6
        fetchData()
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
        
        // Tag 1: Araba Görseli
        if let imageView = cell.viewWithTag(1) as? UIImageView, let url = car.images.first {
            imageView.sd_setImage(with: URL(string: url))
        }
        
        // Tag 2: Marka (Üst Label)
        if let brandLabel = cell.viewWithTag(2) as? UILabel {
            brandLabel.text = car.brand
        }
        
        // Tag 4: Model (Orta Label)
        if let modelLabel = cell.viewWithTag(4) as? UILabel {
            modelLabel.text = car.model
        }
        
        // Tag 3: Fiyat (Alt Label)
        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = "\(car.price) TL"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // İSTEDİĞİN ÇÖZÜM: Seçili kalan gri rengi anında temizler
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
