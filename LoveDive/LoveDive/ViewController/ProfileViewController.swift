//
//  ProfileViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//
import UIKit
class ProfileViewController: UIViewController, UISearchBarDelegate {

  var searchBar = UISearchBar()
  var nameText = ""
  let cloudKitVM = CloudKitViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  func setupUI() {
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchBar)
    searchBar.delegate = self

    NSLayoutConstraint.activate([
      searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])
  }

  func searchBarSearchButtonClicked(_: UISearchBar) {
    searchFriends()
    print("THE SEARCH USERNAME IS \(searchBar.text)")
  }


  func searchFriends() {
    cloudKitVM.searchForFriends(withName: searchBar.text ?? "") { records in
      if let records {
        for record in records {
          if let username = record["username"] as? String {
            print("Found user: \(username)")
          }
        }
      }
    }
  }



}
