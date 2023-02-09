//
//  ViewModel.swift
//  MVVMSample10
//
//  Created by 鈴木楓香 on 2023/02/08.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

struct ViewModelInput {
    let titleTextField: Observable<String?>
    let detailTextView: Observable<String?>
    let registerButton: Observable<Void>
}

protocol ViewModelOutput {
    var titleObservable: Driver<String> { get }
    var detailObservable: Driver<String> { get }
    var isEnabledObservable: Driver<Bool> { get }
    var registrationResultObservable: Driver<Bool> { get }
}

protocol ViewModelType {
    var outputs: ViewModelOutput? { get }
    /// 初期設定
    /// - Parameter input: ViewModelInput構造体
    /// - Parameter model: 実行するModelクラス
    func setup(input: ViewModelInput, model: Model)
}

class ViewModel: ViewModelType {
    
    var outputs: ViewModelOutput?
    var titleValidation: Observable<String>!
    var detailValidation: Observable<String>!
    var isButtonEnabled: Observable<Bool>!
    var registrationResult: Observable<Bool>!
    
    init() {
        self.outputs = self
    }
    
    func setup(input: ViewModelInput, model: Model) {
        // バリデーション結果を返す
        let titleEvent = input.titleTextField
            .skip(1)
            .flatMap { titleText -> Observable<Event<Void>> in
                return model.titleValidate(titleText: titleText)
                    .materialize()
            }
        
        // バリデーション結果を返す
        let detailEvent = input.detailTextView
            .skip(1)
            .flatMap { detailText -> Observable<Event<Void>> in
                return model.detailValidate(detailText: detailText)
                    .materialize()
            }
        
        // イベントに応じたエラー処理を行う
        titleValidation = titleEvent
            .flatMap { event -> Observable<String> in
                switch event {
                    // 正常の場合は空欄
                case .next: return .just("")
                    // エラーの場合に文言を返す
                case let .error(error as ModelError.TitleError):
                    return .just(error.localizedDescription)
                case .error, .completed: return .empty()
                }
            }
            .startWith("")
        
        // イベントに応じたエラー処理を行う
        detailValidation = detailEvent
            .flatMap { event -> Observable<String> in
                switch event {
                    // 正常の場合は空欄
                case .next: return .just("")
                    // エラーの場合に文言を返す
                case let .error(error as ModelError.DetailError):
                    return .just(error.localizedDescription)
                case .error, .completed: return .empty()
                }
            }
            .startWith("")
        
        // TitleとDetailの両方の結果から登録ボタンを使用するか判定
        isButtonEnabled = Observable.combineLatest(titleEvent, detailEvent)
            .flatMap { (titleEvent, detailEvent) -> Observable<Bool> in
                let isRegisterEnabled:Bool = titleEvent.event.error == nil && detailEvent.event.error == nil
                
                return Observable<Bool>.create { observer in
                    observer.on(.next(isRegisterEnabled))
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            .startWith(false)
        
        // 登録ボタンをタップした際の処理
        registrationResult = input.registerButton
            .flatMap { _ -> Observable<Bool> in
                // DBに登録する処理が入る
                // successとfilerを判定してBool値を返す
                return Observable<Bool>.create { observer in
                    observer.on(.next(true))
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
    }
    
    
}


// MARK: - ViewModelOutput

extension ViewModel: ViewModelOutput {
    var titleObservable: Driver<String> {
        return titleValidation
            .asDriver(onErrorJustReturn: "")
    }
    
    var detailObservable: Driver<String> {
        return detailValidation
            .asDriver(onErrorJustReturn: "")
    }
    
    var isEnabledObservable: Driver<Bool> {
        return isButtonEnabled
            .asDriver(onErrorJustReturn: false)
    }
    
    var registrationResultObservable: Driver<Bool> {
        return registrationResult
            .asDriver(onErrorJustReturn: false)
    }
    
    
    
}
