import Foundation

#if os(Linux)
class Thread
{
    init(_ callback : () -> Void) {
        let thread = NSThread(){
            callback();
        };
        thread.start();
    }
}
#elseif os(OSX)
    class Thread: NSObject
    {
        private var thread: NSThread?
        private var callback: (() -> Void)?

        init(_ callback : () -> Void) {
            super.init()
            self.callback = callback

            self.thread = NSThread(target: self, selector: #selector(Thread.invoke), object: nil);
            thread?.start();
        }

        func invoke() {
            self.callback?()

            // Discard callback and timer.
            self.callback = nil
            self.thread = nil
        }
    }
#endif
