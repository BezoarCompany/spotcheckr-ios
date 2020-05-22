import MaterialComponents

class CollectionView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.collectionViewLayout = contentViewLayout
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
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        return view
    }()

    let contentViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8.0
        return layout
    }()
    let refreshControl = RefreshControl()
}
