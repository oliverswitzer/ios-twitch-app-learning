//
//  ViewController.swift
//  learning
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var channelTextField: UITextField!
    @IBOutlet var tableView: UITableView!

    let service: TwitchCollectorService
    var emotes: [Emote] = []

    init(service: TwitchCollectorService) {
        self.service = service

        super.init(nibName: "ViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        channelTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emotes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let emote = emotes[indexPath.row]
        cell.textLabel?.text = "\(emote.name) \(emote.count)"

        return cell
    }

    // MARK: UITextFieldDelegate

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        service.emotes(channelName: textField.text ?? "", success: { emotes in
            self.emotes = emotes.sorted { $0.count >= $1.count }
            self.tableView.reloadData()
        }, error: { _ in

        })

        return true
    }

}
