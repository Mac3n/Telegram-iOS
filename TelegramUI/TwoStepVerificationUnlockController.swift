import Foundation
import Display
import SwiftSignalKit
import Postbox
import TelegramCore

private final class TwoStepVerificationUnlockSettingsControllerArguments {
    let updatePasswordText: (String) -> Void
    let checkPassword: () -> Void
    let openForgotPassword: () -> Void
    let openSetupPassword: () -> Void
    let openDisablePassword: () -> Void
    let openSetupEmail: () -> Void
    let openResetPendingEmail: () -> Void
    let updateEmailAddress: (String) -> Void
    let updateEmailCode: (String) -> Void
    
    init(updatePasswordText: @escaping (String) -> Void, checkPassword: @escaping () -> Void, openForgotPassword: @escaping () -> Void, openSetupPassword: @escaping () -> Void, openDisablePassword: @escaping () -> Void, openSetupEmail: @escaping () -> Void, openResetPendingEmail: @escaping () -> Void, updateEmailAddress: @escaping (String) -> Void, updateEmailCode: @escaping (String) -> Void) {
        self.updatePasswordText = updatePasswordText
        self.checkPassword = checkPassword
        self.openForgotPassword = openForgotPassword
        self.openSetupPassword = openSetupPassword
        self.openDisablePassword = openDisablePassword
        self.openSetupEmail = openSetupEmail
        self.openResetPendingEmail = openResetPendingEmail
        self.updateEmailAddress = updateEmailAddress
        self.updateEmailCode = updateEmailCode
    }
}

private enum TwoStepVerificationUnlockSettingsSection: Int32 {
    case password
    case email
}

private enum TwoStepVerificationUnlockSettingsEntryTag: ItemListItemTag {
    case password
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        if let other = other as? TwoStepVerificationUnlockSettingsEntryTag {
            switch self {
                case .password:
                    if case .password = other {
                        return true
                    } else {
                        return false
                    }
            }
        } else {
            return false
        }
    }
}

private enum TwoStepVerificationUnlockSettingsEntry: ItemListNodeEntry {
    case passwordEntry(PresentationTheme, String, String)
    case passwordEntryInfo(PresentationTheme, String)
    
    case passwordSetup(PresentationTheme, String)
    case passwordSetupInfo(PresentationTheme, String)
    
    case changePassword(PresentationTheme, String)
    case turnPasswordOff(PresentationTheme, String)
    case setupRecoveryEmail(PresentationTheme, String)
    case passwordInfo(PresentationTheme, String)
    
    case pendingEmailConfirmInfo(PresentationTheme, String)
    case pendingEmailConfirmAddress(PresentationTheme, String, String)
    case pendingEmailConfirmCode(PresentationTheme, String, String)
    case pendingEmailInfo(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
            case .pendingEmailConfirmInfo, .pendingEmailConfirmAddress, .pendingEmailConfirmCode:
                return TwoStepVerificationUnlockSettingsSection.email.rawValue
            default:
                return TwoStepVerificationUnlockSettingsSection.password.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
            case .passwordEntry:
                return 0
            case .passwordEntryInfo:
                return 1
            case .passwordSetup:
                return 2
            case .passwordSetupInfo:
                return 3
            case .changePassword:
                return 4
            case .turnPasswordOff:
                return 5
            case .setupRecoveryEmail:
                return 6
            case .passwordInfo:
                return 7
            case .pendingEmailConfirmInfo:
                return 8
            case .pendingEmailConfirmAddress:
                return 9
            case .pendingEmailConfirmCode:
                return 10
            case .pendingEmailInfo:
                return 11
        }
    }
    
    static func <(lhs: TwoStepVerificationUnlockSettingsEntry, rhs: TwoStepVerificationUnlockSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(_ arguments: TwoStepVerificationUnlockSettingsControllerArguments) -> ListViewItem {
        switch self {
            case let .passwordEntry(theme, text, value):
                return ItemListSingleLineInputItem(theme: theme, title: NSAttributedString(string: text, textColor: theme.list.itemPrimaryTextColor), text: value, placeholder: "", type: .password, spacing: 10.0, tag: TwoStepVerificationUnlockSettingsEntryTag.password, sectionId: self.section, textUpdated: { updatedText in
                    arguments.updatePasswordText(updatedText)
                }, action: {
                    arguments.checkPassword()
                })
            case let .passwordEntryInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .markdown(text), sectionId: self.section, linkAction: { action in
                    switch action {
                        case .tap:
                            arguments.openForgotPassword()
                    }
                })
            case let .passwordSetup(theme, text):
                return ItemListActionItem(theme: theme, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                    arguments.openSetupPassword()
                })
            case let .passwordSetupInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .markdown(text), sectionId: self.section)
            case let .changePassword(theme, text):
                return ItemListActionItem(theme: theme, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                    arguments.openSetupPassword()
                })
            case let .turnPasswordOff(theme, text):
                return ItemListActionItem(theme: theme, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                    arguments.openDisablePassword()
                })
            case let .setupRecoveryEmail(theme, text):
                return ItemListActionItem(theme: theme, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                    arguments.openSetupEmail()
                })
            case let .passwordInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
            case let .pendingEmailConfirmInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
            case let .pendingEmailConfirmAddress(theme, title, text):
                return ItemListSingleLineInputItem(theme: theme, title: NSAttributedString(string: ""), text: text, placeholder: title, type: .email, sectionId: self.section, textUpdated: { value in
                    arguments.updateEmailAddress(value)
                }, action: {})
            case let .pendingEmailConfirmCode(theme, title, text):
                return ItemListSingleLineInputItem(theme: theme, title: NSAttributedString(string: ""), text: text, placeholder: title, type: .number, sectionId: self.section, textUpdated: { value in
                    arguments.updateEmailCode(value)
                }, action: {})
            case let .pendingEmailInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .markdown(text), sectionId: self.section, linkAction: { action in
                    switch action {
                        case .tap:
                            arguments.openResetPendingEmail()
                    }
                })
        }
    }
}

private struct TwoStepVerificationUnlockSettingsControllerState: Equatable {
    var passwordText: String = ""
    var checking: Bool = false
    var emailAddress: String = ""
    var emailCode: String = ""
}

private func twoStepVerificationUnlockSettingsControllerEntries(presentationData: PresentationData, state: TwoStepVerificationUnlockSettingsControllerState, data: TwoStepVerificationUnlockSettingsControllerData) -> [TwoStepVerificationUnlockSettingsEntry] {
    var entries: [TwoStepVerificationUnlockSettingsEntry] = []
    
    switch data {
        case let .access(configuration):
            if let configuration = configuration {
                switch configuration {
                    case let .notSet(pendingEmailAndValue):
                        if let pendingEmailAndValue = pendingEmailAndValue {
                            /*entries.append(.pendingEmailConfirmInfo(presentationData.theme, presentationData.strings.TwoStepAuth_EmailSent))
                            if pendingEmailAndValue.email != nil {
                            } else {
                                entries.append(.pendingEmailConfirmAddress(presentationData.theme, presentationData.strings.TwoStepAuth_EmailTitle, state.emailAddress))
                            }
                            entries.append(.pendingEmailConfirmCode(presentationData.theme, presentationData.strings.TwoStepAuth_RecoveryCode, state.emailCode))
                             entries.append(.pendingEmailInfo(presentationData.theme, "[" + presentationData.strings.TwoStepAuth_ConfirmationAbort + "]()"))
                             */
                            entries.append(.pendingEmailInfo(presentationData.theme, presentationData.strings.TwoStepAuth_ConfirmationText + "\n\n\(pendingEmailAndValue.pendingEmail.pattern)\n\n[" + presentationData.strings.TwoStepAuth_ConfirmationAbort + "]()"))
                        } else {
                            entries.append(.passwordSetup(presentationData.theme, presentationData.strings.TwoStepAuth_SetPassword))
                            entries.append(.passwordSetupInfo(presentationData.theme, presentationData.strings.TwoStepAuth_SetPasswordHelp))
                        }
                    case let .set(hint, _, _):
                        entries.append(.passwordEntry(presentationData.theme, presentationData.strings.TwoStepAuth_EnterPasswordPassword, state.passwordText))
                        if hint.isEmpty {
                            entries.append(.passwordEntryInfo(presentationData.theme, presentationData.strings.TwoStepAuth_EnterPasswordHelp + "\n\n[" + presentationData.strings.TwoStepAuth_EnterPasswordForgot + "](forgot)"))
                        } else {
                            entries.append(.passwordEntryInfo(presentationData.theme, presentationData.strings.TwoStepAuth_EnterPasswordHint(escapedPlaintextForMarkdown(hint)).0 + "\n\n" + presentationData.strings.TwoStepAuth_EnterPasswordHelp + "\n\n[" + presentationData.strings.TwoStepAuth_EnterPasswordForgot + "](forgot)"))
                        }
                }
            }
        case let .manage(_, emailSet, pendingEmailAndValue, _):
            entries.append(.changePassword(presentationData.theme, presentationData.strings.TwoStepAuth_ChangePassword))
            entries.append(.turnPasswordOff(presentationData.theme, presentationData.strings.TwoStepAuth_RemovePassword))
            entries.append(.setupRecoveryEmail(presentationData.theme, emailSet ? presentationData.strings.TwoStepAuth_ChangeEmail : presentationData.strings.TwoStepAuth_SetupEmail))
            if let pendingEmailAndValue = pendingEmailAndValue {
                /*entries.append(.pendingEmailConfirmInfo(presentationData.theme, presentationData.strings.TwoStepAuth_EmailSent))
                if pendingEmailAndValue.email != nil {
                } else {
                    entries.append(.pendingEmailConfirmAddress(presentationData.theme, presentationData.strings.TwoStepAuth_EmailTitle, state.emailAddress))
                }
                entries.append(.pendingEmailConfirmCode(presentationData.theme, presentationData.strings.TwoStepAuth_RecoveryCode, state.emailCode))*/
                //entries.append(.pendingEmailInfo(presentationData.theme, presentationData.strings.TwoStepAuth_ConfirmationText + "\n\n\(pendingEmailAndValue.pendingEmail.pattern)\n\n[" + presentationData.strings.TwoStepAuth_ConfirmationAbort + "]()"))
                entries.append(.pendingEmailInfo(presentationData.theme, presentationData.strings.TwoStepAuth_EmailSent))
            } else {
                entries.append(.passwordInfo(presentationData.theme, presentationData.strings.TwoStepAuth_GenericHelp))
            }
    }
    
    return entries
}

struct PendingEmailAndValue {
    let pendingEmail: TwoStepVerificationPendingEmail
    let email: String?
}

extension PendingEmailAndValue {
    init?(pendingEmail: TwoStepVerificationPendingEmail?) {
        if let pendingEmail = pendingEmail {
            self.init(pendingEmail: pendingEmail, email: nil)
        } else {
            return nil
        }
    }
}

enum TwoStepVerificationUnlockSettingsControllerMode {
    case access
    case manage(password: String, email: String, pendingEmail: PendingEmailAndValue?, hasSecureValues: Bool)
}

private enum TwoStepVeriticationAccessConfiguration {
    case notSet(pendingEmail: PendingEmailAndValue?)
    case set(hint: String, hasRecoveryEmail: Bool, hasSecureValues: Bool)
    
    init(configuration: TwoStepVerificationConfiguration) {
        switch configuration {
            case let .notSet(pendingEmail):
                self = .notSet(pendingEmail: PendingEmailAndValue(pendingEmail: pendingEmail))
            case let .set(hint, hasRecoveryEmail, _, hasSecureValues):
                self = .set(hint: hint, hasRecoveryEmail: hasRecoveryEmail, hasSecureValues: hasSecureValues)
        }
    }
}

private enum TwoStepVerificationUnlockSettingsControllerData {
    case access(configuration: TwoStepVeriticationAccessConfiguration?)
    case manage(password: String, emailSet: Bool, pendingEmail: PendingEmailAndValue?, hasSecureValues: Bool)
}

func twoStepVerificationUnlockSettingsController(account: Account, mode: TwoStepVerificationUnlockSettingsControllerMode) -> ViewController {
    let initialState = TwoStepVerificationUnlockSettingsControllerState()
    
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((TwoStepVerificationUnlockSettingsControllerState) -> TwoStepVerificationUnlockSettingsControllerState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    var replaceControllerImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController, ViewControllerPresentationArguments?) -> Void)?
    
    let actionsDisposable = DisposableSet()
    
    let checkDisposable = MetaDisposable()
    actionsDisposable.add(checkDisposable)
    
    let setupDisposable = MetaDisposable()
    actionsDisposable.add(setupDisposable)
    
    let setupResultDisposable = MetaDisposable()
    actionsDisposable.add(setupResultDisposable)
    
    let dataPromise = Promise<TwoStepVerificationUnlockSettingsControllerData>()
    
    switch mode {
        case .access:
            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: nil))
            |> then(twoStepVerificationConfiguration(account: account) |> map { TwoStepVerificationUnlockSettingsControllerData.access(configuration: TwoStepVeriticationAccessConfiguration(configuration: $0)) }))
        case let .manage(password, email, pendingEmail, hasSecureValues):
            dataPromise.set(.single(.manage(password: password, emailSet: !email.isEmpty, pendingEmail: pendingEmail, hasSecureValues: hasSecureValues)))
    }
    
    let arguments = TwoStepVerificationUnlockSettingsControllerArguments(updatePasswordText: { updatedText in
        updateState { state in
            var state = state
            state.passwordText = updatedText
            return state
        }
    }, checkPassword: {
        var wasChecking = false
        var password: String?
        updateState { state in
            var state = state
            wasChecking = state.checking
            password = state.passwordText
            state.checking = true
            return state
        }
        
        if let password = password, !password.isEmpty, !wasChecking {
            checkDisposable.set((requestTwoStepVerifiationSettings(network: account.network, password: password)
            |> mapToSignal { settings -> Signal<(TwoStepVerificationSettings, TwoStepVerificationPendingEmail?), AuthorizationPasswordVerificationError> in
                return twoStepVerificationConfiguration(account: account)
                |> mapError { _ -> AuthorizationPasswordVerificationError in
                    return .generic
                }
                |> map { configuration in
                    var pendingEmail: TwoStepVerificationPendingEmail?
                    if case let .set(configuration) = configuration {
                        pendingEmail = configuration.pendingEmail
                    }
                    return (settings, pendingEmail)
                }
            }
            |> deliverOnMainQueue).start(next: { settings, pendingEmail in
                updateState { state in
                    var state = state
                    state.checking = false
                    return state
                }
                
                replaceControllerImpl?(twoStepVerificationUnlockSettingsController(account: account, mode: .manage(password: password, email: settings.email, pendingEmail: PendingEmailAndValue(pendingEmail: pendingEmail), hasSecureValues: settings.secureSecret != nil)))
            }, error: { error in
                updateState { state in
                    var state = state
                    state.checking = false
                    return state
                }
                
                let presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
                
                let text: String
                switch error {
                    case .limitExceeded:
                        text = presentationData.strings.LoginPassword_FloodError
                    case .invalidPassword:
                        text = presentationData.strings.LoginPassword_InvalidPasswordError
                    case .generic:
                        text = presentationData.strings.Login_UnknownError
                }
                
                presentControllerImpl?(standardTextAlertController(theme: AlertControllerTheme(presentationTheme: presentationData.theme), title: nil, text: text, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
            }))
        }
    }, openForgotPassword: {
        setupDisposable.set((dataPromise.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { data in
            switch data {
                case let .access(configuration):
                    if let configuration = configuration {
                        let presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
                        switch configuration {
                            case let .set(_, hasRecoveryEmail, _):
                                if hasRecoveryEmail {
                                    updateState { state in
                                        var state = state
                                        state.checking = true
                                        return state
                                    }
                                    setupResultDisposable.set((requestTwoStepVerificationPasswordRecoveryCode(network: account.network)
                                    |> deliverOnMainQueue).start(next: { emailPattern in
                                        updateState { state in
                                            var state = state
                                            state.checking = false
                                            return state
                                        }
                                        
                                        var completionImpl: (() -> Void)?
                                        let controller = resetPasswordController(account: account, emailPattern: emailPattern, completion: {
                                            completionImpl?()
                                        })
                                        completionImpl = { [weak controller] in
                                            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: nil))))
                                            controller?.view.endEditing(true)
                                            controller?.dismiss()
                                        }
                                        presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                                    }, error: { _ in
                                        updateState { state in
                                            var state = state
                                            state.checking = false
                                            return state
                                        }
                                        presentControllerImpl?(standardTextAlertController(theme: AlertControllerTheme(presentationTheme: presentationData.theme), title: nil, text: presentationData.strings.Login_UnknownError, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                                    }))
                                } else {
                                    presentControllerImpl?(standardTextAlertController(theme: AlertControllerTheme(presentationTheme: presentationData.theme), title: nil, text: presentationData.strings.TwoStepAuth_RecoveryUnavailable, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                                }
                            case .notSet:
                                break
                        }
                    }
                case .manage:
                    break
            }
        }))
    }, openSetupPassword: {
        setupDisposable.set((dataPromise.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { data in
            switch data {
                case let .access(configuration):
                    if let configuration = configuration {
                        switch configuration {
                            case .notSet:
                                var completionImpl: ((String, String, Bool) -> Void)?
                                var updatePatternImpl: (((String, String)?) -> Void)?
                                let controller = createPasswordController(account: account, context: .account, state: .setup(currentPassword: nil), completion: { password, hint, emailPattern in
                                    completionImpl?(password, hint, emailPattern)
                                }, updatePasswordEmailConfirmation: { pattern in
                                    updatePatternImpl?(pattern)
                                }, processPasswordEmailConfirmation: false)
                                presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                                completionImpl = { [weak controller] password, hint, hasRecovery in
                                    dataPromise.set(.single(.manage(password: password, emailSet: hasRecovery, pendingEmail: nil, hasSecureValues: false)))
                                    controller?.view.endEditing(true)
                                    controller?.dismiss()
                                }
                            
                                updatePatternImpl = { [weak controller] pattern in
                                    if let (email, pattern) = pattern {
                                        dataPromise.set(.single(.access(configuration: .notSet(pendingEmail: PendingEmailAndValue(pendingEmail: TwoStepVerificationPendingEmail(pattern: pattern, codeLength: nil), email: email)))))
                                    } else {
                                        dataPromise.set(.single(.access(configuration: .notSet(pendingEmail: nil))))
                                    }
                                    controller?.view.endEditing(true)
                                    controller?.dismiss()
                                }
                            case .set:
                                break
                        }
                    }
                case let .manage(password, hasRecovery, pendingEmail, hasSecureValues):
                    var completionImpl: ((String, String, Bool) -> Void)?
                    var updatePatternImpl: (((String, String)?) -> Void)?
                    let controller = createPasswordController(account: account, context: .account, state: .setup(currentPassword: password), completion: { password, hint, emailPattern in
                        completionImpl?(password, hint, emailPattern)
                    }, updatePasswordEmailConfirmation: { pattern in
                        updatePatternImpl?(pattern)
                    }, processPasswordEmailConfirmation: false)
                    presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                    completionImpl = { [weak controller] password, hint, _ in
                        dataPromise.set(.single(.manage(password: password, emailSet: hasRecovery, pendingEmail: pendingEmail, hasSecureValues: hasSecureValues)))
                        controller?.view.endEditing(true)
                        controller?.dismiss()
                    }
                    
                    updatePatternImpl = { [weak controller] pattern in
                        if let (email, pattern) = pattern {
                            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: PendingEmailAndValue(pendingEmail: TwoStepVerificationPendingEmail(pattern: pattern, codeLength: nil), email: email)))))
                        } else {
                            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: nil))))
                        }
                        controller?.view.endEditing(true)
                        controller?.dismiss()
                    }
            }
        }))
    }, openDisablePassword: {
        setupDisposable.set((dataPromise.get() |> take(1) |> deliverOnMainQueue).start(next: { data in
            switch data {
                case let .manage(_, _, _, hasSecureValues):
                    let presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
                    var text = presentationData.strings.TwoStepAuth_PasswordRemoveConfirmation
                    if hasSecureValues {
                        text = presentationData.strings.TwoStepAuth_PasswordRemovePassportConfirmation
                    }
                    presentControllerImpl?(standardTextAlertController(theme: AlertControllerTheme(presentationTheme: presentationData.theme), title: nil, text: text, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_Cancel, action: {}), TextAlertAction(type: .genericAction, title: presentationData.strings.Common_OK, action: {
                        var disablePassword = false
                        updateState { state in
                            var state = state
                            if state.checking {
                                return state
                            } else {
                                disablePassword = true
                                state.checking = true
                                return state
                            }
                        }
                        if disablePassword {
                            setupDisposable.set((dataPromise.get()
                            |> take(1)
                            |> mapError { _ -> UpdateTwoStepVerificationPasswordError in return .generic }
                            |> mapToSignal { data -> Signal<Void, UpdateTwoStepVerificationPasswordError> in
                                switch data {
                                case .access:
                                    return .complete()
                                case let .manage(password, _, _, _):
                                    return updateTwoStepVerificationPassword(network: account.network, currentPassword: password, updatedPassword: .none)
                                        |> mapToSignal { _ -> Signal<Void, UpdateTwoStepVerificationPasswordError> in
                                            return .complete()
                                        }
                                }
                            }
                            |> deliverOnMainQueue).start(error: { _ in
                                updateState { state in
                                    var state = state
                                    state.checking = false
                                    return state
                                }
                            }, completed: {
                                updateState { state in
                                    var state = state
                                    state.checking = false
                                    return state
                                }
                                dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: nil))))
                            }))
                        }
                    })]), ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                default:
                    break
            }
        }))
    }, openSetupEmail: {
        setupDisposable.set((dataPromise.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { data in
            switch data {
                case .access:
                    break
                case let .manage(password, _, _, hasSecureValues):
                    let result = Promise<TwoStepVerificationPasswordEntryResult?>()
                    let controller = twoStepVerificationPasswordEntryController(account: account, mode: .setupEmail(password: password), result: result)
                    presentControllerImpl?(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
                    setupResultDisposable.set((result.get() |> take(1) |> deliverOnMainQueue).start(next: { [weak controller] updatedPassword in
                        if let updatedPassword = updatedPassword {
                            dataPromise.set(.single(.manage(password: updatedPassword.password, emailSet: true, pendingEmail: updatedPassword.pendingEmail, hasSecureValues: hasSecureValues)))
                            controller?.dismiss()
                        }
                    }))
            }
        }))
    }, openResetPendingEmail: {
        updateState { state in
            var state = state
            state.checking = true
            return state
        }
        setupDisposable.set((updateTwoStepVerificationPassword(network: account.network, currentPassword: nil, updatedPassword: .none)
        |> deliverOnMainQueue).start(next: { _ in
            updateState { state in
                var state = state
                state.checking = false
                return state
            }
            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: nil))))
        }, error: { _ in
            updateState { state in
                var state = state
                state.checking = false
                return state
            }
        }))
    }, updateEmailAddress: { value in
        updateState { state in
            var state = state
            state.emailAddress = value
            return state
        }
    }, updateEmailCode: { value in
        updateState { state in
            var state = state
            state.emailCode = value
            return state
        }
    })
    
    let checkEmailConfirmation: () -> Void = {
        let _ = (dataPromise.get()
        |> take(1)
        |> deliverOnMainQueue).start(next: { data in
            var pendingEmailData: PendingEmailAndValue?
            switch data {
                case let .access(configuration):
                    guard let configuration = configuration else {
                        return
                    }
                    switch configuration {
                        case let .notSet(pendingEmail):
                            pendingEmailData = pendingEmail
                        case .set:
                            break
                    }
                case let .manage(_, _, pendingEmail, _):
                    pendingEmailData = pendingEmail
            }
            if let pendingEmailAndValue = pendingEmailData {
                var emailAndCode: (String, String)?
                updateState { state in
                    var state = state
                    if !state.checking {
                        emailAndCode = (pendingEmailAndValue.email ?? state.emailAddress, state.emailCode)
                        state.checking = true
                    }
                    return state
                }
                if let (email, code) = emailAndCode {
                    setupDisposable.set((confirmTwoStepRecoveryEmail(network: account.network, email: email, code: code)
                    |> deliverOnMainQueue).start(error: { error in
                        updateState { state in
                            var state = state
                            state.checking = false
                            return state
                        }
                        let presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
                        let text: String
                        switch error {
                            case .invalidEmail:
                                text = presentationData.strings.TwoStepAuth_EmailInvalid
                            case .invalidCode:
                                text = presentationData.strings.Login_InvalidCodeError
                            case .expired:
                                text = presentationData.strings.TwoStepAuth_EmailCodeExpired
                                let _ = (dataPromise.get()
                                |> take(1)
                                |> deliverOnMainQueue).start(next: { data in
                                    switch data {
                                        case .access:
                                            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.access(configuration: .notSet(pendingEmail: nil))))
                                        case let .manage(manage):
                                            dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.manage(password: manage.password, emailSet: false, pendingEmail: nil, hasSecureValues: manage.hasSecureValues)))
                                    }
                                    
                                    updateState { state in
                                        var state = state
                                        state.checking = false
                                        state.emailAddress = ""
                                        state.emailCode = ""
                                        return state
                                    }
                                })
                            case .flood:
                                text = presentationData.strings.TwoStepAuth_FloodError
                            case .generic:
                                text = presentationData.strings.Login_UnknownError
                        }
                        presentControllerImpl?(standardTextAlertController(theme: AlertControllerTheme(presentationTheme: presentationData.theme), title: nil, text: text, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Common_OK, action: {})]), nil)
                    }, completed: {
                        let _ = (dataPromise.get()
                        |> take(1)
                        |> deliverOnMainQueue).start(next: { data in
                            switch data {
                                case .access:
                                    dataPromise.set(.single(.access(configuration: nil))
                                    |> then(twoStepVerificationConfiguration(account: account) |> map { TwoStepVerificationUnlockSettingsControllerData.access(configuration: TwoStepVeriticationAccessConfiguration(configuration: $0)) }))
                                case let .manage(manage):
                                    dataPromise.set(.single(TwoStepVerificationUnlockSettingsControllerData.manage(password: manage.password, emailSet: true, pendingEmail: nil, hasSecureValues: manage.hasSecureValues)))
                            }
                            
                            updateState { state in
                                var state = state
                                state.checking = false
                                state.emailAddress = ""
                                state.emailCode = ""
                                return state
                            }
                        })
                    }))
                }
            }
        })
    }
    
    var initialFocusImpl: (() -> Void)?
    var didAppear = false
    
    let signal = combineLatest((account.applicationContext as! TelegramApplicationContext).presentationData, statePromise.get(), dataPromise.get() |> deliverOnMainQueue) |> deliverOnMainQueue
    |> map { presentationData, state, data -> (ItemListControllerState, (ItemListNodeState<TwoStepVerificationUnlockSettingsEntry>, TwoStepVerificationUnlockSettingsEntry.ItemGenerationArguments)) in
        var rightNavigationButton: ItemListNavigationButton?
        var emptyStateItem: ItemListControllerEmptyStateItem?
        let title: String
        switch data {
            case let .access(configuration):
                title = presentationData.strings.TwoStepAuth_Title
                if let configuration = configuration {
                    if state.checking {
                        rightNavigationButton = ItemListNavigationButton(content: .none, style: .activity, enabled: true, action: {})
                    } else {
                        switch configuration {
                            case let .notSet(pendingEmail):
                                /*if let pendingEmailAndValue = pendingEmail {
                                    rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Next), style: .bold, enabled: (pendingEmailAndValue.email != nil || !state.emailAddress.isEmpty) && !state.emailCode.isEmpty, action: {
                                        checkEmailConfirmation()
                                    })
                                }*/
                                break
                            case .set:
                                rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Next), style: .bold, enabled: true, action: {
                                    arguments.checkPassword()
                                })
                        }
                    }
                } else {
                    emptyStateItem = ItemListLoadingIndicatorEmptyStateItem(theme: presentationData.theme)
                }
            case let .manage(manage):
                title = presentationData.strings.PrivacySettings_TwoStepAuth
                if state.checking {
                    rightNavigationButton = ItemListNavigationButton(content: .none, style: .activity, enabled: true, action: {})
                } else {
                    /*if let pendingEmailAndValue = manage.pendingEmail {
                        rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Common_Next), style: .bold, enabled: (pendingEmailAndValue.email != nil || !state.emailAddress.isEmpty) && !state.emailCode.isEmpty, action: {
                            checkEmailConfirmation()
                        })
                    }*/
                }
        }
        
        let controllerState = ItemListControllerState(theme: presentationData.theme, title: .text(title), leftNavigationButton: nil, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back), animateChanges: false)
        let listState = ItemListNodeState(entries: twoStepVerificationUnlockSettingsControllerEntries(presentationData: presentationData, state: state, data: data), style: .blocks, focusItemTag: didAppear ? TwoStepVerificationUnlockSettingsEntryTag.password : nil, emptyStateItem: emptyStateItem, animateChanges: false)
        
        return (controllerState, (listState, arguments))
    }
    |> afterDisposed {
            actionsDisposable.dispose()
    }
    
    let controller = ItemListController(account: account, state: signal)
    replaceControllerImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.replaceTopController(c, animated: true)
    }
    presentControllerImpl = { [weak controller] c, p in
        if let controller = controller {
            controller.present(c, in: .window(.root), with: p)
        }
    }
    initialFocusImpl = { [weak controller] in
        guard let controller = controller, controller.didAppearOnce else {
            return
        }
        var resultItemNode: ItemListSingleLineInputItemNode?
        let _ = controller.frameForItemNode({ itemNode in
            if let itemNode = itemNode as? ItemListSingleLineInputItemNode, let tag = itemNode.tag, tag.isEqual(to: TwoStepVerificationUnlockSettingsEntryTag.password) {
                resultItemNode = itemNode
                return true
            }
            return false
        })
        if let resultItemNode = resultItemNode {
            resultItemNode.focus()
        }
    }
    controller.didAppear = { firstTime in
        if !firstTime {
            return
        }
        didAppear = true
        initialFocusImpl?()
    }
    
    return controller
}
