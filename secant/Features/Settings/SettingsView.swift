import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: SettingsStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 40) {
                Toggle("Enable Crash Reporting",
                       isOn: viewStore.binding(\.$isCrashReportingOn)
                )
                Button(
                    action: { viewStore.send(.backupWalletAccessRequest) },
                    label: { Text("Backup Wallet") }
                )
                .activeButtonStyle
                .frame(height: 50)
                
                Button(
                    action: { viewStore.send(.rescanBlockchain) },
                    label: { Text("Rescan Blockchain") }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Button(
                    action: { viewStore.send(.exportLogs) },
                    label: {
                        if viewStore.exportLogsDisabled {
                            HStack {
                                ProgressView()
                                Text("Exporting...")
                            }
                        } else {
                            Text("Export & share logs")
                        }
                    }
                )
                .primaryButtonStyle
                .frame(height: 50)
                .disabled(viewStore.exportLogsDisabled)

                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationTitle("Settings")
            .applyScreenBackground()
            .confirmationDialog(
                store.scope(state: \.rescanDialog),
                dismiss: .cancelRescan
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForBackupPhrase,
                destination: {
                    RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                }
            )
            .onAppear { viewStore.send(.onAppear) }
            
            if viewStore.isSharingLogs {
                UIShareDialogView(
                    activityItems: [viewStore.tempSDKDir, viewStore.tempWalletDir, viewStore.tempTCADir]
                ) {
                    viewStore.send(.logsShareFinished)
                }
                // UIShareDialogView only wraps UIActivityViewController presentation
                // so frame is set to 0 to not break SwiftUIs layout
                .frame(width: 0, height: 0)
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .placeholder)
    }
}
