import Foundation

extension String {
    func replace(pattern: String, template: String) -> String {
#if os(Linux)
        let regex = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive);
        return regex.stringByReplacingMatchesInString(self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
#elseif os(OSX)
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive);
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
#endif
    }
}
