
import UIKit
import Alamofire
import SwiftyJSON
import CRRefresh

class search : UIViewController, UISearchBarDelegate {
    
    
    lazy var searchText = UISearchBar()
    @IBOutlet weak var SearchCollectionView: UICollectionView!
    
    lazy var workItem = WorkItem()
     
    
        
    
    
    var gshti = 1
    var Array : [ActivityObjects] = []
    var searchPlaceHolder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.titleView = searchText
        searchText.backgroundImage = UIImage()
        SearchCollectionView.register(UINib(nibName: "NewsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsCell")
        self.searchText.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]

        if XLanguage.get() == .Kurdish{
            self.searchPlaceHolder = "گەران..."
            self.searchText.placeholder = self.searchPlaceHolder
        }else if XLanguage.get() == .Arabic{
            self.searchPlaceHolder = "البحث..."
            self.searchText.placeholder = self.searchPlaceHolder
        }else{
            self.searchPlaceHolder = "Search..."
            self.searchText.placeholder = self.searchPlaceHolder
        }
        
        

        
    }
    
    
    
    
    
    var IsSearched : Bool = false
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            self.Array.removeAll()
        }else{
            self.IsSearched = true
            self.workItem.perform(after: 0.3) {
                self.Array.removeAll()
                let stringUrl = URL(string: API.URL);
                let param: [String: Any] = [
                    "key":API.key,
                    "username":API.UserName,
                    "fun":"search_activity",
                    "text": searchText
                ]
                AF.request(stringUrl!, method: .post, parameters: param).responseData { respons in
                    switch respons.result{
                    case .success:
                        let jsonData = JSON(respons.data ?? "")
                        if(jsonData[0] != "error"){
                            for (_,val) in jsonData{
                                print(jsonData)
                                let act = ActivityObjects(id: val["id"].string ?? "",image: val["image"].string ?? "", title: val["title"].string ?? "", desc: val["desc"].string ?? "", youtube_link: val["youtube_link"].string ?? "", activity_date: val["activity_date"].string ?? "", date: val["date"].string ?? "", user_id: val["user_id"].string ?? "", views: val["views"].string ?? "", rate: val["rate"].string ?? "")
                                self.Array.append(act)
                            }
                            self.SearchCollectionView.reloadData()
                        }
                    case .failure(let error):
                        print("error 520 : error while getting category in search")
                        print(error);
                    }
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let activity = sender as? ActivityObjects{
            if let next = segue.destination as? Details{
                next.Details = activity
            }
        }
    }

}



extension searchVC : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.Array.count == 0{
            return 0
        }
        return self.Array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewsCollectionViewCell
        if self.Array.count != 0{
            cell.update(self.Array[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3, height: 164)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.Array.count != 0 && indexPath.row <= self.Array.count{
            if UserDefaults.standard.bool(forKey: "Login") == true{
                ViewsObject.SetView(profileId: UserDefaults.standard.string(forKey: "id") ?? "", activitiesId: Array[indexPath.row].id) { state in
                    //
                }
            }
              self.performSegue(withIdentifier: "Next", sender: Array[indexPath.row])
        }
    }
    

    
}




