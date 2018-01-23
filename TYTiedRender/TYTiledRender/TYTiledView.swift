import ImageIO
import UIKit

private let kDefaultTileSize: CGFloat = 256.0

protocol TYTiledViewDelegate: class {
}

protocol TYTiledBitmapViewDelegate: TYTiledViewDelegate {
    func tiledView(_ tiledView: TYTiledView, imageForRow row: Int, column: Int, scale: Int) -> UIImage
}

class TYTiledView: UIView {
    
    weak var delegate: TYTiledViewDelegate?
    var tileSize: CGFloat = 0
//    var numberOfZoomLevels = size_t()
    var cgSourceImage: CGImage? = nil
    var blockSize = CGSize.zero
    
    
    var totalCol: Int = 0
    var totalRow: Int = 0
    
    var lastColWidth: CGFloat =  0
    var lastRowHeight: CGFloat = 0
    
    private func tiledLayer() -> TYTiledLayer {
        return (layer as? TYTiledLayer)!
    }
    
    override class var layerClass: Swift.AnyClass{
        get {
            return TYTiledLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let scaledTileSize: CGSize = __CGSizeApplyAffineTransform(CGSize.init(width: kDefaultTileSize, height: kDefaultTileSize), CGAffineTransform.init(scaleX: self.contentScaleFactor, y: self.contentScaleFactor))
        tiledLayer().tileSize = scaledTileSize
        tiledLayer().levelsOfDetail = 1
        numberOfZoomLevels = 3
        //切片大小
        tileSize = kDefaultTileSize
        backgroundColor = UIColor.black
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    override func draw(_ rect: CGRect) {
        let ctx: CGContext? = UIGraphicsGetCurrentContext()
        let bounds: CGRect = rect
        //draw tile
        let blockSize: CGSize = self.blockSize
        let firstCol = Int(bounds.origin.x / blockSize.width)
        let lastCol = Int((bounds.origin.x + bounds.size.width) / blockSize.width - 1)
        
        let firstRow = Int(bounds.origin.y / blockSize.height)
        let lastRow = Int((bounds.origin.y + bounds.size.height) / blockSize.height - 1)
            //最后一列宽度
//        lastColWidth = bounds.size.width - CGFloat(lastCol-firstCol) * blockSize.width;
//        
//            //最后一行高度
//        lastRowHeight = bounds.size.height - CGFloat(lastRow-firstRow) * blockSize.height;
        
        //防止过度放大
        if (firstRow >= lastRow || firstCol >= lastCol) && (firstCol != totalCol - 1 && lastCol != totalCol - 1 && firstRow != totalRow - 1 && lastRow != totalRow - 1) {
            return
        }
        var i = 0
        for row in firstRow...lastRow {
            UIGraphicsPushContext(ctx!)
            for col in firstCol...lastCol {
                //load tile image
                let tileImage: UIImage? = prepareForSource(atCol: col, row: row)
                if tileImage == nil {
                    continue
                }
                let drawRect = CGRect(x: CGFloat(col * Int(blockSize.width)), y: CGFloat(row * Int(blockSize.height)), width: CGFloat(blockSize.width), height: CGFloat(blockSize.height))
                tileImage?.draw(in: drawRect)
//                log.info("\(NSStringFromCGRect(drawRect))")
                Thread.sleep(forTimeInterval: 0.005)
                i+=1
            }
            UIGraphicsPopContext()
        }
    }
    
    func prepareForSource(atCol col: Int, row: Int) -> UIImage? {
        var width = tileSize
        var height = tileSize
        //最后一列
        if col == totalCol-1 {
            width = lastColWidth
        }
        if row == totalRow-1 {
            height = lastRowHeight
        }
        
        if width == 0 || height == 0  {
            return nil
        }
        
        let tileImage: CGImage = cgSourceImage!.cropping(to: CGRect(x: CGFloat(
CGFloat(col) * tileSize), y: CGFloat(CGFloat(row) * tileSize), width: width, height: tileSize))!
        return UIImage(cgImage: tileImage)
    }
    
    var numberOfZoomLevels: size_t {
        get {
            return (self.layer as! CATiledLayer).levelsOfDetailBias
        }
        set {
            (self.layer as! CATiledLayer).levelsOfDetailBias = newValue
        }
        
    }
    
    
    
}
