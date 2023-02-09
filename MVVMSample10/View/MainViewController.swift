//
//  MainViewController.swift
//  MVVMSample10
//
//  Created by 鈴木楓香 on 2023/02/08.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var titleValidateLabel: UILabel!
    @IBOutlet weak var detailValidateLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    var viewModel: ViewModel!
    let disposeBag = DisposeBag()
    /// テキスト変更時に流す
    private let textViewSubject = PublishRelay<String?>()
    /// ViewModelに渡す際に必要
    var textViewObserver: Observable<String?> {
        return textViewSubject.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        viewModel = ViewModel()
        let input = ViewModelInput(titleTextField: titleTextField.rx.text.asObservable(), detailTextView: textViewObserver, registerButton: registerButton.rx.tap.asObservable())
        viewModel.setup(input: input, model: Model())
        
        // テキストが変更され場合のみバリデーションチェック
        // コードで変更の場合は考慮しない
        detailTextView.rx.didChange
            .subscribe(onNext: { [weak self] in
                self!.textViewSubject.accept(self!.detailTextView.text)
            })
            .disposed(by: disposeBag)
        // バリデーションラベル更新
        viewModel.outputs?.titleObservable
            .drive(titleValidateLabel.rx.text)
            .disposed(by: disposeBag)
        // バリデーションラベル更新
        viewModel.outputs?.detailObservable
            .drive(detailValidateLabel.rx.text)
            .disposed(by: disposeBag)
        // 登録ボタン更新
        viewModel.outputs?.isEnabledObservable
            .drive(registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        // 登録タップ後の更新
        viewModel.outputs?.registrationResultObservable
            .drive(onNext: { [weak self] in
                // AlertControllerに表示するタイトル
                var titleText: String!
                if $0 {
                    self!.resetTextView()
                    titleText = "登録が完了しました。"
                } else {
                    titleText = "登録に失敗しました。"
                }
                // AlertControllerを表示する
                let controller = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                self!.present(controller, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 登録時にTextの内容をリセットする
    private func resetTextView() {
        view.endEditing(true)
        titleTextField.text = ""
        detailTextView.text = ""
    }
    
    
}
