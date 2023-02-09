//
//  Model.swift
//  MVVMSample10
//
//  Created by 鈴木楓香 on 2023/02/08.
//

import Foundation
import RxSwift
import RxCocoa

enum ModelError: LocalizedError {
    enum TitleError: LocalizedError {
        case empty
        case tooCharacters
        
        var errorDescription: String? {
            switch self {
            case .empty:
                return "タイトルを入力してください。"
            case .tooCharacters:
                return "10文字以内で入力してください。"
            }
        }
    }
    
    enum DetailError: LocalizedError {
        case empty
        case tooCharacters
        case lessCharacters
        
        var errorDescription: String? {
            switch self {
            case .empty:
                return "本文を入力してください。"
            case .tooCharacters:
                return "10文字以内で入力してください。"
            case .lessCharacters:
                return "5文字以上で入力してください。"
            }
        }
    }
    
}

protocol ModelProtocol {
    /// エラーチェック
    /// - Parameter titleText: 対象テキスト
    /// - Returns: 正常の場合はnil
    func titleValidate(titleText: String?) -> Observable<Void>
    /// エラーチェック
    /// - Parameter detailText: 対象テキスト
    /// - Returns: 正常の場合はnil
    func detailValidate(detailText: String?) -> Observable<Void>
}

final class Model: ModelProtocol {
    func titleValidate(titleText: String?) -> Observable<Void> {
        switch titleText {
        case .none: return Observable.error(ModelError.TitleError.empty)
        case let titleText?:
            // 全てスペースの場合はエラーを返す
            switch titleText.trimmingCharacters(in: .whitespaces).isEmpty {
            case true:
                return Observable.error(ModelError.TitleError.empty)
            case false:
                switch titleText.count {
                case (let count) where count > 10:
                    return Observable.error(ModelError.TitleError.tooCharacters)
                    // 正常の場合
                default: return Observable.just(())
                }
            }
        }
    }
    
    func detailValidate(detailText: String?) -> Observable<Void> {
        switch detailText {
        case .none: return Observable.error(ModelError.DetailError.empty)
        case let detailText?:
            // 全てスペースの場合はエラーを返す
            switch detailText.trimmingCharacters(in: .whitespaces).isEmpty {
            case true:
                return Observable.error(ModelError.DetailError.empty)
            case false:
                switch detailText.count {
                case (let count) where count < 5:
                    return Observable.error(ModelError.DetailError.lessCharacters)
                case (let count) where count > 10:
                    return Observable.error(ModelError.DetailError.tooCharacters)
                    // 正常の場合
                default: return Observable.just(())
                }
            }
        }
    }
    
    
}
