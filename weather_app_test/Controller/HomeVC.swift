//
//  HomeVC.swift
//  weather_app_test
//
//  Created by Dilshod Iskandarov on 3/16/22.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import CoreLocation
import NVActivityIndicatorView

struct Temp16 : Codable{
    var date : String
    var max : Int
    var min : Int
    var img : String
}

class HomeVC: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate {
 
    
   
    let Api_Key = "63a288a620ab8ba29dbe5d4fa35c2d4d"
    var searchBar:UISearchBar = {
       let s = UISearchBar()
        return s
    }()
    var resultTable: UITableView = {
        let t = UITableView()
        t.register(UINib.init(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        t.separatorStyle = .none
        t.allowsSelection = false
        t.layer.cornerRadius = 20
        return t
    }()
    let contentView: UIView = {
       let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    let titleCity: UILabel = {
       let l = UILabel()
        l.text = "Label"
        l.font = UIFont.systemFont(ofSize: 33)
        l.textAlignment = .center
        return l
    }()
    let imgBack: UIImageView = {
       let i = UIImageView()
        i.contentMode = .scaleAspectFill
        return i
    }()
    let img: UIImageView = {
       let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.image = UIImage.init(named: "10n")
        return i
    }()
    let gradus: UILabel = {
       let l = UILabel()
        l.text = "0"
        l.font = UIFont.systemFont(ofSize: 77)
        l.textAlignment = .center
        return l
    }()
    var status: UISegmentedControl = {
        var s = UISegmentedControl()
        let items = ["5 Days/3hour ", "16 Days"]
        s = UISegmentedControl(items: items)
        s.selectedSegmentIndex = 0
        s.layer.cornerRadius = 30.0
        s.tintColor = .white
        s.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return s
    }()
    var country = "Tashkent"
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .red, padding: 0)
    var data16Daily : [Temp16] = []
    var locationManager: CLLocationManager!
    var lat = Double()
    var lon = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViewUI()
        searchBar.placeholder = " Search..."
        delegates()
        updateViewConstraints()
        dailyAPI()
        setup()
        laoding()
        getCurrentLocation()
    }
    func delegates(){
        searchBar.delegate = self
        resultTable.delegate = self
        resultTable.dataSource = self
    }
    func addSubViewUI(){
        view.addSubview(imgBack)
        view.addSubview(contentView)
        contentView.addSubview(searchBar)
        contentView.addSubview(titleCity)
        contentView.addSubview(gradus)
        contentView.addSubview(resultTable)
        contentView.addSubview(img)
        contentView.addSubview(status)
    }
    func setup(){
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
                case 0..<5:
                    imgBack.image = UIImage(named: "night")
                case 5..<6:
                    imgBack.image = UIImage(named: "morn")
                case 6..<19:
                    imgBack.image = UIImage(named: "day")
                case 19..<24:
                    imgBack.image = UIImage(named: "night")
                default:
                    break
        }
    }
    func laoding(){
        loading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.widthAnchor.constraint(equalToConstant: 80),
            loading.heightAnchor.constraint(equalToConstant: 80),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        loading.startAnimating()
    }
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loading.startAnimating()
            dailyAPI()
            resultTable.reloadData()
        }else if sender.selectedSegmentIndex == 1{
            loading.startAnimating()
            weekAPI(request: self.country)
            resultTable.reloadData()
        }
    }
    func getCurrentLocation(){
           if (CLLocationManager.locationServicesEnabled()){
               locationManager = CLLocationManager()
               locationManager.delegate = self
               locationManager.desiredAccuracy = kCLLocationAccuracyBest
               locationManager.requestAlwaysAuthorization()
               locationManager.startUpdatingLocation()
           }
       }
    override func updateViewConstraints() {
        contentView.snp.makeConstraints { make in
            make.height.equalTo(view)
            make.width.equalTo(view)
            make.top.equalTo(80)
        }
        imgBack.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp_bottom)
            make.height.equalTo(view)
            make.width.equalTo(view)
        }
        searchBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
        }
        titleCity.snp.makeConstraints { make in
            make.top.equalTo(img.snp_bottom)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        gradus.snp.makeConstraints { make in
            make.top.equalTo(titleCity.snp_bottom)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        status.snp.makeConstraints { make in
            make.top.equalTo(gradus.snp_bottom)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        img.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp_bottom)
            make.height.equalTo(200)
            make.centerX.equalTo(contentView)
            make.width.equalTo(200)
        }
        resultTable.snp.makeConstraints { make in
            make.top.equalTo(status.snp_bottom)
            make.right.equalTo(0)
            make.height.equalTo(430)
            make.left.equalTo(0)
        }
        super.updateViewConstraints()
    }
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loading.startAnimating()
        weekAPI(request: searchBar.text!)
    }
   
    func dailyAPI(){
        data16Daily.removeAll()
        let urldaily = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(Api_Key)"
        AF.request(urldaily).responseJSON {[self] (res) in
            if let data = res.data{
                let json = JSON(data)
                titleCity.text = json["city"]["name"].stringValue
                gradus.text =  "\(json["list"][0]["main"]["temp"].intValue - 273)°C"
                country = json["city"]["name"].stringValue
                img.image = UIImage.init(named: json["list"][0]["weather"][0]["icon"].stringValue)
                for w in 0..<json["list"].count {
                    let da = json["list"][w]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, dd MMM YYYY"
                    let daily = Temp16(
                        date: da["dt_txt"].stringValue,
                        max: da["main"]["temp_max"].intValue - 273,
                        min: da["main"]["temp_min"].intValue - 273,
                        img: da["weather"][0]["icon"].stringValue
                                       )
                    data16Daily.append(daily)
                    loading.stopAnimating()
                }
            }
            resultTable.reloadData()
        }
    }
    func weekAPI(request: String){
        data16Daily.removeAll()
        let urldaily = "https://api.weatherbit.io/v2.0/forecast/daily?&city=\(request)&key=7c239c4decd84254b0b8aef6dd7e6a20"
        AF.request(urldaily).responseJSON {[self] (res) in
            if let data = res.data{
                let json = JSON(data)
                print(json)
                titleCity.text = json["city_name"].stringValue
                gradus.text =  "\(json["data"][0]["temp"].intValue)°C"
                img.image = UIImage.init(named: json["data"][0]["weather"]["icon"].stringValue)
                for w in 0..<json["data"].count {
                    let da = json["data"][w]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, dd MMM YYYY"
                    let daily = Temp16(
                        date: da["datetime"].stringValue,
                        max: da["max_temp"].intValue,
                        min: da["min_temp"].intValue,
                        img: da["weather"]["icon"].stringValue
                    )
                    data16Daily.append(daily)
                    loading.stopAnimating()
                }
            }
            resultTable.reloadData()
        }
    }
 
    // MARK: Location Manager Delegate methods
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
            let locationsObj = locations.last! as CLLocation
            lat = locationsObj.coordinate.latitude
            lon = locationsObj.coordinate.longitude
            print("Current location = \(locationsObj.coordinate.latitude) \(locationsObj.coordinate.longitude)")
       
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Get Location failed")
        }
}


extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data16Daily.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTable.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        cell.dateLabel.text = data16Daily[indexPath.row].date
        cell.maxLabel.text = "\(data16Daily[indexPath.row].max)"
        cell.img.image = UIImage.init(named: data16Daily[indexPath.row].img) ?? UIImage.init(named: "c02d")
        return cell
    }
}
    

