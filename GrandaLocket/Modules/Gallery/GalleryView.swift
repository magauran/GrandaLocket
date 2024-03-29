//
//  GalleryView.swift
//  GrandaLocket
//
//  Created by Сердюков Евгений on 25.02.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct GalleryItemView: View {
    let photo: FeedViewModel.Photo
    let viewModel: FeedViewModel

    @State private var scale: CGFloat = 0
    @State private var opacity: CGFloat = 0

    var body: some View {
        ZStack {
            WebImage(url: photo.url)
                .resizable()
                .placeholder {
                    Rectangle().foregroundColor(Color(white: 0.1))
                }
                .indicator(.activity)
                .scaledToFill()
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.scale = 1.2
                    self.opacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.scale = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.scale = 0
                        self.opacity = 0
                    }
                    viewModel.like(photo)
                }
            }
            VStack {
                Spacer()
                HStack {
                    ReactionsCounterView(count: photo.reactionsCount)
                        .padding(.leading, 4)
                        .padding(.bottom, 4)
                    Spacer()
                }
            }
            Text("🔥")
                .font(.system(size: 120))
                .shadow(color: .black, radius: 10, x: 0, y: 0)
                .scaleEffect(scale)
                .opacity(opacity)
        }
    }
}

struct GalleryView: View {
    let photos: [FeedViewModel.Photo]
    let focus: FeedViewModel.Photo
    let viewModel: FeedViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                VStack(spacing: 16) {
                    ForEach(photos, id: \.self) { item in
                        GalleryItemView(photo: item, viewModel: viewModel)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
                .onAppear {
                    withAnimation {
                        value.scrollTo(focus, anchor: .center)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}
