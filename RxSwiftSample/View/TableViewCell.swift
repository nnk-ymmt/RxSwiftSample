//
//  TableViewCell.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import UIKit

final class TableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!

    static let reuseIdentifier: String = "TableViewCell"
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        urlLabel.text = nil
    }

    func configure(gitHubModel: GitHubModel) {
        titleLabel.text = gitHubModel.name
        urlLabel.text = gitHubModel.urlStr
    }
}
