//
//  RxNoMvvmViewController.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import NSObject_Rx
import RxCocoa
import RxOptional
import RxSwift
import UIKit

final class RxNoMvvmViewController: UIViewController, HasDisposeBag {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(TableViewCell.loadNib(), forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        }
    }

    private var responseData: [GitHubModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // 文字列のストリーム (1)
        let searchWordObservable = textField.rx.text
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged().filterNil()

        // ソートのストリーム (2)
        // 初回読み込み時または変化があれば、segmentedControlのindexをストリームに流す
        let sortTypeObservable = Observable.merge(
            Observable.just(segmentedControl.selectedSegmentIndex),
            segmentedControl.rx.controlEvent(.valueChanged).map { self.segmentedControl.selectedSegmentIndex }
        ).map { $0 == 0 }

        // (1), (2)を合成してストリームに値がきたらAPIを叩いてテーブルをリロード
        let getAPIObservable = Observable.combineLatest(searchWordObservable, sortTypeObservable)
            .flatMapLatest { searchWord, sortType -> Observable<[GitHubModel]> in
                GitHubAPI.shared.rx.get(searchWord: searchWord, isDesc: sortType)
            }

        //購買する
        getAPIObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
            self?.responseData = models
            self?.tableView.reloadData()
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: disposeBag)

        // この書き方だとUITableViewDataSourceがいらなくなる
        getAPIObservable.subscribeOn(MainScheduler.instance)
            .bind(to: self.tableView.rx.items(cellIdentifier: TableViewCell.reuseIdentifier, cellType: TableViewCell.self)) { _, element, cell in
                guard let cell = cell as? TableViewCell else { return }
                cell.configure(gitHubModel: element)
            }.disposed(by: disposeBag)
    }
}

//extension RxNoMvvmViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return responseData.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let gitHubModel = responseData[safe: indexPath.item],
//            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell
//        else { return UITableViewCell() }
//        cell.configure(gitHubModel: gitHubModel)
//        return cell
//    }
//}
