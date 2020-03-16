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
}
