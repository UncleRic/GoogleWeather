//
//  OptionList.swift
//  GoogleWeather
//
//  Created by Frederick C. Lee on 2/6/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

import UIKit

class GoogleTableViewController: UITableViewController, OptionProtocol {
    var optionList: OptionsStruct?
    
    override func viewDidLoad() {
        tableView.isScrollEnabled = false
        tableView.rowHeight = 40.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.sizeToFit()
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let optionCount = optionList?.availableOptions.count {
            return optionCount
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier:nil)
        if let optionDestription = optionList?.availableOptions[indexPath.row].description() {
            cell.textLabel?.text = optionDestription
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return optionList?.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = ["sender":self]
        NotificationCenter.default.post(name: optionNotification, object: indexPath.row, userInfo: userInfo)
    }
}


