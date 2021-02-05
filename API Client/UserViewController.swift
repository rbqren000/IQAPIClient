//
//  UserViewController.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import UIKit
import IQAPIClient
import Alamofire
import IQListKit

class UserViewController: UITableViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    lazy var list = IQList(listView: tableView, delegateDataSource: self)

    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        list.performUpdates({
            let section = IQSection(identifier: 0)
            list.append(section)
        }, animatingDifferences: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUI()
        getUser()
    }

    private func getUser() {

        guard activityIndicator.isAnimating == false else {
            return
        }

        activityIndicator.startAnimating()

        IQAPIClient.user(id: user.id) { [weak self] (result) in

            self?.activityIndicator.stopAnimating()

            switch result {
            case .success(let user):
                self?.user = user
                self?.refreshUI()
            case .failure(let error):
                break
            }
        }
    }

    func refreshUI() {
        list.performUpdates {
            let section = IQSection(identifier: 0)
            list.append(section)

            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "User ID", detail: "\(user.id)")], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "First Name", detail: user.first_name)], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Last Name", detail: user.last_name)], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Email", detail: user.email)], section: section)
            list.append(IQTableViewCell.self, models: [IQTableViewCell.Model(text: "Avatar URL", detail: user.avatar?.absoluteString)], section: section)
        }
    }
}

extension UserViewController: IQListViewDelegateDataSource {
}
