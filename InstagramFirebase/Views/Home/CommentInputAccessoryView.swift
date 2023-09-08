//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 05.04.23.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextView() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //1
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 12),size: .init(width: 50, height: 50))
        //3 for safeAreaLayoutGuide
        addSubview(commentTextView)
        self.commentTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: submitButton.leadingAnchor, padding: .init(top: 8, left: 12, bottom: 8, right: 0))
        
        setupLineSeperatoriew()
    }
    
    //2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func setupLineSeperatoriew() {
        let lineSeperatorView = UIView()
        lineSeperatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeperatorView)
        lineSeperatorView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    @objc func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        delegate?.didSubmit(for: commentText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
