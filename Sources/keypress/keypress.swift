import Foundation
import SwiftUI

let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
let loc = CGEventTapLocation.cghidEventTap

public enum keypress {
    enum KeyError: Error {
        case KeyNotFound
    }

    private static func check(_ key: String) throws {
        let key = key.lowercased()

        guard keyCode[key] != nil || ShiftKeyCode[key] != nil else {
            throw KeyError.KeyNotFound
        }
    }

    private static func isStringAnInt(_ string: String) -> Bool {
        return Int(string) != nil
    }

    private static func docheck(_ key: String) {
        do {
            try check(key)
        } catch KeyError.KeyNotFound {
            print("Key not found.")
        } catch {
            print("Unknown error.")
        }
    }

    public static func write(_ str: String) {
        for char in str {
            if String(char).containsWhitespace() {
                continue
            }
            docheck(String(char))
        }

        for char in str {
            if String(char).containsWhitespace() {
                let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode["space"]!), keyDown: true)
                let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode["space"]!), keyDown: false)
                key_down?.post(tap: loc)
                key_up?.post(tap: loc)

            } else if String(char).isUppercase, !isStringAnInt(String(char)), keyCode[String(char).lowercased()] != nil {
                let key_down_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: true)
                let key_up_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: false)
                let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[String(char).lowercased()]!), keyDown: true)
                let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[String(char).lowercased()]!), keyDown: false)
                key_down?.flags = CGEventFlags.maskShift
                key_down_shift?.post(tap: loc)
                key_down?.post(tap: loc)
                key_up?.post(tap: loc)
                key_up_shift?.post(tap: loc)

            } else if keyCode[String(char)] == nil {
                let key_down_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: true)
                let key_up_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: false)
                let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(ShiftKeyCode[String(char)]!), keyDown: true)
                let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(ShiftKeyCode[String(char)]!), keyDown: false)
                key_down?.flags = CGEventFlags.maskShift
                key_down_shift?.post(tap: loc)
                key_down?.post(tap: loc)
                key_up?.post(tap: loc)
                key_up_shift?.post(tap: loc)

            } else {
                let char_low = String(char).lowercased()
                let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[char_low]!), keyDown: true)
                let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[char_low]!), keyDown: false)
                key_down?.post(tap: loc)
                key_up?.post(tap: loc)
            }
        }
    }

    public static func press(_ key: String) {
        docheck(key)
        let key = key.lowercased()

        if keyCode[key] == nil {
            let key_down_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: true)
            let key_up_shift = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(0x38), keyDown: false)
            let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(ShiftKeyCode[key]!), keyDown: true)
            let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(ShiftKeyCode[key]!), keyDown: false)
            key_down?.flags = CGEventFlags.maskShift
            key_down_shift?.post(tap: loc)
            key_down?.post(tap: loc)
            key_up?.post(tap: loc)
            key_up_shift?.post(tap: loc)

        } else {
            let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[key]!), keyDown: true)
            let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[key]!), keyDown: false)

            key_down?.post(tap: loc)
            key_up?.post(tap: loc)
        }
    }

    public static func hotkey(_ with: String, _ key: String) {
        docheck(with)
        docheck(key)

        let key = key.lowercased()
        let with = with.lowercased()

        let key_down_with = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[with]!), keyDown: true)
        let key_up_with = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[with]!), keyDown: false)
        let key_down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[key]!), keyDown: true)
        let key_up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode[key]!), keyDown: false)

        switch with {
        case "command", "⌘", "cmd":
            key_down?.flags = CGEventFlags.maskCommand
        case "option", "⌥", "opt":
            key_down?.flags = CGEventFlags.maskAlternate
        case "shift", "⇧":
            key_down?.flags = CGEventFlags.maskShift
        case "control", "⌃", "ctrl":
            key_down?.flags = CGEventFlags.maskControl
        case "function", "fn":
            key_down?.flags = CGEventFlags.maskSecondaryFn
        case "capslock", "caps":
            key_down?.flags = CGEventFlags.maskAlphaShift
        default:
            print("\(with) key is not supported.")
        }

        key_down_with?.post(tap: loc)
        key_down?.post(tap: loc)
        key_up?.post(tap: loc)
        key_up_with?.post(tap: loc)
    }

    // Determine if a key is pressed.
    // If it is pressed, return true, else return false.
    public static func isPressed(_ key: String) -> Bool {
        docheck(key)

        let key_lower = key.lowercased()
        let key_code = CGKeyCode(keyCode[key_lower]!)
        let isPressed: Bool = CGEventSource.keyState(.combinedSessionState, key: key_code)
        return isPressed
    }
}

private extension String {
    func containsWhitespace() -> Bool {
        return rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }

    var isUppercase: Bool {
        return self == uppercased()
    }
}
