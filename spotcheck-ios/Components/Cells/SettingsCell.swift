import UIKit
import MaterialComponents

class SettingsCell: UICollectionViewCell {
    private let baseCell: MDCSelfSizingStereoCell = {
        let cell = MDCSelfSizingStereoCell()
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.isUserInteractionEnabled = false
        return cell
    }()

    let switchView: Switch = {
        let view = Switch()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var titleLabel: UILabel {
        get {
            return UILabel()
        }
        set(value) {
            baseCell.titleLabel.text = value.text
        }
    }
    var detailLabel: UILabel {
        get {
            return UILabel()
        }
        set(value) {
            baseCell.detailLabel.text = value.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        applyConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(baseCell)
        addSubview(switchView)
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            baseCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseCell.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: baseCell.bottomAnchor),
            baseCell.trailingAnchor.constraint(equalTo: switchView.leadingAnchor),
            switchView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            bottomAnchor.constraint(equalTo: switchView.bottomAnchor),
            trailingAnchor.constraint(equalTo: switchView.trailingAnchor, constant: 16)
        ])
    }
}
