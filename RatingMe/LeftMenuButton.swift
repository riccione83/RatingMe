//
//  LeftMenuButton.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 22/02/16.
//  Copyright (c) 2016 Riccardo Rizzo. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

public class LeftMenuButton : NSObject {

    //// Drawing Methods

    public class func drawButtonMenu(numOfMessage numOfMessage: CGFloat = 0, numberOfMessages: String = "0") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let color = UIColor(red: 0.133, green: 0.454, blue: 0.833, alpha: 1.000)
        let color2 = UIColor(red: 0.320, green: 0.728, blue: 0.800, alpha: 1.000)
        var color2RedComponent: CGFloat = 1,
            color2GreenComponent: CGFloat = 1,
            color2BlueComponent: CGFloat = 1
        color2.getRed(&color2RedComponent, green: &color2GreenComponent, blue: &color2BlueComponent, alpha: nil)

        let top = UIColor(red: (color2RedComponent * 0.3 + 0.7), green: (color2GreenComponent * 0.3 + 0.7), blue: (color2BlueComponent * 0.3 + 0.7), alpha: (CGColorGetAlpha(color2.CGColor) * 0.3 + 0.7))
        let bottom = UIColor(red: (color2RedComponent * 1), green: (color2GreenComponent * 1), blue: (color2BlueComponent * 1), alpha: (CGColorGetAlpha(color2.CGColor) * 1 + 0))

        //// Gradient Declarations
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [bottom.CGColor, top.CGColor], [0, 1])!

        //// Variable Declarations
        let messageBoxVisible = numOfMessage > 0

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath()
        rectanglePath.moveToPoint(CGPointMake(1, 5))
        rectanglePath.addCurveToPoint(CGPointMake(2, 7), controlPoint1: CGPointMake(1, 6), controlPoint2: CGPointMake(2, 7))
        rectanglePath.addLineToPoint(CGPointMake(28, 7))
        rectanglePath.addCurveToPoint(CGPointMake(29, 5), controlPoint1: CGPointMake(28, 7), controlPoint2: CGPointMake(29, 6))
        rectanglePath.addCurveToPoint(CGPointMake(28, 3), controlPoint1: CGPointMake(29, 4), controlPoint2: CGPointMake(28, 3))
        rectanglePath.addLineToPoint(CGPointMake(2, 3))
        rectanglePath.addCurveToPoint(CGPointMake(1, 5), controlPoint1: CGPointMake(2, 3), controlPoint2: CGPointMake(1, 4))
        rectanglePath.closePath()
        color.setFill()
        rectanglePath.fill()


        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath()
        rectangle2Path.moveToPoint(CGPointMake(1, 15.5))
        rectangle2Path.addCurveToPoint(CGPointMake(2, 17.5), controlPoint1: CGPointMake(1, 16.5), controlPoint2: CGPointMake(2, 17.5))
        rectangle2Path.addLineToPoint(CGPointMake(28, 17.5))
        rectangle2Path.addCurveToPoint(CGPointMake(29, 15.5), controlPoint1: CGPointMake(28, 17.5), controlPoint2: CGPointMake(29, 16.5))
        rectangle2Path.addCurveToPoint(CGPointMake(28, 13.5), controlPoint1: CGPointMake(29, 14.5), controlPoint2: CGPointMake(28, 13.5))
        rectangle2Path.addLineToPoint(CGPointMake(2, 13.5))
        rectangle2Path.addCurveToPoint(CGPointMake(1, 15.5), controlPoint1: CGPointMake(2, 13.5), controlPoint2: CGPointMake(1, 14.5))
        rectangle2Path.closePath()
        color.setFill()
        rectangle2Path.fill()


        //// Rectangle 3 Drawing
        let rectangle3Path = UIBezierPath()
        rectangle3Path.moveToPoint(CGPointMake(1, 26))
        rectangle3Path.addCurveToPoint(CGPointMake(2, 28), controlPoint1: CGPointMake(1, 27), controlPoint2: CGPointMake(2, 28))
        rectangle3Path.addLineToPoint(CGPointMake(28, 28))
        rectangle3Path.addCurveToPoint(CGPointMake(29, 26), controlPoint1: CGPointMake(28, 28), controlPoint2: CGPointMake(29, 27))
        rectangle3Path.addCurveToPoint(CGPointMake(28, 24), controlPoint1: CGPointMake(29, 25), controlPoint2: CGPointMake(28, 24))
        rectangle3Path.addLineToPoint(CGPointMake(2, 24))
        rectangle3Path.addCurveToPoint(CGPointMake(1, 26), controlPoint1: CGPointMake(2, 24), controlPoint2: CGPointMake(1, 25))
        rectangle3Path.closePath()
        color.setFill()
        rectangle3Path.fill()


        if (messageBoxVisible) {
            //// Oval Drawing
            let ovalPath = UIBezierPath(ovalInRect: CGRectMake(2, 3.24, 26, 25.26))
            CGContextSaveGState(context)
            ovalPath.addClip()
            CGContextDrawLinearGradient(context, gradient, CGPointMake(15, 3.24), CGPointMake(15, 28.5), CGGradientDrawingOptions())
            CGContextRestoreGState(context)
            color2.setStroke()
            ovalPath.lineWidth = 1
            ovalPath.stroke()


            //// Oval 2 Drawing
            let oval2Path = UIBezierPath()
            oval2Path.moveToPoint(CGPointMake(4.76, 13.31))
            oval2Path.addCurveToPoint(CGPointMake(15.5, 5.5), controlPoint1: CGPointMake(5.86, 8.84), controlPoint2: CGPointMake(10.25, 5.5))
            oval2Path.lineCapStyle = .Round;

            top.setStroke()
            oval2Path.lineWidth = 1
            oval2Path.stroke()


            //// Text Drawing
            let textRect = CGRectMake(5.38, 9.19, 19, 13.37)
            let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .Center

            let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(UIFont.labelFontSize()), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: textStyle]

            let textTextHeight: CGFloat = NSString(string: numberOfMessages).boundingRectWithSize(CGSizeMake(textRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
            CGContextSaveGState(context)
            CGContextClipToRect(context, textRect);
            NSString(string: numberOfMessages).drawInRect(CGRectMake(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight), withAttributes: textFontAttributes)
            CGContextRestoreGState(context)
        }
    }

    //// Generated Images

    public class func imageOfButtonMenu(numOfMessage numOfMessage: CGFloat = 0, numberOfMessages: String = "0") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), false, 0)
            LeftMenuButton.drawButtonMenu(numOfMessage: numOfMessage, numberOfMessages: numberOfMessages)

        let imageOfButtonMenu = UIGraphicsGetImageFromCurrentImageContext().imageWithRenderingMode(.AlwaysOriginal)
        UIGraphicsEndImageContext()

        return imageOfButtonMenu
    }

}
