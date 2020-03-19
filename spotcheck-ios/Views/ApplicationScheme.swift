import MaterialComponents.MaterialContainerScheme
import MaterialComponents.MaterialColorScheme

class ApplicationScheme: NSObject {
    private static var singleton = ApplicationScheme()
    
    static var instance: ApplicationScheme {
        return singleton
    }
    
    override init() {
        self.containerScheme = MDCContainerScheme()
        self.containerScheme.colorScheme = self.colorScheme
        self.containerScheme.typographyScheme = self.typographyScheme
        
        super.init()
    }
    
    public var containerScheme: MDCContainerScheme
    
    private let typographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        let fontName = "Roboto"
        let lightFontName = "\(fontName)-Light"
        let regularFontName = "\(fontName)-Regular"
        let mediumFontName = "\(fontName)-Medium"
        
        scheme.headline1 = UIFont(name: lightFontName, size: 96)!
        scheme.headline2 = UIFont(name: lightFontName, size: 60)!
        scheme.headline3 = UIFont(name: regularFontName, size: 48)!
        scheme.headline4 = UIFont(name: regularFontName, size: 34)!
        scheme.headline5 = UIFont(name: regularFontName, size: 24)!
        scheme.headline6 = UIFont(name: mediumFontName, size: 20)!
        
        scheme.subtitle1 = UIFont(name: regularFontName, size: 16)!
        scheme.subtitle2 = UIFont(name: mediumFontName, size: 14)!
        
        scheme.body1 = UIFont(name: regularFontName, size: 16)!
        scheme.body2 = UIFont(name: regularFontName, size: 14)!
        
        scheme.button = UIFont(name: mediumFontName, size: 14)!
        
        scheme.caption = UIFont(name: regularFontName, size: 12)!
        
        scheme.overline = UIFont(name: regularFontName, size: 10)!
        
        return scheme
    }()
    
    private let colorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme()
        
        scheme.primaryColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)
        scheme.primaryColorVariant = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.00)
        scheme.onPrimaryColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        
        scheme.secondaryColor = UIColor(red: 0.19, green: 0.24, blue: 0.69, alpha: 1.00)
        scheme.onSecondaryColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        
        scheme.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
        scheme.onBackgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        
        scheme.errorColor = UIColor(red: 0.75, green: 0.00, blue: 0.22, alpha: 1.00)
        
        scheme.surfaceColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1)
        scheme.onSurfaceColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        
        return scheme
    }()
}
