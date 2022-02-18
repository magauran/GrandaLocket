//
//  ContactList.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 16.02.2022.
//

import SwiftUI

struct ContactsView: View {

    @Binding var destination: AppDestination
    @ObservedObject private var contactsInfo = ContactsInfo.instance

    private static var footerHeight: CGFloat {
        48 + 16 + 16 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)
    }

    init(destination: Binding<AppDestination>) {
        self._destination = destination
    }

    var sortedContacts: [ContactInfo] {
        contactsInfo.contacts.sorted(by: {(first, second) in
            first.status.rawValue < second.status.rawValue
        })
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(sortedContacts) { contact in
                        ContactRow(contact: contact)
                            .listRowSeparator(.hidden)
                    }
                    //.animation(.default)
                    .listRowBackground(Palette.blackHard)

                    Spacer()
                        .frame(height: Self.footerHeight)
                }
                .animation(.default, value: contactsInfo.contacts)
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Add your friends")
                FooterView(destination: $destination, nextDestination: .main)
            }.ignoresSafeArea(edges: .bottom)
        }.preferredColorScheme(.dark)
    }
}

private struct ContactRow: View {

    var contact: ContactInfo
    var textForIcon: String {

        let firstLetter: String
        let secondLetter: String

        if let ch = contact.firstName.first {
            firstLetter = String(ch)
        } else {
            firstLetter = ""
        }

        if let ch = contact.lastName.first {
            secondLetter = String(ch)
        } else {
            secondLetter = ""
        }

        return firstLetter + secondLetter
    }

    var body: some View {

        HStack {
            Text("\(textForIcon)")
                .frame(width: 61, height: 61)
                .background {
                    Circle()
                        .stroke()
                        .foregroundColor(Palette.accent)
                }.padding(.trailing, 12)
            VStack(alignment: .leading, spacing: 8) {
                Text("\(contact.firstName) \(contact.lastName)")
                    .foregroundColor(.white)
                    .font(Typography.description)
                    .lineSpacing(4)
                Text("\(contact.phoneNumber)")
                    .foregroundColor(.white.opacity(0.8))
                    .font(Typography.description)
                    .lineSpacing(4)
            }
            Spacer()

            let buttonProperties = getTextButtonPropeties()

            Button {
                UserService().setRequestToChangeContactStatus(contact: contact) { status in
                    //contact.changeStatus(status)
                }
            } label: {
                buttonProperties.label
            }
            .buttonStyle(SmallCapsuleButtonStyle())
            .disabled(buttonProperties.availability)
        }
        .padding(.vertical, 10)
    }

    private func getTextButtonPropeties() -> (label: AnyView, availability: Bool) {
        switch contact.status {
        case .register:
            return (label: AnyView(Text("ADD")), availability: true)
        case .added:
            return (label: AnyView(Text("ADDED")), availability: false)
        case .request:
            return (label: AnyView(Text("REQUEST")), availability: false)
        case .notRegister:
            return (label: AnyView(Text("INVITE")), availability: true)
        }
    }
}
