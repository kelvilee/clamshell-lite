public enum DisplayPolicy {
    public static func builtinShouldBeEnabled(autoEnabled: Bool, externalPresent: Bool) -> Bool {
        !(autoEnabled && externalPresent)
    }
}
