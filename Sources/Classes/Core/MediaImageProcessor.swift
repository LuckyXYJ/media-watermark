//
//  MediaItemImage.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit

extension MediaProcessor {
    func processImageWithElements(item: MediaItem, completion: @escaping ProcessCompletionHandler) {
        if item.filter != nil {
            filterProcessor = FilterProcessor(mediaFilter: item.filter)
            filterProcessor.processImage(image: item.sourceImage.fixedOrientation(), completion: { [weak self] (success, finished, image, error) in
                if error != nil {
                    completion(MediaProcessResult(processedUrl: nil, image: nil), error)
                } else if image != nil && finished == true {
                    completion(MediaProcessResult(processedUrl: nil, image: image), nil)

                    let updatedMediaItem = MediaItem(image: image!)
                    updatedMediaItem.add(elements: item.mediaElements)
                    self?.processItemAfterFiltering(item: updatedMediaItem, completion: completion)
                }
            })
            
        } else {
            processItemAfterFiltering(item: item, completion: completion)
        }
    }
    
    func processItemAfterFiltering(item: MediaItem, completion: @escaping ProcessCompletionHandler) {
        // 新的渲染器配置
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = item.sourceImage.scale // 保留原图的scale
        rendererFormat.opaque = false // 设置背景是否不透明
        
        // 初始化一个renderer对象，传入大小和配置
        let renderer = UIGraphicsImageRenderer(size: item.sourceImage.size, format: rendererFormat)
        
        // 使用renderer的image方法生成新的图像
        let newImage = renderer.image { context in
            item.sourceImage.draw(in: CGRect(x: 0, y: 0, width: item.sourceImage.size.width, height: item.sourceImage.size.height))
            
            for element in item.mediaElements {
                switch element.type {
                case .view:
                    // 对于视图类型的元素，先将视图渲染为UIImage
                    UIImage(view: element.contentView)?.draw(in: element.frame)
                case .image:
                    // 对于图片类型的元素，直接将图片绘制到上下文
                    element.contentImage.draw(in: element.frame)
                case .text:
                    // 对于文本类型的元素，直接将文本绘制到上下文
                    element.contentText.draw(in: element.frame)
                }
            }
        }
        
        completion(MediaProcessResult(processedUrl: nil, image: newImage), nil)
    }
}
