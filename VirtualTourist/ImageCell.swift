//
//  ColorCell
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imagePanel: UIImageView!
    
    @IBOutlet weak var indicatorDownloading: UIActivityIndicatorView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }


}
