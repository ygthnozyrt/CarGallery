//
//  FavsVC.swift
//  CarGallery
//
//  Created by Yigithan Ozyurt on 1.01.2026.
//

import UIKit
import SDWebImage

class FavsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let brandColor = UIColor(hex: "#910029")
    let darkTextColor = UIColor(hex: "#39404B")
    let bgColor = UIColor(hex: "#ECF4F7")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        checkEmptyState()
    }
    
    func setupUI() {
        title = "Favorites"
        view.backgroundColor = bgColor
        tableView.backgroundColor = bgColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    func checkEmptyState() {
        let favorites = FavoriteManager.shared.getAllFavorites()
        if favorites.isEmpty {
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            let imageIcon = UIImageView(image: UIImage(systemName: "star.bubble"))
            imageIcon.tintColor = brandColor.withAlphaComponent(0.3)
            imageIcon.contentMode = .scaleAspectFit
            imageIcon.translatesAutoresizingMaskIntoConstraints = false
            let messageLabel = UILabel()
            messageLabel.text = "You Don't Have any Favorites.\nAdd Your Favorite Cars Now!"
            messageLabel.textColor = darkTextColor.withAlphaComponent(0.6)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyView.addSubview(imageIcon)
            emptyView.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                imageIcon.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                imageIcon.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -40),
                imageIcon.widthAnchor.constraint(equalToConstant: 80),
                imageIcon.heightAnchor.constraint(equalToConstant: 80),
                messageLabel.topAnchor.constraint(equalTo: imageIcon.bottomAnchor, constant: 20),
                messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 40),
                messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -40)
            ])
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteManager.shared.getAllFavorites().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        let car = FavoriteManager.shared.getAllFavorites()[indexPath.row]

        cell.backgroundColor = .clear
        let cv = cell.contentView
        cv.layer.cornerRadius = 16
        cv.layer.shadowColor = UIColor.black.cgColor
        cv.layer.shadowOffset = CGSize(width: 0, height: 4)
        cv.layer.shadowRadius = 6
        cv.layer.shadowOpacity = 0.1
        cv.layer.masksToBounds = false

        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if let imageData = car.image?.data(using: .utf8),
               let images = try? JSONDecoder().decode([String].self, from: imageData) {
                imageView.sd_setImage(with: URL(string: images.first ?? ""))
            }
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
        }

        if let brandLabel = cell.viewWithTag(2) as? UILabel {
            brandLabel.text = car.brand?.uppercased()
            brandLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            brandLabel.textColor = brandColor.withAlphaComponent(0.6)
        }

        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = Int(car.price).formatAsCurrency()
            priceLabel.textColor = brandColor
            priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        }

        if let modelLabel = cell.viewWithTag(4) as? UILabel {
            modelLabel.text = car.model
            modelLabel.textColor = darkTextColor
            modelLabel.font = .systemFont(ofSize: 17, weight: .bold)
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
        let selectedFav = FavoriteManager.shared.getAllFavorites()[indexPath.row]
        
        var imageArray: [String] = []
        if let imageData = selectedFav.image?.data(using: .utf8) {
            imageArray = (try? JSONDecoder().decode([String].self, from: imageData)) ?? []
        }
        
        let carToPass = Car(
            id: Int(selectedFav.id),
            brand: selectedFav.brand ?? "",
            model: selectedFav.model ?? "",
            year: Int(selectedFav.year),
            color: selectedFav.color ?? "",
            price: Int(selectedFav.price),
            fuelType: selectedFav.fuelType ?? "",
            images: imageArray
        )
        
        performSegue(withIdentifier: "toDetailFromFavs", sender: carToPass)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFromFavs",
           let dest = segue.destination as? CarDetailVC,
           let car = sender as? Car {
            dest.selectedCar = car
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let car = FavoriteManager.shared.getAllFavorites()[indexPath.row]
            FavoriteManager.shared.remove(Int(car.id))
            tableView.deleteRows(at: [indexPath], with: .fade)
            checkEmptyState()
        }
    }
}
