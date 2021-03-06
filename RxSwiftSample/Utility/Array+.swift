//
//  Array+.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import Foundation
import UIKit

// 範囲外にアクセスしても落ちないでnilを返すためのextension
extension Array {
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < self.count ? self[index] : nil
    }
}
