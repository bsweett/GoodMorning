//
//  XMLParser.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-18.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class XMLParser: NSObject {
    
    func checkValidRSSChannel(xml: AEXMLDocument, type: RSSType, url: String) -> RSSFeed? {
        
        var title = xml.root["channel"]["title"].stringValue
        var link = xml.root["channel"]["link"].stringValue
        var lastBuild = xml.root["channel"]["lastBuildDate"].stringValue
        var description = xml.root["channel"]["description"].stringValue
        var language = xml.root["channel"]["language"].stringValue
        
        var activeDate: NSDate!
        if(lastBuild.rangeOfString("not found") == nil) {
            activeDate = NSDate().dateFromInternetDateTimeString(lastBuild, formatHint: .RFC822)
        } else {
            activeDate = NSDate()
        }
        
        var imageURL = xml.root["channel"]["image"]["url"].stringValue
        
        if title.rangeOfString("not found") != nil || link.rangeOfString("not found") != nil {
            return nil
        }
        
        if description.rangeOfString("not found") != nil {
            description = "unknown"
        }
        
        if language.rangeOfString("not found") != nil {
            language = "en"
        }
        
        var rss = RSSFeed(title: title, creation: NSDate(), lastActiveDate: activeDate, type: type, description: description, language: language, link: link, rssLink: url)
        
        if imageURL.rangeOfString("not found") != nil {
            rss.setLogoUrl("")
        } else {
            rss.setLogoUrl(imageURL)
        }
        
        return rss
    }
    
    func parseArticles(xml: AEXMLDocument) -> Dictionary<String, RSSArticle> {
        
        var articles: Dictionary<String, RSSArticle> = Dictionary<String, RSSArticle>()
        
            // do something in the background
            if let items = xml.root["channel"]["item"].all {
                
                for article in items {
                    var rssArticle: RSSArticle = RSSArticle()
                    
                    var title = article["title"].stringValue
                    var link = article["link"].stringValue
                    var descriptionRaw = article["description"].stringValue
                    var nsRawDes: NSString = descriptionRaw
                    
                    if let catergories = article["category"].all {
                        for category in catergories {
                            
                            rssArticle.addCategory(category.value!)
                            
                        }
                    }
                    
                    var pubString = article["pubDate"].stringValue
                    var creator = article["dc:creator"].stringValue
                    
                    rssArticle.title = title
                    rssArticle.link = link
                    rssArticle.rawDescription = descriptionRaw
                    rssArticle.pubdate = NSDate().dateFromInternetDateTimeString(pubString, formatHint: .RFC822)
                    rssArticle.creator = creator
                    rssArticle.textDescription = nsRawDes.stringByConvertingHTMLToPlainText()
                        
                        //String().fromHtmlEncodedString(descriptionRaw) //getDescriptionTextFromHTML(descriptionRaw)
                    rssArticle.thumbnailURL = self.getThumbNailUrlFromRaw(descriptionRaw)
                    
                    // TODO: check null on elements and add to article
                    // add article to map
                    
                    articles[rssArticle.title] = rssArticle
                }
            }

        
        return articles
    }

    func getDescriptionTextFromHTML(html: String) -> String {
        let str = html.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        return str
    }
    

    func getThumbNailUrlFromRaw(html: String) -> String {
        
        // Note: using an HTML parser that doesn't support XHTML tags
        //let removedInset = html.stringByReplacingOccurrencesOfString("<inset[^>]*>.*?</inset>", withString: "", options: .RegularExpressionSearch, range: nil)
        //let strippedHtml = removedInset.stringByReplacingOccurrencesOfString("</img>", withString: "", range: nil)
        
        //let newHtml = "<html><head></head><body>" + strippedHtml + "</body>"
        
        //let str = matchesForRegexInText("<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>", text: html)
        /*
        if(str.count > 0) {
            return str[0]
        }*/
        
        var url: NSString? = ""
        var theScanner = NSScanner(string: html)
        // find start of IMG tag
        theScanner.scanUpToString("<img", intoString:nil)
        
        if (!theScanner.atEnd) {
            
            theScanner.scanUpToString("src", intoString: nil)
            var charset = NSCharacterSet(charactersInString: "\"'")
            theScanner.scanUpToCharactersFromSet(charset, intoString: nil)
            theScanner.scanCharactersFromSet(charset, intoString: nil)
            theScanner.scanUpToCharactersFromSet(charset, intoString: &url)
            // "url" now contains the URL of the img
            if (url != nil) {
                return url!
            } else {
                return ""
            }
        }
        
        /*
        var err : NSError?
        var parser = HTMLParser(html: newHtml, error: &err)
        if err != nil {
            println(err)
            return ""
        }
        
        var bodyNode = parser.body
        
        if let inputNodes = bodyNode?.findChildTags("img") {
            var src = inputNodes[0].getAttributeNamed("src")
            return src
        }*/
        
        return ""
    }
    
    /*
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        let regex = NSRegularExpression(pattern: regex,
            options: nil, error: nil)!
        let nsString = text as NSString
        let results = regex.matchesInString(nsString,
            options: nil, range: NSMakeRange(0, nsString.length))
            as [NSTextCheckingResult]
        return map(results) { nsString.substringWithRange($0.range)}
    }*/

}
