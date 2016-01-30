import Foundation

extension String {
    func replace(pattern: String, template: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        return regex.stringByReplacingMatchesInString(self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
    }
}
