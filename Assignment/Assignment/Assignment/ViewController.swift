//
//  ViewController.swift
//  Assignment
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainerView: UIView!

    @objc var pageControl : UIPageControl = UIPageControl();
    @objc var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    
    var searchedMenu: [Menu] = []
    var menuList: [Menu] = []
 
    var categoryCount : Int = 0
    var searching = false
    var MenuCategories: [MenuList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenuCategories = processJSONData(filename: "Menu.json")
        configurePageControl()
        setUpMenuList()
        setUpScrollView()
        configureScrollViewPages()
    }
    
    func setUpScrollView()  {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.frame = CGRect(x: 0, y: 8, width: self.view.frame.size.width, height: 300)
        scrollView.bounces = false
    }
    
    // function for confugure scrollview
    
    func configureScrollViewPages()  {
        categoryCount = MenuCategories.count
        
        // Add images on scrollview
        for index in 0..<categoryCount {
            
            let subView = UIImageView();
            subView.backgroundColor = UIColor.darkGray
            subView.image = UIImage(named: MenuCategories[index].categoryImage);
          
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            subView.frame = frame
            self.scrollView .addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * CGFloat(categoryCount),height: self.scrollView.frame.size.height)
        
        self.scrollViewContainerView.addSubview(pageControl)
    }
    
    // customize page control
    @objc func configurePageControl() {

        self.pageControl.numberOfPages = MenuCategories.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.white
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.red
        
        pageControl.frame = CGRect(x: self.scrollView.frame.size.width/2-100, y: scrollView.frame.size.height + 40, width:200 , height: 50)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
    }
    
    func setUpMenuList() {
        self.listTableView.separatorStyle = .singleLine
        reloadTableData()
    }
    
    // function to change while clicking on Page Control
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        reloadTableData()
    }
    
    // function called when page changed for reloading table data
    func reloadTableData()  {
        let currentPageNo = pageControl.currentPage
        menuList = MenuCategories[currentPageNo].menus
        
        listTableView.reloadData()
    }

    func processJSONData<T: Decodable>(filename: String) -> [T] {
      let data: Data
      guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
          else {
              fatalError("Couldn't find \(filename) in main bundle.")
      }
      do {
          data = try Data(contentsOf: file)
      } catch {
          fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
      }
      do {
        return try JSONDecoder().decode([T].self, from: data)
      } catch {
          fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
      }
    }
}

// MARK: - UITableView Delegate and DataSource methods

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedMenu.count
        } else {
            return menuList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCellIdentifier",
                                                       for: indexPath) as? MenuCellTableViewCell else {
            fatalError("MenuCellTableViewCell cell not found")
        }
        
        let currentPageNo = pageControl.currentPage
        cell.menuImageView.image = UIImage(named: MenuCategories[currentPageNo].categoryImage)

        if searching {
            cell.menuNameLabel.text = searchedMenu[indexPath.row].name
        } else {
            cell.menuNameLabel.text = menuList[indexPath.row].name
        }
     
        return cell
    }
}

// MARK: - Delegate methods for UISearch Bar

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
  
        searchedMenu = menuList.filter { ($0.name )?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()
        }
        searching = true
        listTableView.reloadData()
    }
    
    // delegate shows the behaviour of cancel button of search Bar
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        self.searchBar.searchTextField.endEditing(true)
        listTableView.reloadData()
    }
}

// MARK: - Delegate methods for Scrollview
extension ViewController: UIScrollViewDelegate {
    // delegated called when scroll ends scrolling
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        reloadTableData()
    }
}
