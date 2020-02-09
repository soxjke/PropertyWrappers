//
//  ViewController.swift
//  PropertyWrappers
//
//  Created by Petro Korienev on 2/9/20.
//  Copyright © 2020 PetroKorienev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    
    private(set) var data: [GithubAPI.Response.Model] = []
    
    @Debounced(0.5)
    private(set) var searchTerm: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        $searchTerm.on { [weak self] (term) in
            self?.searchGithub(term: term)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GithubRepoCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].full_name
        cell.detailTextLabel?.text = "⭐️ \(data[indexPath.row].stargazers_count)"
        return cell
    }
}

extension ViewController {
    @objc func textDidChange(_ sender: UITextField) {
        searchTerm = sender.text
        // alternatively:
        // $searchTerm.receive(sender.text ?? "")
    }
    private func searchGithub(term: String) {
        GithubAPI.search(term: term) { [weak self] result in
            switch (result) {
            case .success(let models): self?.onSuccess(models)
            case .failure(let error): self?.onError(error)
            }
        }
    }
    private func onSuccess(_ models: [GithubAPI.Response.Model]) {
        DispatchQueue.main.async {
            self.data = models
            self.tableView.reloadData()
        }
    }
    private func onError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorLabel.text = (error as NSError).localizedDescription
            self.errorLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.errorLabel.isHidden = true
            }
        }
    }
}

