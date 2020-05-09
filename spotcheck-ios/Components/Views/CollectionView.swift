import MaterialComponents

class CollectionView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func attachRefreshControl() {
        if !refreshControl.isDescendant(of: contentView) {
            contentView.addSubview(refreshControl)
            NSLayoutConstraint.activate([
                refreshControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ])
        }
    }
    let contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8.0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        return view
    }()
    
    let refreshControl = RefreshControl()
}
