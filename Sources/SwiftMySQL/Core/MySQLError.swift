public enum MysqlError: Error {
    case NotConnected;
    case AlreadyConnected;
    case Error(error: String, errno : UInt32);
}
