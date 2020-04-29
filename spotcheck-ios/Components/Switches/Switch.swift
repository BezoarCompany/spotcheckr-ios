import UIKit

class Switch: UIView {
    let content: UISwitch = {
        let element = UISwitch()
        element.translatesAutoresizingMaskIntoConstraints = false
        element.onTintColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        return element
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(content)
        NSLayoutConstraint.activate([
//            content.centerXAnchor.constraint(equalTo: centerXAnchor),
//            content.centerYAnchor.constraint(equalTo: centerYAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])
    }
}
