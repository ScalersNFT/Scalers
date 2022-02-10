import UIKit

final class GameViewController: UIViewController {

    var presenter: GamePresenterProtocol?

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configurateCollectionView()
        presenter?.startGame()
    }

    private func configurateCollectionView() {
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

// MARK: - Presenter input communication
extension GameViewController: GameViewProtocol {

    func reloadCollection() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    func show(cards: [Card]) {
        for card in cards {
            let index = presenter?.index(for: card)
            let cell = collectionView.cellForItem(at: IndexPath(item: index!, section: 0)) as? CardCell
            DispatchQueue.main.async {
                cell?.show(animated: true)
            }
        }
    }

    func hide(cards: [Card]) {
        for card in cards {
            let index = presenter?.index(for: card)
            let cell = collectionView.cellForItem(at: IndexPath(item: index!, section: 0)) as? CardCell
            cell?.show(animated: true)
        }
    }

    func show(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.contentLabel.text = message
            self?.contentLabel.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                self?.contentLabel.isHidden = true
            })
        }
    }

    func show(content: String) {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = content
        }
    }

    func show(error: Error, completion: (() -> Swift.Void)? = nil) {
        present(error: error, animated: true, completion: completion )
    }

}

// MARK: - Data Source
extension GameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return presenter!.amountOfCards()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as? CardCell else {
            fatalError("Developer: Error casting CardCell")
        }
        cell.show(animated: false)
        guard let card = presenter?.card(at: indexPath.item) else { return cell }
        cell.card = card
        cell.backgroundColor = .clear
        return cell
    }

}

// MARK: - Collection Layout
extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let amountPerRow = CGFloat(Int(sqrt(Double(presenter!.amountOfCards()))))
        let interSpaces = (10*(amountPerRow-1))
        let availableSpace = collectionView.frame.width - interSpaces
        let itemWidth =  availableSpace / amountPerRow

        return CGSize(width: itemWidth, height: itemWidth)
    }

}

// MARK: - User Actions
extension GameViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else {
            fatalError("Developer: Error casting CardCell")
        }
        guard !cell.shown, let card = cell.card else { return }
        presenter?.didSelect(card: card)
    }

}
