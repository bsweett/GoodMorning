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
        
        if let items = xml.root["channel"]["item"].all {
            
            for article in items {
                var rssArticle: RSSArticle = RSSArticle()
                
                var title = article["title"].stringValue
                var link = article["link"].stringValue
                var descriptionRaw = article["description"].stringValue
                
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
                rssArticle.textDescription = String().fromHtmlEncodedString(descriptionRaw) //getDescriptionTextFromHTML(descriptionRaw)
                rssArticle.thumbnailURL = getThumbNailUrlFromRaw(descriptionRaw)
                
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
        let removedInset = html.stringByReplacingOccurrencesOfString("<inset[^>]*>.*?</inset>", withString: "", options: .RegularExpressionSearch, range: nil)
        let strippedHtml = removedInset.stringByReplacingOccurrencesOfString("</img>", withString: "", range: nil)
        
        let newHtml = "<html><head></head><body>" + strippedHtml + "</body>"
        
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
        }
        
        return ""
    }

}
