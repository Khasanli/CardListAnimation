//
//  CardListViewController.swift
//
//  Created by Khayala Hasanli on 16.03.24.
//

import UIKit

class CardListViewController: UIViewController {
    
    private var cardsOpened: Bool = false
    private var initialSetUp: Bool = false
    
    private lazy var cardsView: UIView = {
        let cardsView = UIView()
        cardsView.backgroundColor = .clear
        return cardsView
    }()

    var leadingConstraints: [NSLayoutConstraint] = []
    var trailingConstraints: [NSLayoutConstraint] = []
    var topConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCards()
        
    }

    private func setupCards() {
        view.addSubview(cardsView)
        cardsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            cardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        addCardsToCardsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialAnimation()
    }
    
    private func initialAnimation() {
        
        guard initialSetUp else {
            initialSetUp = true
            return
        }
        
        for (index, cardView) in cardsView.subviews.enumerated() {
            let initialSideOffset = 20 + CGFloat(leadingConstraints.count - 1 - index) * 7
            let cardOverlap: CGFloat = 20
            let initialTopOffset = CGFloat(index) * cardOverlap
            leadingConstraints[index].constant = initialSideOffset
            trailingConstraints[index].constant = -initialSideOffset
            topConstraints[index].constant = initialTopOffset
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                cardView.transform = CGAffineTransform.identity
            })
        }
    }
    
    private func addCardsToCardsView() {
        let numberOfCards = 4
        for i in 0...numberOfCards  {
            let cardOverlap: CGFloat = 20
            let cardHeight: CGFloat = 200
            let sideOffset = cardOverlap + CGFloat(numberOfCards - i) * 7
            let cardView = createCardView(index: i)
            cardsView.addSubview(cardView)
            let yOffset = (CGFloat(i) * cardOverlap)
            let leadingConstraint = cardView.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor, constant: sideOffset)
            let trailingConstraint = cardView.trailingAnchor.constraint(equalTo: cardsView.trailingAnchor, constant: -sideOffset)
            let topConstraint = cardView.topAnchor.constraint(equalTo: cardsView.topAnchor, constant: yOffset)
            
            NSLayoutConstraint.activate([
                topConstraint,
                leadingConstraint,
                trailingConstraint,
                cardView.heightAnchor.constraint(equalToConstant: cardHeight)
            ])
            
            topConstraints.append(topConstraint)
            leadingConstraints.append(leadingConstraint)
            trailingConstraints.append(trailingConstraint)
            
            let cardViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTappped(_:)))
            cardView.tag = i
            cardView.addGestureRecognizer(cardViewTapGesture)
            
            let initialTransform = CGAffineTransform(translationX: 0, y: -100)
            cardView.transform = initialTransform
            
            UIView.animate(withDuration: 0.5, delay: Double(numberOfCards - i) * 0.1, options: [.curveEaseOut], animations: {
                cardView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            cardView.addGestureRecognizer(tapGesture)
        }
    }
    
    private func createCardView(index: Int) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.random()
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 10
        return cardView
    }
    
    @objc func cardTappped(_ gesture: UITapGestureRecognizer) {
        guard let selectedCardView = gesture.view else { return }
        for cardView in cardsView.subviews {
            if cardView == selectedCardView {
                let tag : Int = selectedCardView.tag
                
                UIView.animate(withDuration: 0.4) { [weak self] in
                    guard let self else { return }
                    leadingConstraints[tag].constant = leadingConstraints.last?.constant ?? 0
                    trailingConstraints[tag].constant = trailingConstraints.last?.constant ?? 0
                    topConstraints[tag].constant = 40
                    
                    view.layoutIfNeeded()
                    cardView.transform = .identity

                } completion: { [weak self] _ in
                    guard let self else { return }
                    let detailVC = CardDetailViewController()
                    detailVC.modalPresentationStyle = .fullScreen
                    detailVC.cardColor = selectedCardView.backgroundColor
                    present(detailVC, animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.4) { [weak self] in
                    guard let self else { return }
                    cardView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                }
            }
        }
    }
    
    @objc func handleCardTap(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view?.superview)
        let yPercentage = translation.y / (gesture.view?.superview?.frame.height ?? 1)
        let yOffset = 60 * yPercentage
        let numberOfCards = 4
        
        switch gesture.state {
        case .changed:
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                guard let self else { return }
                for i in 0...numberOfCards {
                    
                    let subview = cardsView.subviews[i]
                    var transform = CATransform3DIdentity
                    transform.m34 = -1.0 / 400
                    
                     
                    if yOffset > 0 || cardsOpened {
                        let adjustedYOffset = yOffset < 0 ? 30 + yOffset : yOffset
                        transform = CATransform3DTranslate(transform, 0, adjustedYOffset * CGFloat(i + 1), 0)
                        let normalizedFactor = min(max(abs(yOffset) / 30, 0), 1)
                        let finalNormalizedFactor = yOffset > 0 ? normalizedFactor : (1 - normalizedFactor)
                        let maxRotationRadians = CGFloat.pi / 12
                        let rotationAngle = -1 * maxRotationRadians * finalNormalizedFactor
                        
                        transform = CATransform3DRotate(transform, rotationAngle, 1, 0, 0)
                        subview.layer.transform = transform
                    }
                }
            })
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                for i in 0...numberOfCards {
                    let subview = cardsView.subviews[i]
                    
                    var combinedTransform = CATransform3DIdentity
                    combinedTransform.m34 = -1.0 / 400
                    
                    let translationY = yOffset > 20 ? 30 * CGFloat(i + 1) : 0
                    combinedTransform = CATransform3DTranslate(combinedTransform, 0, translationY, 0)
                 
                    if yOffset > 20 {
                        combinedTransform = CATransform3DRotate(combinedTransform, -CGFloat.pi / 12, 1, 0, 0)
                        cardsOpened = true
                    } else {
                        cardsOpened = false
                    }
                    
                    subview.layer.transform = combinedTransform
                }
            }
        default:
            break
        }
    }
}


