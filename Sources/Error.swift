public enum MysqlError: ErrorType {
    case NotConnected;
    case AlreadyConnected;
    case Error(error: String, errno : UInt32);
}
