//
//  HomeVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 31.12.2025.
//

import UIKit
import SDWebImage // Resimleri yüklemek için bunu eklemeyi unutma!

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tasarımdaki TableView'ı buraya bağlayacağız
    @IBOutlet weak var tableView: UITableView!
    
    var carList: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView ayarları
        tableView.delegate = self
        tableView.dataSource = self
        
        // Verileri çekmeye başla
        fetchData()
    }
    
    // --- İNTERNETTEN VERİ ÇEKME KISMI ---
    func fetchData() {
        let urlString = "https://gist.githubusercontent.com/ygthnozyrt/5d899ac741fca87cc82c211322981aa9/raw/8c3a82ffdc3dd5bf87927dc373a3073e92c5ae8e/cars.json"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            
            do {
                let incomingCars = try JSONDecoder().decode([Car].self, from: data)
                self.carList = incomingCars
                
                // Veri geldi, tabloyu yenile (Ana iş parçacığında yapılmalı)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Hata: \(error.localizedDescription)")
            }
        }.resume()
    }

    // --- TABLEVIEW AYARLARI (Custom Cell Dosyası Olmadan) ---
    
    // 1. Kaç araba var?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carList.count
    }
    
    // 2. Her satırda ne gösterilecek?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Storyboard'daki 'CarCell' isimli hücreyi çağır
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        
        let car = carList[indexPath.row]
        
        // --- TAG YÖNTEMİ ---
        // 1 numara: Resim
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            // İlk resim linkini alıp gösteriyoruz
            if let imageUrl = car.images.first {
                imageView.sd_setImage(with: URL(string: imageUrl))
            }
        }
        
        // 2 numara: Marka Model
        if let brandLabel = cell.viewWithTag(2) as? UILabel {
            brandLabel.text = "\(car.brand) \(car.model)"
        }
        
        // 3 numara: Fiyat
        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = "\(car.price) TL"
        }
        
        return cell
    }
    
    // Satır yüksekliği (İstersen değiştirebilirsin)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Tasarımına göre ayarla
    }
}
