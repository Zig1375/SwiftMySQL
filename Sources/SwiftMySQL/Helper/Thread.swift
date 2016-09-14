import Foundation

#if os(Linux)
typealias zThread = Thread;
#elseif os(OSX)
    class zThread: NSObject
    {
        private var thread: Thread?
        private var callback: (() -> Void)?;

        init(block : @escaping(() -> Void)) {
            super.init()
            self.callback = block;

            self.thread = Thread(target: self, selector: #selector(zThread.invoke), object: nil);
        }

        func start() {
            self.thread?.start();
        }

        func invoke() {
            self.callback?()

            // Discard callback and timer.
            self.callback = nil
            self.thread = nil
        }
    }
#endif
