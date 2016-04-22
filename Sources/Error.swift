public enum MysqlError: ErrorProtocol {
    case NotConnected;
    case AlreadyConnected;
    case Error(error: String, errno : UInt32);
}
