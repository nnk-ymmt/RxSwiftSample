//
//  GitHubAPI.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import Alamofire
import RxSwift
import Foundation

final class GitHubAPI {

    static let shared = GitHubAPI()
    private init() {}

    func get(searchWord: String, isDesc: Bool = true, success: (([GitHubModel]) -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        guard !searchWord.isEmpty else {
            success?([])
            return
        }
        AF.request("https://api.github.com/search/repositories?q=\(searchWord)&sort=stars&order=\(isDesc ? "desc" : "asc")").response { response in
            switch response.result {
            case .success:
                guard let data = response.data,
                      let gitHubResponse = try? JSONDecoder().decode(GitHubResponse.self, from: data),
                      let models = gitHubResponse.items else {
                    success?([])
                    return
                }
                success?(models)
            case .failure(let err):
                error?(err)
            }
        }
    }
}

// 自作のGitHubAPIクラスのfunctionをRx対応させる
extension GitHubAPI: ReactiveCompatible {}
extension Reactive where Base: GitHubAPI {
    func get(searchWord: String, isDesc: Bool = true) -> Observable<[GitHubModel]> {
        return Observable.create { observer in
            GitHubAPI.shared.get(searchWord: searchWord, isDesc: isDesc, success: { models in
                observer.on(.next(models))
            }, error: { err in
                observer.on(.error(err))
            })
            return Disposables.create()
        }.share(replay: 1, scope: .whileConnected)
    }
}
