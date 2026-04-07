//
//  SettingsView.swift
//  BeforeYouGo
//
//  Created by Artem Basko on 2026-02-08.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.soundEnabled") private var soundEnabled: Bool = true

    var body: some View {
        NavigationStack {
            List {
                Section("Notification Settings") {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text("Sound")
                        Spacer()
                        Toggle("", isOn: $soundEnabled)
                            .labelsHidden()
                    }

                }

                Section("Location Permissions") {
                    NavigationLink {
                        ManagePermissionsView()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text("Manage Permissions")
                        }
                    }

                    Button {
                        openAppSettings()
                    } label: {
                        Text("Manage Permissions")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("General") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                    }
                }
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct ManagePermissionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Manage Permissions")
                .font(.title2).bold()

            Text("iOS permissions are managed in the system Settings app.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Open iOS Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section("BeforeYouGo") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion())
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(appBuild())
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("A simple checklist app with history.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private func appBuild() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
