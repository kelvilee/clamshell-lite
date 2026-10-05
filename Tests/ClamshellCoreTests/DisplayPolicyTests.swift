import Testing
@testable import ClamshellCore

@Test(arguments: [
    (true, true, false),
    (true, false, true),
    (false, true, true),
    (false, false, true),
])
func builtinShouldBeEnabled(autoEnabled: Bool, externalPresent: Bool, expected: Bool) {
    #expect(DisplayPolicy.builtinShouldBeEnabled(autoEnabled: autoEnabled, externalPresent: externalPresent) == expected)
}
