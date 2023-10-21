//
//  VoteContentView.swift
//  TwoHoSun
//
//  Created by 김민 on 10/19/23.
//

import SwiftUI

import Kingfisher

enum VoteType {
    case agree, disagree

    var title: String {
        switch self {
        case .agree:
            return "산다"
        case .disagree:
            return "안산다"
        }
    }

    var color: Color {
        switch self {
        case .agree:
            return .orange
        case .disagree:
            return .pink
        }
    }
}

struct VoteContentView: View {
    @State private var isVoteCompleted = false
    @State private var isImageDetailPresented = false
    @State private var isLinkWebViewPresented = false
    @State var title: String
    @State var contents: String
    @State var imageURL: String
    @State var externalURL: String
    @State var likeCount: Int
    @State var viewCount: Int
    @State var commentCount: Int
    @State var agreeCount: Int
    @State var disagreeCount: Int

    var buyCountRatio: Double {
        let ratio = Double(agreeCount) / Double(viewCount) * 100
        return Double(Int(ratio * 10)) / 10.0
    }

    var notBuyCountRatio: Double {
        return 100 - buyCountRatio
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                decorationBoxView
                    .padding(.top, 22)
                titleView
                    .padding(.top, 12)
                voteInfoView
                    .padding(.top, 10)
                contentTextView
                    .padding(.top, 20)
                tagView
                    .padding(.top, 16)
                voteImageView
                    .padding(.top, 12)
                voteView
                    .padding(.top, 10)
            }
            .padding(.horizontal, 26)

            HStack(spacing: 0) {
                likeButton
                    .padding(.trailing, 10)
                commentButton
                Spacer()
                shareButton
            }
            .padding(.leading, 20)
            .padding(.trailing, 26)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 0) {
                likeCountingLabel
                    .padding(.top, 10)
                commentCountButton
                    .padding(.top, 8)
                uploadTimeLabel
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
            .padding(.leading, 26)

            Rectangle()
                .frame(height: 10)
                .foregroundStyle(.gray)
        }
        .fullScreenCover(isPresented: $isImageDetailPresented) {
            NavigationView {
                ImageDetailView(imageURL: imageURL, externalURL: externalURL)
            }
        }
        .fullScreenCover(isPresented: $isLinkWebViewPresented) {
            NavigationView {
                LinkView(externalURL: externalURL)
            }
        }
    }
}

extension VoteContentView {

    private var decorationBoxView: some View {
        Rectangle()
            .frame(width: 18, height: 3)
            .foregroundStyle(.gray)
    }

    private var titleView: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
        }
    }

    private var voteInfoView: some View {
        HStack(spacing: 0) {
            Image(systemName: "timer")
                .padding(.trailing, 3)
            Text("6시간 후")
                .padding(.trailing, 12)
            Image(systemName: "person.fill")
                .padding(.trailing, 3)
            Text("\(viewCount)")
        }
        .font(.system(size: 12))
        .foregroundStyle(.gray)
    }

    private var contentTextView: some View {
        Text(contents)
            .font(.system(size: 16))
    }

    private var tagView: some View {
        HStack {
            ForEach(1..<3) { index in
                tag("\(index)")
            }
        }
    }

    @ViewBuilder
    private var voteImageView: some View {
        if !imageURL.isEmpty {
            ZStack(alignment: .bottomTrailing) {
                KFImage(URL(string: imageURL)!)
                    .placeholder {
                        ProgressView()
                    }
                    .onFailure { error in
                        print(error.localizedDescription)
                    }
                    .cancelOnDisappear(true)
                    .resizable()
                    .frame(width: 200, height: 200)
                linkButton
                    .padding(.trailing, 12)
                    .padding(.bottom, 10)
            }
            .onTapGesture {
                isImageDetailPresented = true
            }
        }
    }

    private var linkButton: some View {
        Button {
            isLinkWebViewPresented = true
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "link")
                Text("링크")
            }
            .font(.system(size: 10))
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    @ViewBuilder
    private var voteView: some View {
        if isVoteCompleted {
            completedVoteView
        } else {
            defaultVoteView
        }
    }

    private var completedVoteView: some View {
        ZStack {
            HStack(spacing: 0) {
                voteResultView(for: .agree, buyCountRatio)
                voteResultView(for: .disagree, notBuyCountRatio)
            }
            .frame(width: 338, height: 60)
            vsLabel
                .offset(x: 169 - (338 * (100 - buyCountRatio) / 100))
                .opacity(buyCountRatio > 95 || notBuyCountRatio > 95 ? 0.0 : 1.0)
        }
    }

    private func voteResultView(for voteType: VoteType, _ voteRatio: Double) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(voteType.color)
                .frame(width: 338 * voteRatio / 100)
            if voteRatio >= 20 {
                VStack(spacing: 0) {
                    Text(voteType.title)
                        .font(.system(size: 16))
                    Text("(" + String(format: getFirstDecimalNum(voteRatio) == 0 ? "%.0f" : "%.1f", voteRatio) + "%)")
                        .font(.system(size: 12))
                }
            }
        }
    }

    private var defaultVoteView: some View {
        ZStack {
            HStack(spacing: 0) {
                Button {
                    isVoteCompleted = true
                    print("buy button tap")
                } label: {
                    Text("산다")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 169, height: 60)
                        .background(Color.orange)
                }
                Button {
                    isVoteCompleted = true
                    print("not buy button tap")
                } label: {
                    Text("안산다")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 169, height: 60)
                        .background(Color.pink)
                }
            }
            vsLabel
        }
    }

    private var vsLabel: some View {
        Text("vs")
            .frame(width: 33, height: 17)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var likeButton: some View {
        Button {
            print("like button did tap")
        } label: {
            Image(systemName: "heart")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
    }

    private var commentButton: some View {
        Button {
            print("like button did tap")
        } label: {
            Image(systemName: "message")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
    }

    private var shareButton: some View {
        Button {
            print("share button did tap")
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24))
                .foregroundStyle(.gray)
        }
    }

    private func tag(_ content: String) -> some View {
        Text("# \(content)")
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.gray)
    }

    @ViewBuilder
    private var likeCountingLabel: some View {
        if likeCount != 0 {
            HStack {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.gray)
                Text("김아무개님 외 \(likeCount)명이 좋아합니다")
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    @ViewBuilder
    private var commentCountButton: some View {
        if commentCount != 0 {
            Button {
                print("comment button did tap")
            } label: {
                Text("댓글 \(commentCount)개 모두 보기")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
        }
    }

    private var uploadTimeLabel: some View {
        Text("2분전")
            .font(.system(size: 14))
            .foregroundStyle(.gray)
    }

    private func getFirstDecimalNum(_ voteRatio: Double) -> Int {
        return Int((voteRatio * 10).truncatingRemainder(dividingBy: 10))
    }
}

#Preview {
    VoteContentView(title: "배고파... 치킨 살말...",
                    contents: "너무너무 배고파혀 빨리정래줘 꾸예우에웨에ㅐㅜ엑으우어우양아ㅔㅇㅇ엥",
                    imageURL: "https://picsum.photos/200/300",
                    externalURL: "",
                    likeCount: 4,
                    viewCount: 6,
                    commentCount: 20,
                    agreeCount: 3,
                    disagreeCount: 3)
}
