//
//  RxMvvmViewController.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import NSObject_Rx
import RxSwift
import UIKit

final class RxMvvmViewController: UIViewController, HasDisposeBag {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(TableViewCell.loadNib(), forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        }
    }

    //ViewModelの書き方のひとつで、input,outputを明確に分けた書き方
    private let viewModel = MvvmViewModel()
    private lazy var input: MvvmViewModelInput = viewModel
    private lazy var output: MvvmViewModelOutput = viewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        //inputとoutputのストリームを決める
        bindInputStream()
        bindOutputStream()
    }

    //viewModelの中に流すストリーム
    private func bindInputStream() {
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

        // inputのプロパティと繋げる(bindはそのまま値をストリームに流す)
        searchWordObservable.bind(to: input.searchTextObserver).disposed(by: disposeBag)
        sortTypeObservable.bind(to: input.sortTypeObserver).disposed(by: disposeBag)
    }

    // viewModelからくるストリーム
    private func bindOutputStream() {
        // outputの「modelsに変化があったよ」というストリームが流れてきたらテーブルを更新
        output.changeModelsObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: {
            self.tableView.reloadData()
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
}

extension RxMvvmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // outputの中にmodelsがある
        return output.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let githubModel = output.models[safe: indexPath.item],
              let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell
        else { return UITableViewCell() }
        cell.configure(gitHubModel: githubModel)
        return cell
    }
}
