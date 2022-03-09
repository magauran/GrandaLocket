//
//  MyFriendsFeedViewModel.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 22.02.2022.
//

import Foundation
import Firebase
import Combine

final class FeedViewModel: ObservableObject {
    struct Photo: Hashable {
        let url: URL
        let reactionsCount: Int
    }

    struct Friend: Hashable {
        var id: String?
        let name: String
        let phone: String
        var photos: [Photo]
    }

    @Published var friends: [Friend] = []
    @Published var myPhotos: [Photo] = []
    private let service = DownloadImageService()
    private var cancellable: AnyCancellable?
    private var cancellablePhoto: AnyCancellable?

    init() {
        self.cancellable = Publishers.CombineLatest(ContactsInfo.instance.$contacts, PhotosInfo.instance.$photos)
            .receive(on: RunLoop.main)
            .removeDuplicates(by: { $0 == $1 })
            .sink { [weak self] contacts, photos in
                guard let self = self else { return }
                let reversedPhoto = photos.reversed()

                let friendsModels = contacts.filter { $0.status == .inContacts(.friend) }

                if let user = Auth.auth().currentUser {
                    let value = reversedPhoto.filter { $0.authorID == user.uid }
                    self.myPhotos = value.map { Photo(url: $0.url, reactionsCount: 0) }
                }

                self.friends = friendsModels.map { friend in
                    let photos = reversedPhoto.filter { $0.authorID == friend.id }
                    let photoItems = photos.map { Photo(url: $0.url, reactionsCount: 0) }
                    return Friend(id: friend.id, name: friend.firstName, phone: friend.phoneNumber, photos: photoItems)
                }
            }

    }
}
