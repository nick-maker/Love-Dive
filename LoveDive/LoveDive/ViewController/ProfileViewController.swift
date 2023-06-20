//
//  ProfileViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//
import CloudKit
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
    guard let searchEmail = searchBar.text else { return }
    searchFriends(email: searchEmail)
  }

  func searchFriends(email: String) {
    let lookupInfo = CKUserIdentity.LookupInfo(emailAddress: email)
    let operation = CKDiscoverUserIdentitiesOperation(userIdentityLookupInfos: [lookupInfo])

    operation.userIdentityDiscoveredBlock = { identity, _ in
      // Do something with the discovered user identity
      if let nameComponents = identity.nameComponents {
        let name = PersonNameComponentsFormatter.localizedString(from: nameComponents, style: .default, options: [])
        print("Discovered user: \(name)")
      }
    }

    operation.discoverUserIdentitiesCompletionBlock = { error in
      if let error {
        // Handle the error
        print("Error discovering user identities: \(error)")
      } else {
        print("Finished discovering user identities")
      }
    }

    CKContainer.default().add(operation)
  }

}
