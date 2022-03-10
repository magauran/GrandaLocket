//
//  FeedView.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 22.02.2022.
//

import SwiftUI

struct FeedView: View {
    @Binding var destination: AppDestination
    @State private var yDirection: GesturesDirection = .bottom
    @ObservedObject var viewModel = FeedViewModel()
    @State var showContacts: Bool = false

    private var minYToChangeMode: CGFloat {
        UIScreen.main.bounds.height * 0.1
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                MyFeedView(viewModel: viewModel, destination: $destination)
                    .padding(.bottom, 40)
                MyFriendsFeedView(viewModel: viewModel, destination: $destination, showContacts: $showContacts)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        destination = .main
                    } label: {
                        VStack {
                            Image("angle_up")
                                .opacity(0.8)
                            Text("Camera")
                                .font(Typography.controlL)
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct MyFriendsFeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Binding var destination: AppDestination
    @ObservedObject private var contacts = ContactsInfo.instance
    @Binding var showContacts: Bool

    var filteredContacts: [ContactInfo] {
        let request = contacts.contacts.filter { $0.status == .inContacts(.incomingRequest) }
        let result = request.sorted {
            $0.status.order < $1.status.order
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Friends")
                    .font(Typography.headerM)
                    .padding(.bottom, 20)
                Spacer()
                VStack() {
                    addButton
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
            if filteredContacts.count > 0 {
                requestList
                    .padding(.horizontal, 8)
            }
            ForEach(viewModel.friends, id: \.id) { friend in
                if friend.photos.count > 0 {
                    VStack(alignment: .leading) {
                        Text(friend.name)
                            .font(Typography.headerS)
                            .padding(.horizontal, 8)
                        UserPhotosView(photos: friend.photos, viewModel: viewModel)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    var requestList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Requests")
                .font(Typography.headerS)
                .padding(.bottom, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filteredContacts, id: \.phoneNumber) { contact in
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                ImageAvatar(image: contact.image, frame: CGSize(width: 70, height: 70))
                                Text(contact.firstName)
                                    .font(Typography.description)
                                    .lineLimit(nil)
                            }
                            VStack(spacing: 8) {
                                acceptButton(contact: contact)
                                declineButton(contact: contact)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }

    var addButton: some View {
        Button {
            showContacts.toggle()
            //destination = .contacts
        } label: {
            Text("Add friends")
                .font(Typography.controlL)
                .foregroundColor(Palette.accent)
        }
        .sheet(isPresented: $showContacts) {
            ContactsView(destination: $destination, showNextStep: false)
        }
    }

    struct acceptButton: View {
        var contact: ContactInfo
        var body: some View {
            Button {
                UserService().setRequestToChangeContactStatus(contact: contact) { status in }
            } label: {
                Text("ACCEPT")
            }
            .buttonStyle(SmallCapsuleButtonStyle())
            .frame(width: 95, height: 25)
        }
    }

    struct declineButton: View {
        var contact: ContactInfo
        var body: some View {
            Button {
                UserService().setRequestToDeleteContactStatus(contact: contact) { status in }
            } label: {
                Text("DECLINE")
                    .font(Typography.controlM)
                    .foregroundColor(Palette.whiteLight)
            }
            .buttonStyle(SmallDeclineCapsuleButtonStyle())
            .frame(width: 95, height: 25)
        }
    }
}

import Firebase

private struct MyFeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Binding var destination: AppDestination

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Fire")
                    .font(Typography.headerM)
                Spacer()
  //              signOutButton
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 8)
            UserPhotosView(photos: viewModel.myPhotos, viewModel: viewModel)
        }
    }

    var signOutButton: some View {
        Button {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                destination = .phoneNumberAuth
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        } label: {
            Text("Sign out")
        }
    }
}

private struct UserPhotosView: View {
    let photos: [FeedViewModel.Photo]
    let viewModel: FeedViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(photos, id: \.id) { photo in
                    NavigationLink(destination: GalleryView(photos: photos, focus: photo, viewModel: viewModel)) {
                        ZStack {
                            AsyncImage(url: photo.url) { image in
                                image
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack {
                                Spacer()
                                HStack {
                                    ReactionsCounterView(count: photo.reactionsCount)
                                        .padding(.leading, 4)
                                        .padding(.bottom, 2)
                                    Spacer()
                                }
                            }
                        }.frame(width: 100, height: 100)
                    }
                }
            }.padding(.horizontal, 8)
        }
    }
}
