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
        // Her açıldığında listeyi yenile (yeni favoriler gelebilir)
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
        if FavoriteManager.shared.favorites.isEmpty {
            // Boş durum görünümü için bir view oluşturalım
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            
            // 1. İkon (Yıldız)
            let imageIcon = UIImageView()
            imageIcon.image = UIImage(systemName: "star.bubble") // SFSymbols'dan şık bir ikon
            imageIcon.tintColor = brandColor.withAlphaComponent(0.3) // Hafif silik bir bordo
            imageIcon.contentMode = .scaleAspectFit
            imageIcon.translatesAutoresizingMaskIntoConstraints = false
            
            // 2. Mesaj Label'ı
            let messageLabel = UILabel()
            messageLabel.text = "You Don't Have any Favorites.\nAdd Your Favorite Cars Now!"
            messageLabel.textColor = darkTextColor.withAlphaComponent(0.6)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Elemanları ekleyelim
            emptyView.addSubview(imageIcon)
            emptyView.addSubview(messageLabel)
            
            // Yerleşim (Auto Layout)
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
            // Liste doluysa arka planı temizle
            tableView.backgroundView = nil
        }
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteManager.shared.favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        let car = FavoriteManager.shared.favorites[indexPath.row]

        cell.backgroundColor = .clear
        let verticalPadding: CGFloat = 8
            let horizontalPadding: CGFloat = 16
            
            cell.contentView.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
            
            // 3. Gölgenin kesilmemesi için bu satır kritik!
            cell.contentView.layer.masksToBounds = false
            cell.clipsToBounds = false

        // --- KART TASARIMI (Beyaz kart, hafif gölge) ---
        let cv = cell.contentView
        cv.layer.cornerRadius = 16
        cv.layer.shadowColor = UIColor.black.cgColor
        cv.layer.shadowOffset = CGSize(width: 0, height: 4)
        cv.layer.shadowRadius = 6
        cv.layer.shadowOpacity = 0.1
        cv.layer.masksToBounds = false

        // --- İÇERİK ATAMALARI ---

        // 1. Görsel (Tag 1)
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.sd_setImage(with: URL(string: car.images.first ?? ""))
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
        }

        // 2. MARKA LABEL'I (Tag 2) - EKSİK OLAN KISIM BUYDU!
        if let brandLabel = cell.viewWithTag(2) as? UILabel {
            brandLabel.text = car.brand.uppercased() // Markayı büyük harf yap
            // HomeVC'deki gibi şık, küçük ve hafif silik bordo yapıyoruz
            brandLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            brandLabel.textColor = brandColor.withAlphaComponent(0.6)
        }

        // 3. Fiyat Label'ı (Tag 3)
        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = car.price.formatAsCurrency()
            priceLabel.textColor = brandColor
            priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        }

        // 4. Model Label'ı (Tag 4)
        if let modelLabel = cell.viewWithTag(4) as? UILabel {
            modelLabel.text = car.model
            modelLabel.textColor = darkTextColor
            modelLabel.font = .systemFont(ofSize: 17, weight: .bold)
        }

        return cell
    }
    
    // Hücre yüksekliği ve padding için HomeVC'deki willDisplay metodunu buraya da ekle
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8
        let horizontalPadding: CGFloat = 12
        cell.contentView.frame = cell.bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    // Favoriden kaydırarak silme (Çok Profesyonel bir özellik!)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let car = FavoriteManager.shared.favorites[indexPath.row]
            FavoriteManager.shared.remove(car)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
