import MaterialComponents
import SVGKit
class Images {
    static let chevronUp = UIImageView(SVGNamed: "chevron-up") {
        (svgLayer) in
        svgLayer.fillColor = .none
        svgLayer.strokeColor = UIColor.white.cgColor
    }
    
    static let chevronDown = UIImageView(SVGNamed: "chevron-down") {
        (svgLayer) in
        svgLayer.fillColor = .none
        svgLayer.strokeColor = UIColor.white.cgColor
    }
    
    static let list = SVGKImage(named: "list").uiImage.withRenderingMode(.alwaysTemplate)
    static let user = SVGKImage(named: "user").uiImage.withRenderingMode(.alwaysTemplate)
    static let moreHorizontal = SVGKImage(named: "more-horizontal").uiImage.withRenderingMode(.alwaysTemplate)
    static let trash = SVGKImage(named: "trash-2").uiImage.withRenderingMode(.alwaysTemplate)
    static let back = SVGKImage(named: "chevron-left").uiImage.withRenderingMode(.alwaysTemplate)
    static let logOut = SVGKImage(named: "log-out").uiImage.withRenderingMode(.alwaysTemplate)
    static let reply = SVGKImage(named: "reply").uiImage.withRenderingMode(.alwaysTemplate)
    static let plus = SVGKImage(named: "plus").uiImage.withRenderingMode(.alwaysTemplate)
    static let arrowUp = SVGKImage(named: "arrow-up").uiImage.withRenderingMode(.alwaysTemplate)
    static let arrowDown = SVGKImage(named: "arrow-down").uiImage.withRenderingMode(.alwaysTemplate)
    static let profilePictureDefault = SVGKImage(named: "account-circle").uiImage.withRenderingMode(.alwaysTemplate)
}
