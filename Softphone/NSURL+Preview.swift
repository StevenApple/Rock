//  Created by Steven H.A on 11/18/14.
//

import Foundation

class HTMLParser
{
    var xmlParser: XMLParser?
    var html : String?
    
    func initWithUrl(_ url: URL)
    {
        self.xmlParser = XMLParser(contentsOf: url)
        
    }
}
