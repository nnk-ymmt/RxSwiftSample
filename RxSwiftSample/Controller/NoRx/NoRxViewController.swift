//
//  NoRxViewController.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import UIKit

final class NoRxViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(TableViewCell.loadNib(), forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        }
    }

    private var previousText: String = ""
    private var startTime = Date()
    private var responseData: [GitHubModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // textFieldのdelegateにはテキストが変わった事を検知するdelegateが無いので自分で登録
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let searchWord = textField.text, !searchWord.isEmpty,
              searchWord != previousText, Date().timeIntervalSince(startTime) > 0.3 else { return }
        let isDesc = segmentedControl.selectedSegmentIndex == 0
        reload(searchWord: searchWord, isDesc: isDesc)
    }

    private func reload(searchWord: String, isDesc: Bool) {
        GitHubAPI.shared.get(searchWord: searchWord, isDesc: isDesc, success: { [weak self] models in
            self?.previousText = searchWord
            self?.startTime = Date()
            self?.responseData = models
            self?.tableView.reloadData()
        }, error: nil)
    }

    @IBAction private func changeSortType(_ sender: UISegmentedControl) {
        guard let searchWord = textField.text, !searchWord.isEmpty,
              Date().timeIntervalSince(startTime) > 0.3 else { return }
        let isDesc = segmentedControl.selectedSegmentIndex == 0
        reload(searchWord: searchWord, isDesc: isDesc)
    }
}

extension NoRxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gitHubModel = responseData[safe: indexPath.item],
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell
        else { return UITableViewCell() }
        cell.configure(gitHubModel: gitHubModel)
        return cell
    }
}
