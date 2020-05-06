import MaterialComponents

class AnswerCell: CardCollectionCell {
    lazy var widthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        widthConstraint.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func applyConstraints() {
        dividerLeadingConstraint = cellDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([

//        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//        thumbnailImageView.widthAnchor.constraint(equalToConstant: 40),
//        thumbnailImageView.heightAnchor.constraint(equalToConstant: 40),

        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

        subHeadLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
        subHeadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

        supportingTextLabel.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        supportingTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        supportingTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

        votingControls.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 4),
        dividerLeadingConstraint!,
        cellDivider.topAnchor.constraint(equalTo: votingControls.bottomAnchor, constant: 4),
        contentView.trailingAnchor.constraint(equalTo: cellDivider.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: cellDivider.bottomAnchor)
        ])
    }
}
