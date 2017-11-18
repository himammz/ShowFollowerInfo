//
//  ListTimelineViewController.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/18/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import Foundation
// ListTimelineViewController.swift
import UIKit
import TwitterKit

class ListTimelineViewController: TWTRTimelineViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient()
        self.dataSource = TWTRListTimelineDataSource(listSlug: "surfing", listOwnerScreenName: "stevenhepting", apiClient: client)
}
}
